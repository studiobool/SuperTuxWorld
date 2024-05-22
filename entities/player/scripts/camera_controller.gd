extends Node3D

# Start
@export var cam_rot : Vector2

# Camera
@onready var spring_arm = $SpringArm
var cam_sensitivity : float = 0.00275
var mobile_cam_sensitivity : float = 0.007
var joypad_sensitivity : float = 2.8
var min_zoom : float = 2.0
var max_zoom : float = 16.0
var zoom_factor : float = 0.5
var zoom_duration : float = 5
@export var _zoom_level : float = 6.0
@export var rotation_speed = 120

func _ready():
	spring_arm.rotation.x = cam_rot.x
	rotation.y = cam_rot.y
	spring_arm.spring_length = _zoom_level
	if DisplayServer.is_touchscreen_available():
		cam_sensitivity = mobile_cam_sensitivity

func _unhandled_input(event):
	handle_camera_rotation(event)
	handle_scroll_zoom(event)

func handle_camera_rotation(event):
	if event is InputEventMouseMotion:
		cam_rot.y += -event.relative.x * cam_sensitivity
		cam_rot.x += -event.relative.y * cam_sensitivity

func handle_scroll_zoom(event):
	if event.is_action_pressed("scroll_up"):
		_zoom_level -= zoom_factor
	if event.is_action_pressed("scroll_down"):
		_zoom_level += zoom_factor

func _process(delta):
	if !GlobalManager.is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	handle_camera_zoom(delta)

func handle_camera_zoom(delta):
	if Input.is_action_pressed("zoom_up"):
		_zoom_level -= zoom_factor * delta * 15
	if Input.is_action_pressed("zoom_down"):
		_zoom_level += zoom_factor * delta * 15

func _physics_process(delta):
	# General camera rotation
	spring_arm.rotation.x = lerp_angle(spring_arm.rotation.x, cam_rot.x, 12.5 * delta)
	rotation.y = lerp_angle(rotation.y, cam_rot.y, 12.5 * delta)
	cam_rot.x = clamp(cam_rot.x, -PI/2, PI/3)
	rotation.z = 0.0
	
	# Camera zoom
	_zoom_level = clamp(_zoom_level, min_zoom, max_zoom)
	spring_arm.spring_length = lerp(spring_arm.spring_length, _zoom_level, zoom_duration * delta)
	
	# Joypad camera rotation
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	axis_vector.y = Input.get_action_strength("cam_down") - Input.get_action_strength("cam_up")
	
	cam_rot.y += -axis_vector.x * joypad_sensitivity * delta
	cam_rot.x += -axis_vector.y * joypad_sensitivity * delta

func _on_pause_menu_pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_pause_menu_resume():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
