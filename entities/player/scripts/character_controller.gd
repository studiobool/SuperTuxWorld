class_name Player
extends CharacterBody3D

# Movement
var current_speed : float = 6.0
var acceleration : float = 5
var friction : float = 7.5
var skid_friction : float = 14.0
var is_crouching : bool = false
var is_crawling : bool  = false

# Coyote time variables
@export var coyote_time: float = 0.15
@export var coyote_float: float = 0.0525
var coyote_timer: float = 0.0

# Movement constants
const crawl_speed : float = 3.0
const walk_speed : float = 6.0
const sprint_speed : float = 13.0
const jump_velocity : float = 19.5

# Movement onready variables
@onready var stand_collider = $StandCollider
@onready var crouch_collider = $CrouchCollider
@onready var crawl_collider = $CrawlCollider
@onready var floor_detect = $FloorDetect
@onready var crouch_detection = $CrouchDetection
@onready var crawl_detection = $CrawlDetection
@onready var backflip = $Model/Backflip

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

# Camera
@onready var spring_pivot = $SpringPivot
@onready var spring_arm = $SpringPivot/SpringArm

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
@export var health = 4.0
@onready var health_bar = $Control/Health

# Coins
@export var coins : int = 0
@onready var coin_counter = $Control/Coins

# Detectors
@onready var jump_detect = $JumpDetect
@onready var stomp_detect = $StompDetect

# SFX
@onready var jump_sound = $JumpSound
@onready var flip_sound = $FlipSound

func _process(delta):
	# Counts the amount of coins on a display text
	coin_counter.text = str(coins)
	health_bar.value = lerp(health_bar.value, health, 10 * delta)
	
	# Sprint logic
	if Input.is_action_pressed("sprint") && !is_crawling:
		current_speed = sprint_speed
	elif Input.is_action_pressed("crouch") && !is_crawling && is_on_floor():
		current_speed = crawl_speed
	elif !is_crawling:
		current_speed = walk_speed
	
	# Sliding logic
	if is_crawling:
		floor_max_angle = PI/48
	else:
		floor_max_angle = PI/3
	
	# Handle coyote time (allowing jumps shortly after leaving the ground)
	if !is_on_floor():
		coyote_timer += delta
	else:
		coyote_timer = 0.0
	
	# Crouching
	if Input.is_action_pressed("crouch"):
		if !Input.is_action_pressed("sprint") && is_on_floor():
			is_crawling = true
			current_speed = crawl_speed
			crawl_collider.set_deferred("disabled", false)  
			stand_collider.set_deferred("disabled", true)  
			spring_arm.transform.origin = lerp(spring_arm.transform.origin, crawl_position.transform.origin, MODEL_LERP * delta)
	else:
		if !crawl_detection.is_colliding() && is_on_floor():
			is_crawling = false
			crawl_collider.set_deferred("disabled", true)  
			stand_collider.set_deferred("disabled", false) 
			spring_arm.transform.origin = lerp(spring_arm.transform.origin, stand_position.transform.origin, MODEL_LERP * delta)

func _physics_process(delta):
	# Get the input direction
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_pivot.rotation.y)
	
	# Add the gravity.
	if coyote_timer >= coyote_float:
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") && (is_on_floor() or coyote_timer < coyote_time):
		if !is_crawling && velocity.y <= 0.0:
			jump()
		#else:
		#	jump_sound.play()
		#	flip_sound.play()
		#	velocity += Vector3(_dir.x * 12, direction.y + jump_velocity * 1.5, _dir.z * 12)
	
	if Input.is_action_just_released("jump") && velocity.y > jump_velocity / 2:
		if !is_crawling:
			velocity.y = jump_velocity / 2
	
	movement(direction, delta)
	
	if velocity.x || velocity.z:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(velocity.x, velocity.z), LERP_VAL)
	
	move_and_slide()
	
	animate(direction)

func movement(direction, delta):
	# Handle the movement/deceleration.
	var is_skidding = false
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * current_speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * current_speed, acceleration * delta)
			# Check for skidding condition
			if velocity.length() > current_speed:
				is_skidding = true
		else:
			velocity.x = lerp(velocity.x, 0.0, friction * delta)
			velocity.z = lerp(velocity.z, 0.0, friction * delta)
	else:
		if direction:
			velocity.x = lerp(velocity.x, direction.x * current_speed, acceleration / 2.0 * delta)
			velocity.z = lerp(velocity.z, direction.z * current_speed, acceleration / 2.0 * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, friction / 4 * delta)
			velocity.z = lerp(velocity.z, 0.0, friction / 4 * delta)
	if is_skidding:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
		velocity.z = lerp(velocity.z, 0.0, friction * delta)

func animate(direction):
	anim_tree.set("parameters/conditions/idle", velocity.length() <= 1.5 && is_on_floor())
	anim_tree.set("parameters/conditions/fall", !is_on_floor() && velocity.y > 0.01)
	anim_tree.set("parameters/conditions/walk", velocity.length() >= 1.5 && velocity.length() <= 8.0 && is_on_floor())
	anim_tree.set("parameters/conditions/run", velocity.length() >= 8.0 && is_on_floor())

func jump():
	if !is_crawling:
		jump_sound.play()
		velocity.y = jump_velocity

func _on_stomp_detect_body_entered(body):
	if !velocity.y == 0:
		if body.is_in_group("Enemy") && body.state == 1:
			body.stomp()
			velocity.y = jump_velocity / 1.5

func _on_touch_screen_button_pressed():
	if is_on_floor():
		jump()

func _on_touch_screen_button_released():
	if velocity.y > jump_velocity / 2:
		velocity.y = jump_velocity / 2

func hurt(damage,type,intensity,duration):
	health -= damage
	if type == 0:
		Input.start_joy_vibration(0, intensity, intensity, duration)
