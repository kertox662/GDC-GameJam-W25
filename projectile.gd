extends RigidBody2D

class_name Projectile

var bounces := 5
# Called when the node enters the scene tree for the first time.
func _ready():
	set_contact_monitor(true)
	max_contacts_reported = 1
	pass # Replace with function body.


var previous_position := Vector2(0, 0)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta):
	$Icon.global_rotation = previous_position.angle_to_point(global_position) - PI / 2
	previous_position = global_position
	#$Icon.rotation = -get_parent().rotation


func _on_body_entered(body):
	if body.get_class() == "TileMapLayer":
		bounces -= 1
		$BounceSound.pitch_scale = randf() + 1.2
		$BounceSound.play(0)
		if bounces == 0:
			queue_free()
