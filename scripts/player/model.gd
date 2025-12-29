extends Node3D

@onready var master = self.get_parent()
@onready var animtree = $AnimationTree
@onready var state_machine = animtree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if master.direction.length() > 0.125:
		if master.velocity.length() > 0.5 && master.is_on_floor():
			master.move_dir.x = master.velocity.x
			master.move_dir.z = master.velocity.z
		else:
			master.move_dir = master.direction
		var angle := Vector3.BACK.signed_angle_to(-master.move_dir, Vector3.UP)
		rotation.y = lerp_angle(master.model.rotation.y, angle, delta * 12)
	if master.velocity.length() > 0.01 and master.direction.length() > 0.125:
		if master.is_on_floor():
			if master.velocity.length() >= 0.01:
				state_machine.travel("walk")
			if master.velocity.length() >= 7.5:
				state_machine.travel("run")
			if master.stand_collision.disabled:
				state_machine.travel("crawl_walk")
	else:
		if master.is_on_floor():
			if !master.stand_collision.disabled:
				state_machine.travel("idle")
			if master.stand_collision.disabled:
				state_machine.travel("crawl_idle")
	
	if master.velocity.y >= 0.01:
		state_machine.travel("jump")
	
	if master.velocity.y <= -0.01:
		state_machine.travel("fall")
