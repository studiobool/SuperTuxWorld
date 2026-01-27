extends PlayerState

@export var state_name : String

func enter(previous_state_path: String, data := {}) -> void:
	player.state = state_name

func physics_update(delta: float) -> void:
	if !player.is_on_floor():
		player.coyote_timer += delta
	else:
		player.coyote_timer = 0.0
	
	# Add the gravity.
	var gravity
	if player.holding_jump:
		gravity = (player.get_gravity() * player.power.grav_multi)
	else:
		gravity = player.get_gravity()
	
	if player.stand_collision.disabled:
		if player.velocity.y <= -23:
			player.if_pound = true
	else:
		player.if_pound = false
	
	if not player.is_on_floor() && player.coyote_timer >= player.coyote_float:
		if player.stand_collision.disabled && player.velocity.y <= -2:
			player.velocity += player.get_gravity() * 7.5 * delta
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
	
	var jump_move_boost = player.velocity.length() / 3
	if Input.is_action_just_pressed("jump") && (player.is_on_floor() or player.water_detection.is_colliding() or player.coyote_timer < player.coyote_time):
		if player.velocity.y <= 0.0:
			player.jump(Vector3(0, player.JUMP_VELOCITY + jump_move_boost * player.power.jump_multi, 0))
			player.sfx._jump()
			player.if_jumped = true
	if Input.is_action_just_released("jump") && player.if_jumped:
		if player.velocity.y >= (player.JUMP_VELOCITY + jump_move_boost * player.power.jump_multi) / 2:
			player.velocity.y = (player.JUMP_VELOCITY + jump_move_boost * player.power.jump_multi) / 2
	
	player.holding_jump = Input.is_action_pressed("jump")

	if Input.is_action_pressed("sprint") && !player.stand_collision.disabled:
		if player.is_on_floor() or player.coyote_timer >= player.coyote_float:
			player.SPEED = player.SPRINT
	
	elif !player.stand_collision.disabled:
		player.SPEED = player.WALK
		player.PLAYER_COLLIDER = player.stand_collision
	else:
		player.SPEED = player.CRAWL
		player.PLAYER_COLLIDER = player.crawl_collision
	
	if Input.is_action_pressed("crawl") && player.SPEED != player.SPRINT:
		player.stand_collision.disabled = true
	elif !player.head_detection.is_colliding():
		player.stand_collision.disabled = false
	
	if player.floor_detection.is_colliding():
		player.ACCEL = player.ICE_ACCEL
		player.DECCEL = player.ICE_DECCEL
	else:
		player.ACCEL = player.DEFAULT_ACCEL
		player.DECCEL = player.DEFAULT_ACCEL
	
	if !player.direction && player.is_on_floor() && !player.edge_detection.is_colliding() && player.velocity.length() >= 1.0:
		if !player.floor_detection.is_colliding():
			player.DECCEL = player.DECCEL * 3
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	player.direction = player.direction.rotated(Vector3.UP, player.camera.camera.rotation.y)
	
	var friction : Vector2
	friction.x = (player.ACCEL if player.direction.x else player.DECCEL) * delta
	friction.y = (player.ACCEL if player.direction.z else player.DECCEL) * delta
	
	if player.direction:
		player.velocity.x = lerp(player.velocity.x, player.direction.x * player.SPEED, friction.x)
		player.velocity.z = lerp(player.velocity.z, player.direction.z * player.SPEED, friction.y)
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
