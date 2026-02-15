extends Area3D

var interval_reached : bool
@export var force_multiplier: float = 24
@export var damage : float = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(.25).timeout
	interval_reached = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !interval_reached:
		for a in get_overlapping_bodies():
			if a is RigidBody3D:
				var force = (a.global_position - global_position).normalized()
				a.apply_central_impulse(force * force_multiplier)
			if a.has_method("hurt"):
				var knockback = (a.global_position - global_position).normalized() * 1.5
				knockback = Vector3(knockback.x, knockback.y * 0.5 + 1.0, knockback.z)
				a.hurt(damage,knockback * force_multiplier)
