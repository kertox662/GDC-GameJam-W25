extends Node

const DEADZONE = 0.5
const JUST_PRESSED_TICKS = 3

var device: InputDevice
var actions: Array[String]
var actionDirections: Dictionary

var inputMu: Mutex

var actionPressedDict: Dictionary # actionName: String -> bool
var actionJustPressedDict: Dictionary # actionName: String -> numberOfFramesToBePressed: int
var actionJustReleasedDict: Dictionary # actionName: String -> numberOfFramesToBePressed: int
var actionValueDict: Dictionary # actionName: String -> float

func _ready():
	inputMu = Mutex.new()

func initialize(device: InputDevice, actions: Array[String], actionDirections: Dictionary) -> void:
	self.device = device
	self.actions = actions
	self.actionDirections = actionDirections
	actionPressedDict = {}
	actionJustPressedDict = {}
	actionJustReleasedDict = {}
	actionValueDict = {}

	for action in actions:
		actionPressedDict[action] = false
		actionJustPressedDict[action] = 0
		actionJustReleasedDict[action] = 0
		actionValueDict[action] = 0

func is_action_pressed(action: String) -> bool:
	return action in actions and actionPressedDict[action]

func is_action_just_pressed(action: String) -> bool:
	if action not in action:
		return false
	inputMu.lock()
	var pressed = actionJustPressedDict[action]
	inputMu.unlock()
	return pressed > 0

func is_action_just_released(action: String) -> bool:
	if action not in action:
		return false
	inputMu.lock()
	var released = actionJustReleasedDict[action]
	inputMu.unlock()
	return released > 0

func get_joystick_value(pos_axis_action: String) -> float:
	var axis = getJoystickAxis(pos_axis_action)
	var axis_value = Input.get_joy_axis(device.deviceId, axis)
	# return the value if the magnitude is greater than the deadzone.
	return axis_value if abs(axis_value) >= DEADZONE else 0

func update_joystick_pressed() -> void:
	inputMu.lock()
	for action in actionDirections:
		# actionDirections will adjust for the negative and positive directions.
		var actionState = get_joystick_value(action) * actionDirections[action] >= DEADZONE
		var prevState = actionPressedDict[action]
		actionPressedDict[action] = actionState
		# Check that previous state is different from current state
		if actionState and not prevState:
			actionJustPressedDict[action] = JUST_PRESSED_TICKS
		if (not actionState) and prevState:
			actionJustReleasedDict[action] = JUST_PRESSED_TICKS
	inputMu.unlock()

func _unhandled_input(event: InputEvent) -> void:
	if not device.isInputEventSameDevice(event):
			return
	if event.is_class("InputEventKey") and event.echo:
		return
	var event_actions = get_event_action_type(event)
	inputMu.lock()
	for event_action in event_actions:
		if isControllerJoystickEvent(event):
			actionValueDict[event_action] = event.axis_value
			continue
		
		if event.is_pressed():
			actionPressedDict[event_action] = true
			actionJustPressedDict[event_action] = JUST_PRESSED_TICKS
			actionValueDict[event_action] = 1
		elif event.is_released():
			actionPressedDict[event_action] = false
			actionJustReleasedDict[event_action] = JUST_PRESSED_TICKS
			actionValueDict[event_action] = 0
	inputMu.unlock()

func _process(delta: float) -> void:
	inputMu.lock()
	for action in actions:
		actionJustPressedDict[action] = max(0, actionJustPressedDict[action] - 1)
		actionJustReleasedDict[action] = max(0, actionJustReleasedDict[action] - 1)
	inputMu.unlock()

func get_event_action_type(event: InputEvent) -> Array:
	var ret = []
	for action in actions:
		if event.is_action(action):
			if not isControllerJoystickEvent(event):
				ret.append(action)
				continue
			var axis = getJoystickAxis(action)
			var axis_val = Input.get_joy_axis(device.deviceId, axis)
			if axis_val * actionDirections[action] > DEADZONE: # flip sign if negative
				ret.append(action)
	return ret

func isControllerJoystickEvent(event: InputEvent) -> bool:
	return event.is_class("InputEventJoypadMotion")

func getJoystickAxis(actionType: String) -> JoyAxis:
	var mapping = InputMap.action_get_events(actionType)
	for evt in mapping:
		if isControllerJoystickEvent(evt):
			return evt.axis
	return -1
