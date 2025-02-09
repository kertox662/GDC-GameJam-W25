extends Node2D

var projectile := load("res://Projectile.tscn")
var corpse := load("res://Corpse.tscn")


var screen_size: Vector2i
@onready var window_size: Vector2i = DisplayServer.window_get_size()

# Called when the node enters the scene tree for the first time.
func _ready():
	# set the window size to be 70% of the height, then set the width based off the resolution
	var resolution: float = float(window_size.x) / float(window_size.y)
	screen_size = DisplayServer.screen_get_size()
	window_size = Vector2i(round(screen_size.y*0.5*resolution),
						   round(screen_size.y*0.5))
	
	DisplayServer.window_set_size(window_size)
	DisplayServer.window_set_position(screen_size/2 - window_size/2)

func changeScene(packed : PackedScene) -> Error :
	return get_tree().change_scene_to_packed(packed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
