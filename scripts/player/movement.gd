class_name Player extends StairsCharacterBody3D

# Movement constants
const WALK = 6.5
const SPRINT = 13.5
const CRAWL = 3.25
const DEFAULT_ACCEL = 3.75
const ICE_ACCEL = 1.25
const ICE_DECEL = 0.75
const MIN_POUND_THRESHOLD := -18.0

# Movement stuff
var direction: Vector3
var move_dir:= Vector3.BACK
var speed: float
var acceleration: float = 3.75
var deceleration: float = 3.75
var jump_velocity: float = 18.0

# Movement booleans
var is_sprinting : bool
var holding_jump: bool
var if_jumped: bool
var if_pound: bool
var has_pounded_floor: bool

# Ready variables
@export var player_rotation: float
@export var camera_rotation: Vector2 = Vector2(-22.5, 0)

# Nodes
@onready var camera = $Camera
@onready var model = $Model
@onready var interact = $InteractionSystem
@onready var sfx = $SFX
@onready var stats = $Stats
@onready var power = $Powerup

# Collision nodes
@onready var stand_collision = $StandCollision
@onready var crawl_collision = $CrawlCollision
@onready var water_collision = $WaterCollision

# Detection nodes
@onready var head_detection = $HeadDetection
@onready var floor_detection = $FloorDetection
@onready var edge_detection = $Model/EdgeDetection
@onready var water_detection = $WaterDetection

# Coyote time variables
@export var coyote_time: float = 0.1
@export var coyote_float: float = 0.05
var coyote_timer: float = 0.0

# Jump buffer variables
@export var jump_buffer_time: float = 0.2
var jump_buffer_timer: float = 0.0
var jump_buffer_pressed: bool

# HUD nodes
@onready var item_pocket = $HUD/ItemPocket
@onready var coin_counter = $HUD/Label

# Timer nodes
@onready var safe_timer = $SafeTimer
@onready var pound_timer = $PoundTimer
var temp_safe : bool

var state : String

# Sets player and camera rotation (workaround)
func _ready() -> void:
	model.rotation.y = deg_to_rad(player_rotation)
	camera.cam_rot2.x = deg_to_rad(camera_rotation.x)
	camera.cam_rot2.y = deg_to_rad(camera_rotation.y)

func _process(_delta: float) -> void:
	item_pocket.value = stats.health
	coin_counter.text = str(stats.coins)

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
