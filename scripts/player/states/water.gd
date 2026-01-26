extends PlayerState

@export var state_name : String

func enter(previous_state_path: String, data := {}) -> void:
	player.state = state_name
	player.sfx._splash()

func physics_update(delta: float) -> void:
	player.stand_collision.disabled = true
	player.PLAYER_COLLIDER = player.crawl_collision
	
	if Input.is_action_pressed("sprint"):
		player.SPEED = player.SPRINT * 1.25
	else:
		player.SPEED = player.WALK * 1.25
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	player.direction = player.direction.rotated(Vector3.UP, player.camera.camera.global_rotation.y)
	var friction : Vector2
	friction.x = (player.ACCEL if player.direction.x else player.DECCEL) * delta
	friction.y = (player.ACCEL if player.direction.z else player.DECCEL) * delta
	if player.direction:
		player.velocity.x = lerp(player.velocity.x, player.direction.x * player.SPEED, friction.x)
		player.velocity.z = lerp(player.velocity.z, player.direction.z * player.SPEED, friction.y)
	else:
		player.velocity.x = lerp(player.velocity.x, 0.0, friction.x)
		player.velocity.z = lerp(player.velocity.z, 0.0, friction.y)
	
	# Handle jump.
	player.direction.y = Input.get_axis("crawl", "jump")
	var vertical_friction = (player.ACCEL if player.direction.y else player.DECCEL) * delta
	if player.direction.y:
		player.velocity.y = lerp(player.velocity.y, player.direction.y * player.SPEED, vertical_friction)
	else:
		player.velocity.y = lerp(player.velocity.y, 0.0, vertical_friction)
	
	player._push_away_rigid_bodies()
	#player.move_and_slide()
	
	if !player.water_detection.is_colliding():
		if player.velocity.length() >= 0.0:
			var boost = player.velocity / 2
			player.jump(boost)
		finished.emit(GROUND)
