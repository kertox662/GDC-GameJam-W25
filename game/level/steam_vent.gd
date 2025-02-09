extends Area2D

@export var lifetime: float = 2

func _ready() -> void:
	$CPUParticles2D.lifetime = lifetime
