class_name InputDevice extends Node

var deviceId: int
var isController: bool

func _init(deviceId: int, isController: bool) -> void:
	self.deviceId = deviceId
	self.isController = isController

static func fromInputEvent(event: InputEvent) -> InputDevice:
	var isControllerEvent = (event.is_class("InputEventJoypadButton") or
							event.is_class("InputEventJoypadMotion"))
	return InputDevice.new(event.device, isControllerEvent)

func isInputEventSameDevice(event: InputEvent) -> bool:
	if deviceId != event.device:
		return false
	var isControllerEvent = (event.is_class("InputEventJoypadButton") or
							event.is_class("InputEventJoypadMotion"))
	return isController == isControllerEvent
