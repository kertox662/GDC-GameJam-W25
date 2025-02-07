extends CharacterBody2D

var face_direction := 1
var x_dir := 1

var max_speed: float = 400
var acceleration: float = 2400
var turning_acceleration : float = 9600
var deceleration: float = 3200

var gravity_acceleration : float = 3840
var gravity_max : float = 1020
var gravity_multiplier_when_small : float = 0.3

var jump_height: float = 200
var jump_force : float = 200
var jump_cut : float = 0.25
var jump_gravity_max : float = 500
var jump_hang_treshold : float = 2.0
var jump_hang_gravity_mult : float = 0.1

var jump_coyote : float = 0.08
var jump_buffer : float = 0.1

var jump_coyote_timer : float = 0
var jump_buffer_timer : float = 0
var is_jumping := false

var up = "ui_up"
var down = "ui_down"
var left = "ui_left"
var right = "ui_right"
var shoot = "shoot"

func get_input() -> Dictionary:
	return {
		"x": int(Input.is_action_pressed(right)) - int(Input.is_action_pressed(left)),
		"y": int(Input.is_action_pressed(down)) - int(Input.is_action_pressed(up)),
		"just_jump": Input.is_action_just_pressed(up) == true,
		"jump": Input.is_action_pressed(up) == true,
		"released_jump": Input.is_action_just_released(up) == true,
		"shoot": Input.is_action_pressed(shoot)
	}


func _physics_process(delta: float) -> void:
	x_movement(delta)
	jump_logic(delta)
	apply_gravity(delta)

	timers(delta)
	move_and_slide()

#func size_change_logic() -> void:
	#if get_input()["change_size"]:
		#size_tween = self.create_tween()
		#if size == "small":
			#size = "normal"
			#size_tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
			#size_tween.tween_property($ScreenCamera, "zoom", Vector2(2, 2), 0.1)
		#else:
			#size = "small"
			#size_tween.tween_property(self, "scale", Vector2(small_size_multiplier, small_size_multiplier), 0.1)
			#size_tween.tween_property($ScreenCamera, "zoom", Vector2(6, 6), 0.1)


func x_movement(delta: float) -> void:
	x_dir = get_input()["x"]
	
	# Stop if we're not doing movement inputs.
	if x_dir == 0:
		velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0,0), deceleration * delta).x
		return
	
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


func jump_logic(_delta: float) -> void:
	# Reset our jump requirements
	if is_on_floor():
		jump_coyote_timer = jump_coyote
		is_jumping = false
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
	if jump_coyote_timer > 0:
		return
	
	# Normal gravity limit
	if velocity.y <= gravity_max:
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
