extends Node3D

@onready var camera = $Camera
@onready var springarm = $SpringArm3D
@onready var marker = $SpringArm3D/Marker3D
@onready var springpos = $SpringPos
@onready var master = self.get_parent()

var cam_dir = Vector2.ZERO
var cam_rot : Vector3
var cam_rot2 : Vector3
var cam_pos : Vector3
var cam_pos2 : Vector3
var cam_mouse_sens := 0.2
var cam_input_dir := Vector2.ZERO

func _ready() -> void:
	cam_rot2.x = deg_to_rad(-22.5)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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

func _physics_process(delta: float) -> void:
	#cam_rot = camera.get_third_person_rotation()
	#cam_pos = camera.get_follow_offset()
	#camera.global_position = lerp(camera.global_position, marker.global_position, delta * 8)
	springarm.global_position.x = lerp(springarm.global_position.x, global_position.x, delta * 10)
	springarm.global_position.y = lerp(springarm.global_position.y, springpos.global_position.y, delta * 8)
	springarm.global_position.z = lerp(springarm.global_position.z, global_position.z, delta * 10)
	camera.global_position = marker.global_position
	camera.global_rotation = marker.global_rotation
	springarm.rotation = cam_rot
	cam_rot2.x = clampf(cam_rot2.x, deg_to_rad(-85), deg_to_rad(45))
	
	if !master.stand_collision.disabled:
		springpos.position.y = 0.5
	elif master.is_on_floor():
		springpos.position.y = -0.5
	
	cam_dir.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	cam_dir.y = Input.get_action_strength("cam_down") - Input.get_action_strength("cam_up")
	cam_rot2.x += -cam_dir.y * 4 * delta
	cam_rot2.y += -cam_dir.x * 4 * delta
	#cam_rot2.x += -cam_input_dir.y * 4
	#cam_rot2.y += -cam_input_dir.x * 4
	cam_rot.x = lerp_angle(cam_rot.x, cam_rot2.x, delta * 10)
	cam_rot.y = lerp_angle(cam_rot.y, cam_rot2.y, delta * 10)
	#cam_rot.x = cam_rot2.x
	#cam_rot.y = cam_rot2.y
	#cam_pos = lerp(cam_pos, cam_pos2, delta * 8)
	
	#camera.set_third_person_rotation(cam_rot)
	#camera.set_follow_offset(cam_pos)
