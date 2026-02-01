extends RigidBody3D

var old_vel : float
@onready var sound = $AudioStreamPlayer3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var diff = linear_velocity.y - old_vel
	if diff > 1:
		sound.pitch_scale = randf_range(0.5,1.0)
		sound.play()
	old_vel = linear_velocity.y
