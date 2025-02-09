extends PanelContainer

const DEFAULT_TEXT = "Space / A / X"

@export var playerIcon: Texture
@export var blockColor: Color  # color when joined

var inputDevice: InputDevice = null

var blankColor: Color
var styleBox: StyleBoxFlat

func _ready():
	$MarginContainer/VBoxContainer/TextureRect.texture = playerIcon
	$MarginContainer/VBoxContainer/Button.custom_minimum_size = $MarginContainer/VBoxContainer/Button.size
	styleBox = get_theme_stylebox("panel").duplicate()
	blankColor = styleBox.bg_color

func set_player_joined(device: InputDevice, name: String):
	inputDevice = device
	styleBox.bg_color = blockColor
	add_theme_stylebox_override("panel", styleBox)
	$MarginContainer/VBoxContainer/Button.text = name

func set_player_left():
	inputDevice = null
	styleBox.bg_color = blankColor
	add_theme_stylebox_override("panel", styleBox)
	$MarginContainer/VBoxContainer/Button.text = DEFAULT_TEXT

func get_player_data():
	var dev = inputDevice.as_tuple()
	dev.push_back($MarginContainer/VBoxContainer/TextureRect.texture)
	return dev
	
func show_indicator():
	$Indicator.show()
	
func hide_indicator():
	$Indicator.hide()
