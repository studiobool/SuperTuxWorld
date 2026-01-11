extends CharacterBody3D

var target : CharacterBody3D = null
var direction: Vector3
const WALK = 6.25
const SPRINT = 13.0
var SPEED = 6.0
var ACCEL = 3.75
var DECCEL = 3.75

@export var player_rotation :float
@onready var model = $Model
#@onready var sfx = $SFX

var move_dir := Vector3.BACK
var is_alive := true

@onready var stand_collision = $StandCollision
@onready var floor_detection = $FloorDetection

func _ready() -> void:
	model.rotation.y = deg_to_rad(player_rotation)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if stand_collision.disabled && velocity.y <= -2:
			velocity += get_gravity() * 7.5 * delta
		else:
			if velocity.y >= -0.5:
				velocity += get_gravity() * 1.5 * delta
			else:
				velocity += get_gravity() * 1.75 * delta
	
	#if floor_detection.get_collider():
	#	print(floor_detection.get_collider())
	
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
