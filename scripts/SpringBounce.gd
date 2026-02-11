extends Area3D

var tween
@export var bounce_power : float = 42.5
@onready var bounce_sound = $BounceSound
@onready var marker = $Marker3D
@onready var mesh = $StaticBody3D/trampoline

func _on_body_entered(body: Node3D) -> void:
	bounce_sound.play()
	animate(Vector3(1.25, .75, 1.25))
	var force = (marker.global_position - global_position).normalized()
	if body is RigidBody3D:
		body.apply_impulse(force * bounce_power * body.mass)
	if body is CharacterBody3D:
		if body is Player:
			body.velocity.y = 0
			body.if_jumped = true
			if body.holding_jump:
				body.jump(force * bounce_power)
			else:
				body.jump(force * bounce_power / 1.375)
		else:
			body.jump(force * bounce_power / 1.25)

func animate(scale):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(mesh, "scale", scale, 0.015).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(mesh, "scale", Vector3(.75, 1.25, .75), 0.1).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(mesh, "scale", Vector3(1.125, .84375, 1.125), 0.1).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(mesh, "scale", Vector3(1, 1, 1), 0.1).set_trans(Tween.TRANS_SINE)
