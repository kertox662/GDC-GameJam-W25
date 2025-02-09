extends CharacterBody2D
class_name Player

signal killed(CharacterBody2D)

const BASE_GRAVITY = 1000
const VENT_MULTIPLIER = -1.2
const COOLDOWN_TIME = 0.3

var face_direction := 1
var x_dir := 1
var shoot_input_enabled = true

var max_speed: float = 200
var acceleration: float = 2000
var turning_acceleration : float = 6400
var deceleration: float = 3200

var gravity_acceleration : float = BASE_GRAVITY
var gravity_max : float = 600
var gravity_multiplier_when_small : float = 0.3

var jump_height: float = 100
var jump_force : float = 90
var jump_cut : float = 0.25
var jump_gravity_max : float = 500
var jump_hang_treshold : float = 2.0
var jump_hang_gravity_mult : float = 0.1

var jump_coyote : float = 0.08
var jump_buffer : float = 0.1

var jump_coyote_timer : float = 0
var jump_buffer_timer : float = 0
var is_jumping := false

var up = "move_up"
var down = "move_down"
var left = "move_left"
var right = "move_right"
var shoot = "shoot"
var jump = "jump"
var ammo = 1
var actions: Array[String] = [up, down, left, right, shoot, jump]
var actionDirs: Dictionary = {
	up: -1,
	down: 1,
	left: -1,
	right: 1
}

var invincible := false

@export var deviceId = 0
@export var useController = false

var running
var charging

var animation_lock = 0

func animation_logic(delta):
	if animation_lock > 0:
		animation_lock -= delta
		return

	if hold_time > 0.0:
		$AnimatedSprite2D.play("charging")
		return

	if is_jumping:
		$AnimatedSprite2D.play("jump")
	elif running:
		$AnimatedSprite2D.play("running")
	else:
		$AnimatedSprite2D.play("idle")
	
func _ready():
	var inputDevice = InputDevice.new(deviceId, useController)
	$Input.initialize(inputDevice, actions, actionDirs)

func _process(delta):
	update_shooting_direction()
	shooting_logic(delta)
	animation_logic(delta)

func enable_shooting():
	shoot_input_enabled = true
	
func disable_shooting():
	shoot_input_enabled = false

func get_input() -> Dictionary:
	var x = int($Input.is_action_pressed(right)) - int($Input.is_action_pressed(left))
	var y = int($Input.is_action_pressed(down)) - int($Input.is_action_pressed(up))
	if useController:
		x = sign($Input.get_joystick_value("move_right"))
		y = sign($Input.get_joystick_value("move_down"))
		
	return {
		"x": x,
		"y": y,
		"just_jump": $Input.is_action_just_pressed(jump),
		"jump": $Input.is_action_pressed(jump),
		"released_jump": $Input.is_action_just_released(jump),
		"shoot": $Input.is_action_pressed(shoot) and shoot_input_enabled
	}

func _physics_process(delta: float) -> void:
	if useController:
		$Input.update_joystick_pressed()
	x_movement(delta)
	jump_logic(delta)
	apply_gravity(delta)

	timers(delta)
	move_and_slide()


func x_movement(delta: float) -> void:
	x_dir = get_input()["x"]
	
	# Stop if we're not doing movement inputs.
	if x_dir == 0:
		velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0,0), deceleration * delta).x
		running = false
		return
	
	running = true
	
	# If we are doing movement inputs and above max speed, don't accelerate nor decelerate
	# Except if we are turning
	# (This keeps our momentum gained from outside or slopes)
	if abs(velocity.x) >= max_speed and sign(velocity.x) == x_dir:
		return
	
	# Are we turning?
	# Deciding between acceleration and turn_acceleration
	var accel_rate : float = acceleration if sign(velocity.x) == x_dir else turning_acceleration
	
	# Accelerate
	velocity.x += x_dir * accel_rate * delta
	
	set_direction(x_dir) # This is purely for visuals


func set_direction(hor_direction) -> void:
	# This is purely for visuals
	# Turning relies on the scale of the player
	# To animate, only scale the sprite
	if hor_direction == 0:
		return
	apply_scale(Vector2(hor_direction * face_direction, 1)) # flip
	face_direction = hor_direction # remember direction


#var direction := Vector2(1, -0.5)
var direction := Vector2(0.5, -1)
func update_shooting_direction() -> void:
	var new_direction := Vector2(0, 0)
	#if useController:
		##new_direction = Vector2($Input.get_joystick_value("move_right"), $Input.get_joystick_value("move_down"))
		##new_direction = Vector2(sign($Input.get_joystick_value("move_right")), -1.5)
	#else:
		##if $Input.is_action_pressed("jump"):
			##new_direction = Vector2(face_direction, -2)
		##else:
			##new_direction = Vector2(face_direction, -0.1)

	new_direction = Vector2(face_direction, -1.5)

	if not new_direction.is_zero_approx():
		direction = new_direction


