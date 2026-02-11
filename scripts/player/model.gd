extends Node3D

@onready var master = self.get_parent()
@onready var animtree = $AnimationTree
@onready var state_machine = animtree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation.y = deg_to_rad(master.player_rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var stand_state = remap(master.velocity.length(), 0.0, master.SPRINT, 0.0, 1.0)
	animtree["parameters/stand/blend_position"] = stand_state
	
	var crawl_state = remap(master.velocity.length(), 0.0, master.CRAWL, 0.0, 0.1)
	animtree["parameters/crawl/blend_position"] = crawl_state
	
	var swim_state = remap(master.velocity.length(), 0.0, master.SPRINT, 0.0, 0.2)
	animtree["parameters/swim/blend_position"] = swim_state
	
	if master.state == "Ground":
		rotation.x = lerp(master.model.rotation.x, 0.0, delta * 12)
		if master.direction.length() > 0.125:
			if master.velocity.length() > 0.5 && master.is_on_floor():
				master.move_dir = master.velocity
			else:
				master.move_dir = master.direction
			var angle := Vector3.BACK.signed_angle_to(-master.move_dir, Vector3.UP)
			rotation.y = lerp_angle(master.model.rotation.y, angle, delta * 12)
		
		if master.is_on_floor():
			if !master.stand_collision.disabled:
				state_machine.travel("stand")
			else:
				state_machine.travel("crawl")
		
		if (master.if_jumped or master.holding_jump) && master.velocity.y >= 0.01:
			state_machine.travel("jump")
		
		if master.velocity.y <= -0.01:
			state_machine.travel("fall")
	
	if master.state == "Water":
		state_machine.travel("swim")
		if master.direction.length() > 0.125:
			if master.velocity.length() > 0.1:
				master.move_dir.x = master.velocity.x
				master.move_dir.z = master.velocity.z
			var angle := Vector3.BACK.signed_angle_to(-master.move_dir, Vector3.UP)
			rotation.y = lerp_angle(master.model.rotation.y, angle, delta * 12)
			rotation.x = lerp_angle(master.model.rotation.x, master.direction.y * 1.5, delta * 4)
