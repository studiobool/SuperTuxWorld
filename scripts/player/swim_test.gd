extends CharacterBody3D

@onready var camera = $Camera

var direction : Vector3
var SPEED = 5.0
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
	
	# Handle jump.
	if Input.is_action_pressed("jump"):
		velocity.y = SPEED
	elif Input.is_action_pressed("crawl"):
		velocity.y = -SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = direction.rotated(Vector3.UP, camera.camera.global_rotation.y)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
