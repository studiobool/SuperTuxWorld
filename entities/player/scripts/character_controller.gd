extends CharacterBody3D

# Movement
var SPEED = 6.0
var is_crouching = false
var is_crawling = false
const CRAWL_SPEED = 2.5
const CROUCH_SPEED = 4.0
const WALK_SPEED = 5.5
const SPRINT_SPEED = 11.0
const JUMP_VELOCITY = 16.5
@onready var stand_collider = $StandCollider
@onready var crouch_collider = $CrouchCollider
@onready var crawl_collider = $CrawlCollider
@onready var coyote = $Coyote
@onready var jump_buffer = $JumpBuffer
@onready var crouch_detection = $CrouchDetection
@onready var crawl_detection = $CrawlDetection

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 3.5

# Camera
@onready var spring_pivot = $SpringPivot
@onready var spring_arm = $SpringPivot/SpringArm
@export var cam_sensitivity = 0.0035
@export var min_zoom = 2.0
@export var max_zoom = 8.0
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

# Coins
var coins = 0
@onready var coin_counter = $Control/ColorRect/Label

# Detectors
@onready var jump_detect = $JumpDetect
@onready var stomp_detect = $StompDetect

# SFX
@onready var jump_sound = $JumpSound

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	
	# Sprint logic
	if Input.is_action_pressed("sprint"):
		if is_crouching == false && is_crawling == false:
			if is_crawling == true && is_on_floor():
				SPEED = CRAWL_SPEED
			else:
				SPEED = SPRINT_SPEED
	elif Input.is_action_pressed("crouch"):
		if is_crawling == false && is_on_floor():
			SPEED = CROUCH_SPEED
	elif is_crouching == false && is_crawling == false:
		SPEED = WALK_SPEED
	
	# Sliding logic
	if SPEED == CROUCH_SPEED || SPEED == CRAWL_SPEED:
		floor_max_angle = 0
	else:
		floor_max_angle = 1
	
	# Crouching
	if Input.is_action_pressed("crouch"):
		if Input.is_action_pressed("sprint"):
			is_crawling = true
			is_crouching = false
			SPEED = CRAWL_SPEED
			crawl_collider.set_deferred("disabled", false)  
			crouch_collider.set_deferred("disabled", true)  
			stand_collider.set_deferred("disabled", true)  
			if is_on_floor():
				spring_arm.transform.origin = lerp(spring_arm.transform.origin, crawl_position.transform.origin, MODEL_LERP * delta)
				model.rotation.x = lerp(model.rotation.x, float(1.125), MODEL_LERP * delta)
		else:
			if !crawl_detection.is_colliding():
				is_crawling = false
				is_crouching = true
				SPEED = CROUCH_SPEED
				crawl_collider.set_deferred("disabled", true)  
				crouch_collider.set_deferred("disabled", false)  
				stand_collider.set_deferred("disabled", true)  
				if is_on_floor():
					spring_arm.transform.origin = lerp(spring_arm.transform.origin, crouch_position.transform.origin, MODEL_LERP * delta)
					model.rotation.x = lerp(model.rotation.x, float(0.75), MODEL_LERP * delta)
	else:
		if !crawl_detection.is_colliding():
			if !crouch_detection.is_colliding():
				is_crawling = false
				is_crouching = false
				crawl_collider.set_deferred("disabled", true)  
				crouch_collider.set_deferred("disabled", true)  
				stand_collider.set_deferred("disabled", false)  
				spring_arm.transform.origin = lerp(spring_arm.transform.origin, stand_position.transform.origin, MODEL_LERP * delta)
				model.rotation.x = lerp(model.rotation.x, float(0), MODEL_LERP * delta)
	

func _physics_process(delta):
	# Camera zoom
	_zoom_level = clamp(_zoom_level, min_zoom, max_zoom)
	spring_arm.spring_length = lerp(spring_arm.spring_length, _zoom_level, zoom_duration * delta)
	
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") && (is_on_floor() || !coyote.is_stopped()):
		coyote.stop()
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
	elif Input.is_action_just_pressed("jump") && !is_on_floor():
		jump_buffer.start()
	if Input.is_action_just_released("jump") && velocity.y > JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2
	
	# Get the input direction && handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_pivot.rotation.y)
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 11.5)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 11.5)
			model.rotation.y = lerp_angle(model.rotation.y, atan2(velocity.x, velocity.z), LERP_VAL)
		else:
			if SPEED == WALK_SPEED:
				velocity.x = lerp(velocity.x, 0.0, delta * 14.0)
				velocity.z = lerp(velocity.z, 0.0, delta * 14.0)
			elif SPEED == SPRINT_SPEED:
				velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
				velocity.z = lerp(velocity.z, 0.0, delta * 7.0)
			elif !is_on_floor():
				velocity.x = lerp(velocity.x, 0.0, delta * 4.5)
				velocity.z = lerp(velocity.z, 0.0, delta * 4.5)
			else:
				velocity.x = lerp(velocity.x, 0.0, delta * 28.0)
				velocity.z = lerp(velocity.z, 0.0, delta * 28.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.25)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.25)
		if direction:
			model.rotation.y = lerp_angle(model.rotation.y, atan2(velocity.x, velocity.z), LERP_VAL)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		coyote.start()
	if is_on_floor() && !jump_buffer.is_stopped():
		jump_buffer.stop()
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
	
	anim_tree.set("parameters/conditions/idle", !direction && is_on_floor())
	anim_tree.set("parameters/conditions/fall", !is_on_floor())
	anim_tree.set("parameters/conditions/walk", direction && is_on_floor() && SPEED == WALK_SPEED)
	anim_tree.set("parameters/conditions/run", direction && is_on_floor() && SPEED == SPRINT_SPEED)
	

func _on_stomp_detect_body_entered(body):
	if !is_on_floor():
		if body.is_in_group("Enemy"):
			body.dead()
			velocity.y = JUMP_VELOCITY / 1.5
