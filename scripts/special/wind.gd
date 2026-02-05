extends Area3D

@export var wind : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for a in get_overlapping_bodies():
		if a is RigidBody3D:
			a.apply_central_impulse(wind)
		if a is CharacterBody3D:
			if a.is_on_floor():
				a.velocity += wind / 8
			else:
				a.velocity += wind / 4
