class_name Player
extends CharacterBody3D

# Movement
var current_speed : float = 6
var acceleration : float = 5
var friction : float = 10
var skid_friction : float = 14
var is_crouching : bool
var is_crawling : bool

# Coyote time variables
@export var coyote_time: float = 0.2
@export var coyote_float: float = 0.04
var coyote_timer: float = 0.0

# Movement constants
const crawl_speed : float = 3
const walk_speed : float = 5
const sprint_speed : float = 9
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
#@onready var crouch_position = $SpringPivot/Crouching
@onready var crawl_position = $SpringPivot/Crawling

# Model
@export var model : Node3D
@export var anim_tree : AnimationTree
const LERP_VAL = .125
const MODEL_LERP = 8

# Health
@export var health : float = 4
@onready var health_bar = $Control/Health

# Coins
@export var coins : int = 0
@onready var coin_counter = $Control/Coins

# Fireball
@onready var fireball_counter  = $Control/Fireballs

# Detectors
@onready var jump_detect = $JumpDetect
@onready var stomp_detect = $StompDetect

# SFX
@onready var jump_sound = $JumpSound
@onready var flip_sound = $FlipSound

# Stomp
var is_stomp : bool

func _ready():
	pass

func _process(delta):
	# Counts the amount of coins on a display text
	coin_counter.text = str(coins)
	health_bar.value = lerp(health_bar.value, health, 10 * delta)
	#fireball_counter.text = str(is_stomp)
	
	# Sprint logic
	if Input.is_action_pressed("sprint") && !is_crawling:
		current_speed = sprint_speed
	elif Input.is_action_pressed("crouch") && !is_crawling && is_on_floor():
		current_speed = crawl_speed
	elif !is_crawling:
		current_speed = walk_speed
	
	# Sliding logic
	if is_crawling:
		floor_stop_on_slope = false
		floor_max_angle = PI/48
		floor_snap_length = 0.0
	else:
		floor_stop_on_slope = true
		floor_max_angle = PI/4
		floor_snap_length = 0.1
	
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
	
	if !GlobalManager.is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# Get the input direction
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_pivot.rotation.y)
	
	# Add the gravity.
	if !is_on_floor() && coyote_timer >= coyote_float:
		if !floor_detect.is_colliding() && Input.is_action_pressed("crouch"):
			velocity.y -= (gravity * 1.5) * delta
			is_stomp = true
		else:
			velocity.y -= gravity * delta
			is_stomp = false
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") && (is_on_floor() or coyote_timer < coyote_time):
		if !is_crawling && velocity.y <= 0.0:
			jump()
		#else:
		#	jump_sound.play()
			#flip_sound.play()
			#velocity += Vector3(_dir.x * 12, direction.y + jump_velocity * 1.5, _dir.z * 12)
	
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
	if direction && is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * current_speed, 15 * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, 15 * delta)
	elif is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, 15 * delta)
		velocity.z = lerp(velocity.z, 0.0, 15 * delta)
	elif direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, 5 * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, 5 * delta)

func animate(direction):
	anim_tree.set("parameters/conditions/idle", !is_crawling && velocity.length() <= 1.5 && is_on_floor())
	anim_tree.set("parameters/conditions/fall", !is_on_floor() && velocity.y > 0.01)
	anim_tree.set("parameters/conditions/walk", !is_crawling && velocity.length() >= 1.5 && velocity.length() <= 8.0 && is_on_floor())
	anim_tree.set("parameters/conditions/run", velocity.length() >= 8.0 && is_on_floor())
	anim_tree.set("parameters/conditions/crawl", is_crawling)

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

func align_with_y(xform, new_y): 
	xform.basis.y = new_y 
	xform.basis.x = -xform.basis.z.cross(new_y) 
	xform.basis = xform.basis.orthonormalized() 
	return xform
