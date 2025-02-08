extends RigidBody2D

class_name Projectile

var bounces := 5
# Called when the node enters the scene tree for the first time.
func _ready():
	set_contact_monitor(true)
	max_contacts_reported = 1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.get_class() == "TileMapLayer":
		bounces -= 1
		if bounces == 0:
			queue_free()
