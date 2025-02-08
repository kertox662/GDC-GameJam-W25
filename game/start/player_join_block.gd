extends Control

const DEFAULT_TEXT = "Space / A / X"

@export var playerIcon: Texture

var inputDevice: InputDevice = null

func _ready():
	$MarginContainer/VBoxContainer/TextureRect.texture = playerIcon
	$MarginContainer/VBoxContainer/Button.custom_minimum_size = $MarginContainer/VBoxContainer/Button.size

func set_player_joined(device: InputDevice, name: String):
	inputDevice = device
	$MarginContainer/VBoxContainer/Button.text = name

func set_player_left():
	inputDevice = null
	$MarginContainer/VBoxContainer/Button.text = DEFAULT_TEXT
