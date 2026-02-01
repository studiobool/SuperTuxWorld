extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for a in get_overlapping_bodies():
		if a is RigidBody3D:
			var force = (a.global_position - global_position).normalized()
			a.apply_central_impulse(force * 8)
