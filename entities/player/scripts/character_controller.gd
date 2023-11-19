extends CharacterBody3D

# Start
@export var cam_rot = 0.0

# Movement
var SPEED = 6.0
var is_crouching = false
var is_crawling = false
const CRAWL_SPEED = 3.0
const CROUCH_SPEED = 4.0
const WALK_SPEED = 5.5
const SPRINT_SPEED = 11.0
const JUMP_VELOCITY = 16.5

# Movement onready variables
@onready var stand_collider = $StandCollider
@onready var crouch_collider = $CrouchCollider
@onready var crawl_collider = $CrawlCollider
@onready var floor_detect = $FloorDetect
@onready var coyote = $Coyote
@onready var jump_buffer = $JumpBuffer
@onready var crouch_detection = $CrouchDetection
@onready var crawl_detection = $CrawlDetection
@onready var backflip = $Model/Backflip

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 3.5

# Camera
@onready var spring_pivot = $SpringPivot
@onready var spring_arm = $SpringPivot/SpringArm
@export var cam_sensitivity = 0.0035
@export var mobile_cam_sensitivity = 0.0070
@export var joypad_sensitivity = 0.014
@export var min_zoom = 2.0
@export var max_zoom = 16.0
@export var zoom_factor = 0.5
@export var zoom_duration = 5
var _zoom_level = 4.0

# Camera position
@onready var stand_position = $SpringPivot/Standing
@onready var crouch_position = $SpringPivot/Crouching
@onready var crawl_position = $SpringPivot/Crawling

# Model
@onready var model = $Model
@onready var anim_tree = $Model/AnimationTree
const LERP_VAL = .125
const MODEL_LERP = 8

# Health
var health = 4.0
@onready var health_bar = $Control/Health

# Coins
var coins = 0
@onready var coin_counter = $Control/Coins

# Detectors
@onready var jump_detect = $JumpDetect
@onready var stomp_detect = $StompDetect

# SFX
@onready var jump_sound = $JumpSound
@onready var flip_sound = $FlipSound

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spring_pivot.rotation.y = cam_rot
	if DisplayServer.is_touchscreen_available():
		cam_sensitivity = mobile_cam_sensitivity

func _unhandled_input(event):
	# Camera rotation
	if event is InputEventMouseMotion:
		spring_pivot.rotate_y(-event.relative.x * cam_sensitivity)
		spring_arm.rotate_x(-event.relative.y * cam_sensitivity)
	
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/2.5, PI/4)
	
	# Camera zoom
	if event.is_action_pressed("scroll_up"):
		_zoom_level -= zoom_factor
	if event.is_action_pressed("scroll_down"):
		_zoom_level += zoom_factor
	

func _process(delta):
	# Counts the amount of coins on a display text
	coin_counter.text = str(coins)
	health_bar.value = lerp(health_bar.value, health, 10 * delta)
	
	# Sprint logic
	if Input.is_action_pressed("sprint") && is_crawling == false:
		SPEED = SPRINT_SPEED
	elif Input.is_action_pressed("crouch"):
		if is_crawling == false && is_on_floor():
			SPEED = CRAWL_SPEED
	elif is_crawling == false:
		SPEED = WALK_SPEED
	
	# Sliding logic
	if is_crawling:
		floor_max_angle = 0
	else:
		floor_max_angle = 1
	
	# Crouching
	if Input.is_action_pressed("crouch"):
		if !Input.is_action_pressed("sprint") && is_on_floor():
			is_crawling = true
			SPEED = CRAWL_SPEED
			crawl_collider.set_deferred("disabled", false)  
			stand_collider.set_deferred("disabled", true)  
			spring_arm.transform.origin = lerp(spring_arm.transform.origin, crawl_position.transform.origin, MODEL_LERP * delta)
			#model.rotation.x = lerp(model.rotation.x, float(1.125), MODEL_LERP * delta)
	else:
		if !crawl_detection.is_colliding() && is_on_floor():
			is_crawling = false
			crawl_collider.set_deferred("disabled", true)  
			stand_collider.set_deferred("disabled", false) 
			spring_arm.transform.origin = lerp(spring_arm.transform.origin, stand_position.transform.origin, MODEL_LERP * delta)
			#model.rotation.x = lerp(model.rotation.x, float(0), MODEL_LERP * delta)

func _physics_process(delta):
	# Get the input direction
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#var _dir = (transform.origin - backflip.global_transform.origin).normalized()
	direction = direction.rotated(Vector3.UP, spring_pivot.rotation.y)
	
	# Joypad camera rotation
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	axis_vector.y = Input.get_action_strength("cam_down") - Input.get_action_strength("cam_up")
	
	spring_pivot.rotate_y(-axis_vector.x * joypad_sensitivity)
	spring_arm.rotate_x(-axis_vector.y * joypad_sensitivity)
	
	# Camera zoom= direction.rotated(Vector3.UP, spring_pivot.rotation.y)
	_zoom_level = clamp(_zoom_level, min_zoom, max_zoom)
	spring_arm.spring_length = lerp(spring_arm.spring_length, _zoom_level, zoom_duration * delta)
	
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") && (is_on_floor() || !coyote.is_stopped()):
		coyote.stop()
		if !is_crawling:
			jump()
		#else:
		#	jump_sound.play()
		#	flip_sound.play()
		#	velocity += Vector3(_dir.x * 12, direction.y + JUMP_VELOCITY * 1.5, _dir.z * 12)
	elif Input.is_action_just_pressed("jump") && !is_on_floor():
		jump_buffer.start()
	
	if Input.is_action_just_released("jump") && velocity.y > JUMP_VELOCITY / 2:
		if !is_crawling:
			velocity.y = JUMP_VELOCITY / 2
	
	# Handle the movement/deceleration.
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 10.0)
			model.rotation.y = lerp_angle(model.rotation.y, atan2(velocity.x, velocity.z), LERP_VAL)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 7.5)
			velocity.z = lerp(velocity.z, 0.0, delta * 7.5)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.5)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.5)
		if direction:
			model.rotation.y = lerp_angle(model.rotation.y, atan2(velocity.x, velocity.z), LERP_VAL)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		coyote.start()
	if is_on_floor() && !jump_buffer.is_stopped():
		jump_buffer.stop()
		jump()
	
	anim_tree.set("parameters/conditions/idle", !direction && is_on_floor())
	anim_tree.set("parameters/conditions/fall", !is_on_floor())
	anim_tree.set("parameters/conditions/walk", direction && is_on_floor() && SPEED == WALK_SPEED)
	anim_tree.set("parameters/conditions/run", direction && is_on_floor() && SPEED == SPRINT_SPEED)
	

func jump():
	if !is_crawling:
		jump_sound.play()
		velocity.y = JUMP_VELOCITY

func _on_stomp_detect_body_entered(body):
	if !velocity.y == 0:
		if body.is_in_group("Enemy") && body.state == 1:
			body.stomp()
			velocity.y = JUMP_VELOCITY / 1.5

func _on_touch_screen_button_pressed():
	if is_on_floor():
		jump()

func _on_touch_screen_button_released():
	if velocity.y > JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
