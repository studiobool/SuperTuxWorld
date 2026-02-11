extends Area3D

@export var force_multiplier: float = 12

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(.1).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for a in get_overlapping_bodies():
		if a is RigidBody3D:
			var force = (a.global_position - global_position).normalized()
			a.apply_central_impulse(force * force_multiplier)
