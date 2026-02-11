extends Node3D

@onready var camera = $Camera
@onready var shake = $Camera/Shake
@onready var springarm = $SpringArm3D
@onready var marker = $SpringArm3D/Marker3D
@onready var springpos = $SpringPos
@onready var pos_min = $SpringPos/SpringPosMin
@onready var pos_max = $SpringPos/SpringPosMax
@onready var underwater = $Control
@onready var master = self.get_parent()

var cam_dir = Vector2.ZERO
var cam_rot : Vector3
var cam_rot2 : Vector3
var cam_pos : Vector3
var cam_pos2 : Vector3
var cam_mouse_sens := 0.2
var cam_input_dir := Vector2.ZERO

var min_zoom : float = 5.0
var max_zoom : float = 15.0
var zoom_factor : float = 1.0
var zoom_duration : float = 5
var zoom_level : float = 5.0

func _ready() -> void:
	cam_rot2.x = deg_to_rad(master.camera_rotation.x)
	cam_rot2.y = deg_to_rad(master.camera_rotation.y)
	zoom_level = master.camera_zoom
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	top_level = true
	springarm.top_level = true

func _unhandled_input(event: InputEvent) -> void:
	var cam_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if cam_motion:
		cam_input_dir = event.relative * cam_mouse_sens
		cam_rot2.x += -cam_input_dir.y * .02
		cam_rot2.y += -cam_input_dir.x * .02
	
	if event.is_action_pressed("zoom_close"):
		zoom_level -= zoom_factor
	if event.is_action_pressed("zoom_far"):
		zoom_level += zoom_factor

func _process(_delta: float) -> void:
	camera.global_position = marker.global_position
	camera.global_rotation = marker.global_rotation
	
	if !master.stand_collision.disabled or !master.is_on_floor():
		springpos.position.y = 0.5
	elif master.is_on_floor() or master.state == "Water":
		springpos.position.y = -0.5

func _physics_process(delta: float) -> void:
	global_position = master.global_position + Vector3(0, 1, 0)
	zoom_level = clamp(zoom_level, min_zoom, max_zoom)
	
	springarm.rotation = cam_rot
	springarm.global_position.x = lerp(springarm.global_position.x, global_position.x, delta * 12)
	springarm.global_position.y = lerp(springarm.global_position.y, springpos.global_position.y, delta * 12)
	springarm.global_position.y = clamp(springarm.global_position.y, pos_min.global_position.y, pos_max.global_position.y)
	springarm.global_position.z = lerp(springarm.global_position.z, global_position.z, delta * 12)
	
	springarm.spring_length = lerp(springarm.spring_length, zoom_level, zoom_duration * delta)
	
	cam_dir.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	cam_dir.y = Input.get_action_strength("cam_down") - Input.get_action_strength("cam_up")
	cam_rot2.x += -cam_dir.y * 4 * delta
	cam_rot2.x = clampf(cam_rot2.x, deg_to_rad(-90), deg_to_rad(45))
	cam_rot2.y += -cam_dir.x * 4 * delta
	cam_rot.x = lerp_angle(cam_rot.x, cam_rot2.x, delta * 12)
	cam_rot.y = lerp_angle(cam_rot.y, cam_rot2.y, delta * 12)

func emerge(_area: Area3D) -> void:
	underwater.visible = false

func submerge(_area: Area3D) -> void:
	underwater.visible = true
