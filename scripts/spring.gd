extends Area3D

@export var bounce_power : Vector3 = Vector3(0, 100, 0)
@onready var bounce_sound = $BounceSound


func _on_body_entered(body: Node3D) -> void:
	bounce_sound.play()
	if body is RigidBody3D:
		body.apply_central_impulse(bounce_power*1.1)
	if body.has_method("jump"):
		body.jump(Vector3(0, bounce_power.y / 3.5, 0))
		# If entity is holding jump, this adds an extra boost
		if body.holding_jump:
			body.jump(Vector3(0, bounce_power.y / 10.5, 0))