func jump_logic(_delta: float) -> void:
	# Reset our jump requirements
	if is_on_floor():
		jump_coyote_timer = jump_coyote
		is_jumping = false
	
	if gravity_acceleration < 0:
		is_jumping = true

	if get_input()["just_jump"]:
		jump_buffer_timer = jump_buffer
	
	# Jump if grounded, there is jump input, and we aren't jumping already
	if jump_coyote_timer > 0 and jump_buffer_timer > 0 and not is_jumping:
		is_jumping = true
		jump_coyote_timer = 0
		jump_buffer_timer = 0

		velocity.y = -sqrt(2 * gravity_acceleration * jump_force)
	
	# Cut the velocity if let go of jump. This means our jumpheight is varaiable
	# This should only happen when moving upwards, as doing this while falling would lead to
	# The ability to studder our player mid falling
	if get_input()["released_jump"] and velocity.y < 0:
		velocity.y -= (jump_cut * velocity.y)
	
	# This way we won't start slowly descending / floating once hit a ceiling
	# The value added to the treshold is arbritary,
	# But it solves a problem where jumping into 
	if is_on_ceiling(): velocity.y = jump_hang_treshold + 100.0


func apply_gravity(delta: float) -> void:
	var applied_gravity : float = 0
	
	# No gravity if we are grounded
	if jump_coyote_timer > 0 and gravity_acceleration >= 0:
		return
	
	# Normal gravity limit
	if abs(velocity.y) <= gravity_max:
		applied_gravity = gravity_acceleration * delta
	
	# If moving upwards while jumping, the limit is jump_gravity_max to achieve lower gravity
	if (is_jumping and velocity.y < 0) and velocity.y > jump_gravity_max:
		applied_gravity = 0
	
	# Lower the gravity at the peak of our jump (where velocity is the smallest)
	if is_jumping and abs(velocity.y) < jump_hang_treshold:
		applied_gravity *= jump_hang_gravity_mult
	
	velocity.y += applied_gravity


func timers(delta: float) -> void:
	# Using timer nodes here would mean unnececary functions and node calls
	# This way everything is contained in just 1 script with no node requirements
	jump_coyote_timer -= delta
	jump_buffer_timer -= delta

var cooldown := 0.0
var hold_time := 0.0


func shooting_logic(delta: float) -> void:
	cooldown -= delta
	if cooldown > 0:
		return
	if $Input.is_action_pressed("shoot"):
		hold_time += delta
	if $Input.is_action_just_released("shoot") or hold_time > 2.0:
			var shots = ceil(hold_time * 2)
			for i in range(shots):
				# calculate direction
				var new_projectile : Projectile = Globals.projectile.instantiate()
				get_parent().add_child(new_projectile)
				new_projectile.linear_velocity = Vector2(velocity.x, 0) + direction.normalized().rotated(i * 0.15) * min(200.0 + hold_time * 200.0, 400.0) * randf_range(0.8, 1.2)
				# random
				#new_projectile.apply_central_force(Vector2(randi_range(-50, 50), randi_range(-50, 50)))
				new_projectile.global_position = global_position + direction.normalized().rotated(i * 0.15) * $bullet_spawn.shape.radius # make sure we havent set a scale!

			$AnimatedSprite2D.play("attack")
			animation_lock = 0.2

			cooldown = COOLDOWN_TIME
			hold_time = 0
			ammo -= 1

func parry_logic(delta: float) -> void:
	cooldown -= delta
	if $Input.is_action_pressed("shoot"):
		hold_time += delta
	if $Input.is_action_just_released("shoot"):
		# create projectile
		if cooldown <= 0:
			#print("shooting!")
			var new_projectile : Projectile = Globals.projectile.instantiate()
			get_parent().add_child(new_projectile)

			# calculate direction
			new_projectile.linear_velocity = Vector2(velocity.x, 0) + direction.normalized() * max(100, min(hold_time * 1000.0, 500))
			# random
			#new_projectile.apply_central_force(Vector2(0, 1) * randi_range(2,4))
			new_projectile.global_position = global_position + direction.normalized() * $bullet_spawn.shape.radius # make sure we havent set a scale!
			cooldown = COOLDOWN_TIME
			hold_time = 0

func _on_hurtbox_body_entered(body):
	body.queue_free()
	if !invincible:
		killed.emit(self)
		$hurtbox/hurtboxshape.set_deferred("disabled", true)

func _on_ventbox_area_entered(area: Area2D) -> void:
	gravity_acceleration = BASE_GRAVITY * VENT_MULTIPLIER

func _on_ventbox_area_exited(area: Area2D) -> void:
	gravity_acceleration = BASE_GRAVITY
