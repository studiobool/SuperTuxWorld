class_name InteractBlock extends StaticBody3D

const MINIMUM_VELOCITY_LENGTH_THRESHOLD: float = 0.3

func _block_hit(body, hit: String):
	pass

func hit_below(body: Node3D) -> void:
	if body is Player:
		if body.velocity.y >= -1 && !body.state == "Water":
			_block_hit(body, "below")

func hit_above(body: Node3D) -> void:
	if body is Player:
		if body.if_pound && !body.state == "Water":
			_block_hit(body, "above")

func hit_water(body: Node3D) -> void:
	if body is Player:
		if body.state == "Water" && MINIMUM_VELOCITY_LENGTH_THRESHOLD && body.is_sprinting:
			body.sfx._brick()
			_block_hit(body, "water")
