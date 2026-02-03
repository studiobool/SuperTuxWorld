extends Area3D

@export var bounce_power : Vector3 = Vector3(0, 42.5, 0)
@onready var bounce_sound = $BounceSound


func _on_body_entered(body: Node3D) -> void:
	bounce_sound.play()
	if body is RigidBody3D:
		body.apply_impulse(bounce_power * body.mass)
	if body is CharacterBody3D:
		if body is Player:
			body.if_jumped = true
			body.velocity.y = 0
			if body.holding_jump:
				body.jump(bounce_power)
			else:
				body.jump(bounce_power / 1.25)
		else:
			body.jump(bounce_power / 1.25)
