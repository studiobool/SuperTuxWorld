extends CharacterBody3D

@onready var audio = $AudioStreamPlayer3D
@export var SPEED = 5.0
@export var DAMAGE = 1.0
const LERP_VAL = .125
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 3

var chase = false
var state = 1
var player = null

@onready var agent = $NavigationAgent3D
@onready var anim_tree = $snow_walker/AnimationTree
@onready var logic = $Logic

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()

func _process(_delta):
	anim_tree.set("parameters/conditions/move", chase)
	anim_tree.set("parameters/conditions/idle", !chase)
	
	velocity = Vector3.ZERO
	if chase == true:
		agent.set_target_position(player.global_transform.origin)
		var next_point = agent.get_next_path_position()
		velocity = (next_point - global_transform.origin).normalized() * SPEED
		rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), LERP_VAL)

func _on_vision_detection_body_entered(body):
	if body.is_in_group("Player") && chase == false && state == 1:
		player = body
		chase = true
		print("hola")

func _on_chase_detection_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		chase = false
		print("adios")

func _on_player_detection_body_entered(body):
	if body.is_in_group("Player") && state == 1:
		var direction = (body.transform.origin - global_transform.origin).normalized()
		body.velocity += Vector3(direction.x * 32, direction.y + 8, direction.z * 32)
		body.hurt(DAMAGE,0,1.0,0.35)

func stomp():
	audio.play()
	logic.oof()

func dead():
	#queue_free()
	chase = false
	#logic.ticking = false
	await get_tree().create_timer(0.5).timeout
	queue_free()

