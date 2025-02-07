extends Node

const NON_ACTION = "-"
const DEADZONE = 0.1

var device: InputDevice
var actions: Array[String]
var actionDirections: Dictionary

var actionPressedDict: Dictionary # actionName: String -> bool
var actionJustPressedDict: Dictionary # actionName: String -> bool
var actionJustReleasedDict: Dictionary # actionName: String -> bool
var actionValueDict: Dictionary # actionName: String -> float

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
		actionJustPressedDict[action] = false
		actionJustReleasedDict[action] = false
		actionValueDict[action] = 0

func is_action_pressed(action: String) -> bool:
	return action in actions and actionPressedDict[action]

func is_action_just_pressed(action: String) -> bool:
	return action in actions and actionJustPressedDict[action]

func is_action_just_released(action: String) -> bool:
	return action in actions and actionJustReleasedDict[action]

func get_action_value(action: String) -> float:
	if action not in actions:
		return 0
	return actionValueDict[action]

func _input(event: InputEvent) -> void:
	var event_action = get_event_action_type(event)
	if event_action == NON_ACTION or not device.isInputEventSameDevice(event):
		return
	if event.is_pressed():
		actionPressedDict[event_action] = true
		actionJustPressedDict[event_action] = true
		actionJustReleasedDict[event_action] = false
		actionValueDict[event_action] = 0
	elif event.is_released():
		actionPressedDict[event_action] = false
		actionJustPressedDict[event_action] = false
		actionJustReleasedDict[event_action] = true
		actionValueDict[event_action] = 0
	
func _process(delta: float) -> void:
	for action in actions:
		actionJustPressedDict[action] = false
		actionJustReleasedDict[action] = false

func get_event_action_type(event: InputEvent) -> String:
	for action in actions:
		if event.is_action(action):
			if not isControllerJoystickEvent(event):
				return action
			var axis = getJoystickAxis(action)
			var axis_val = Input.get_joy_axis(device.deviceId, axis)
			if axis_val * actionDirections[action] > DEADZONE: # flip sign if negative
				return action
	return NON_ACTION

func isControllerJoystickEvent(event: InputEvent) -> bool:
	return event.is_class("InputEventJoypadMotion")

func getJoystickAxis(actionType: String) -> JoyAxis:
	var mapping = InputMap.action_get_events(actionType)
	for evt in mapping:
		if isControllerJoystickEvent(evt):
			return evt.axis
	return -1
