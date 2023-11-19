extends Node3D

func _physics_process(delta):
	rotate_y(delta * 0.25)
