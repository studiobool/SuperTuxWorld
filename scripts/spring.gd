extends Area3D

@export var bounce_power : Vector3 = Vector3(0, 40, 0)
@onready var bounce_sound = $BounceSound


func _on_body_entered(body: Node3D) -> void:
	bounce_sound.play()
	if body is RigidBody3D:
		body.apply_impulse(bounce_power * body.mass)
	if body.has_method("jump"):
		if body.holding_jump:
			body.jump(bounce_power)
		else:
			body.jump(bounce_power / 1.25)
