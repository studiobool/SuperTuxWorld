extends CharacterBody3D

var direction: Vector3
const WALK = 6.25
const SPRINT = 13.0
const CRAWL = 3.25
var SPEED = 6.0
var ACCEL = 3.75
var DECCEL = 3.75
var JUMP_VELOCITY = 12.0
var holding_jump: bool
var if_jumped: bool

@export var player_rotation :float
@export var camera_rotation :Vector2 = Vector2(-22.5, 0)
@onready var camera = $Camera
@onready var model = $Model
@onready var interact = $InteractionSystem
@onready var sfx = $SFX
@onready var stats = $Stats

var move_dir := Vector3.BACK

@onready var stand_collision = $StandCollision
@onready var crawl_collision = $CrawlCollision
@onready var object_collision = $ObjectCollision
@onready var head_detection = $HeadDetection
@onready var floor_detection = $FloorDetection

@export var coyote_time: float = 0.15
@export var coyote_float: float = 0.05
var coyote_timer: float = 0.0

@onready var item_pocket = $HUD/ItemPocket
@onready var safe_timer = $SafeTimer
var temp_safe : bool

func _ready() -> void:
	model.rotation.y = deg_to_rad(player_rotation)
	camera.cam_rot2.x = deg_to_rad(camera_rotation.x)
	camera.cam_rot2.y = deg_to_rad(camera_rotation.y)

func _process(delta: float) -> void:
	if !is_on_floor():
		coyote_timer += delta
	else:
		coyote_timer = 0.0
	
	item_pocket.value = stats.health

func _physics_process(delta: float) -> void:
	object_collision.global_position = interact.marker.global_position
	object_collision.global_rotation = interact.marker.global_rotation
	
	# Add the gravity.
	if not is_on_floor() && coyote_timer >= coyote_float:
		if stand_collision.disabled && velocity.y <= -2:
			velocity += get_gravity() * 7.5 * delta
		else:
			if velocity.y >= -0.5:
				velocity += get_gravity() * 1.5 * delta
			else:
				velocity += get_gravity() * 1.75 * delta
	
	# Handle jump.
	if is_on_floor():
		if_jumped = false
	
	var jump_move_boost = velocity.length() / 1.5
	if Input.is_action_just_pressed("jump") && (is_on_floor() or coyote_timer < coyote_time):
		if velocity.y <= 0.0:
			jump(Vector3(0, JUMP_VELOCITY + jump_move_boost, 0))
			sfx._jump()
			if_jumped = true
	if Input.is_action_just_released("jump") && if_jumped:
		if velocity.y >= (JUMP_VELOCITY + jump_move_boost) / 2:
			velocity.y = (JUMP_VELOCITY + jump_move_boost) / 2
	
	holding_jump = Input.is_action_pressed("jump")

	if Input.is_action_pressed("sprint") && !stand_collision.disabled:
		if is_on_floor() or coyote_timer >= coyote_float:
			SPEED = SPRINT
	
	elif !stand_collision.disabled:
		SPEED = WALK
	else:
		SPEED = CRAWL
	
	if Input.is_action_pressed("crawl") && SPEED != SPRINT:
		stand_collision.disabled = true
	elif !head_detection.is_colliding():
		stand_collision.disabled = false
	
	#if floor_detection.get_collider():
	#	print(floor_detection.get_collider())
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = direction.rotated(Vector3.UP, camera.camera.rotation.y)
	
	var friction : Vector2
	friction.x = (ACCEL if direction.x else DECCEL) * delta
	friction.y = (ACCEL if direction.z else DECCEL) * delta
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, friction.x)
		velocity.z = lerp(velocity.z, direction.z * SPEED, friction.y)
	elif is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, friction.x)
		velocity.z = lerp(velocity.z, 0.0, friction.y)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta)
		velocity.z = lerp(velocity.z, 0.0, delta)
	
	_push_away_rigid_bodies()
	move_and_slide()

func hurt(damage,vector):
	if !temp_safe:
		stats.health -= damage
		jump(vector)
		temp_safe = true
		safe_timer.start()
		sfx._hurt()

func jump(vector):
	velocity += vector

func _push_away_rigid_bodies():
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase to match player velocity in the push direction
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			# Only count velocity towards push dir, away from character
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			# Objects with more mass than us should be harder to push. But doesn't really make sense to push faster than we are going
			const MY_APPROX_MASS_KG = 60.0
			var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			# Optional add: Don't push object at all if it's 4x heavier or more
			if mass_ratio < 0.25:
				continue
			# Don't push object from above/below
			push_dir.y = 0
			# 5.0 is a magic number, adjust to your needs
			var push_force = mass_ratio * 5.0
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)

func safe_timeout() -> void:
	temp_safe = false
