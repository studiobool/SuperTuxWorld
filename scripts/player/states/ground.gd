extends PlayerState

@export var state_name : String

func enter(previous_state_path: String, data := {}) -> void:
	player.state = state_name

func physics_update(delta: float) -> void:
	player.water_collision.disabled = true
	
	if !player.is_on_floor():
		if player.coyote_timer < player.coyote_time:
			player.coyote_timer += delta
	else:
		player.coyote_timer = 0.0
	
	if player.jump_buffer_pressed:
		player.jump_buffer_timer += delta
	if player.jump_buffer_timer > player.jump_buffer_time:
		player.jump_buffer_pressed = false
	
	# Add the gravity.
	var gravity
	if player.holding_jump:
		gravity = (player.get_gravity() * player.power.grav_multi)
	else:
		gravity = player.get_gravity()
	
	if player.stand_collision.disabled && !player.has_pounded_floor:
		if player.velocity.y <= player.MIN_POUND_THRESHOLD:
			player.if_pound = true
		elif player.velocity.y >= 0.1:
			player.if_pound = false
	else:
		player.if_pound = false
	
	if player.if_pound:
		if player.is_on_floor() && !player.has_pounded_floor:
			player.has_pounded_floor = true
			player.jump(player.velocity + Vector3(0, 12, 0))
			player.sfx._brick()
			player.pound_timer.start()
	
	if player.pound_timer.is_stopped():
		if player.is_on_floor():
			player.has_pounded_floor = false
	
	if not player.is_on_floor() && player.coyote_timer >= player.coyote_time:
		if player.stand_collision.disabled && !player.has_pounded_floor:
			player.velocity += player.get_gravity() * 6.5 * delta
		else:
			if player.velocity.y >= -0.1:
				player.velocity += player.get_gravity() * 1.5 * delta
			else:
				if player.holding_jump && player.power.is_wing:
					player.velocity += gravity * delta
				else:
					player.velocity += player.get_gravity() * 1.75 * delta
	
	# Handle jump.
	if player.is_on_floor():
		player.if_jumped = false
	
	if player.is_on_ceiling_only():
		player.sfx._brick()
	
	if Input.is_action_just_pressed("jump") && !player.head_detection.is_colliding():
		player.jump_buffer_pressed = true
		player.jump_buffer_timer = 0
	
	var jump_move_boost = player.velocity.length() / 3
	if player.jump_buffer_pressed && (player.is_on_floor() or player.water_detection.is_colliding() or player.coyote_timer < player.coyote_time):
		if player.velocity.y <= 0.0:
			player.jump(Vector3(0, player.jump_velocity + jump_move_boost * player.power.jump_multi, 0))
			player.sfx._jump()
			player.if_jumped = true
	if Input.is_action_just_released("jump") && player.if_jumped:
		if player.velocity.y >= (player.jump_velocity + jump_move_boost * player.power.jump_multi) / 2:
			player.velocity.y = (player.jump_velocity + jump_move_boost * player.power.jump_multi) / 2
	
	player.holding_jump = Input.is_action_pressed("jump")

	if Input.is_action_pressed("sprint") && !player.stand_collision.disabled:
		if player.is_on_floor() or player.coyote_timer >= player.coyote_time:
			player.speed = player.SPRINT
			player.is_sprinting = true
	elif !player.stand_collision.disabled:
		player.speed = player.WALK
		player.PLAYER_COLLIDER = player.stand_collision
		player.is_sprinting = false
	else:
		player.speed = player.CRAWL
		player.PLAYER_COLLIDER = player.crawl_collision
		player.is_sprinting = false
	
	player.crawl_collision.global_rotation = player.model.global_rotation + Vector3(0, deg_to_rad(-90), 0)
	
	if Input.is_action_pressed("crawl") && player.speed != player.SPRINT:
		player.stand_collision.disabled = true
		player.crawl_collision.disabled = false
	elif !player.head_detection.is_colliding():
		player.stand_collision.disabled = false
		player.crawl_collision.disabled = true
	
	if player.floor_detection.is_colliding():
		player.acceleration = player.ICE_ACCEL
		player.deceleration = player.ICE_DECEL
	else:
		player.acceleration = player.DEFAULT_ACCEL
		player.deceleration = player.DEFAULT_ACCEL
	
	# Multiplies deceleration
	if !player.direction && player.is_on_floor() && player.velocity.length() >= 1.0:
		if !player.floor_detection.is_colliding():
			player.deceleration = player.deceleration * 2
	
	# Get the input direction and handle the movement/deceleration.
	player.input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.direction = (player.transform.basis * Vector3(player.input_dir.x, 0, player.input_dir.y))
	player.direction = player.direction.rotated(Vector3.UP, player.camera.camera.rotation.y)
	
	var friction : Vector2
	friction.x = (player.acceleration if player.direction.x else player.deceleration) * delta
	friction.y = (player.acceleration if player.direction.z else player.deceleration) * delta
	
	if player.direction:
		player.velocity.x = lerp(player.velocity.x, player.direction.x * player.speed, friction.x)
		player.velocity.z = lerp(player.velocity.z, player.direction.z * player.speed, friction.y)
	elif player.is_on_floor():
		player.velocity.x = lerp(player.velocity.x, 0.0, friction.x)
		player.velocity.z = lerp(player.velocity.z, 0.0, friction.y)
	else:
		player.velocity.x = lerp(player.velocity.x, 0.0, delta)
		player.velocity.z = lerp(player.velocity.z, 0.0, delta)
	
	player._push_away_rigid_bodies()
	#player.move_and_slide()
	
	
	if player.water_detection.is_colliding():
		finished.emit(WATER)
