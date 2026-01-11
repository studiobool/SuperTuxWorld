extends CharacterBody3D

@onready var camera = $Camera

var direction : Vector3
var SPEED = 5.0
var ACCEL = 4.5
var DECCEL = 2.25
const WALK = 6.25
const SPRINT = 13.0
const JUMP_VELOCITY = 5.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta
	
	if Input.is_action_pressed("sprint"):
		SPEED = SPRINT
	else:
		SPEED = WALK
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = direction.rotated(Vector3.UP, camera.camera.global_rotation.y)
	var friction : Vector2
	friction.x = (ACCEL if direction.x else DECCEL) * delta
	friction.y = (ACCEL if direction.z else DECCEL) * delta
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, friction.x)
		velocity.z = lerp(velocity.z, direction.z * SPEED, friction.y)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction.x)
		velocity.z = lerp(velocity.z, 0.0, friction.y)
	
	# Handle jump.
	var vertical_dir = Input.get_axis("crawl", "jump")
	var vertical_friction = (ACCEL if vertical_dir else DECCEL) * delta
	if vertical_dir:
		velocity.y = lerp(velocity.y, vertical_dir * SPEED, vertical_friction)
	else:
		velocity.y = lerp(velocity.y, 0.0, vertical_friction)
	
	move_and_slide()
