class_name BonusBlock extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _block_hit(body, hit: String):
	pass

func hit_below(body: Node3D) -> void:
	if body is Player:
		if body.is_on_ceiling():
			_block_hit(body, "below")

func hit_above(body: Node3D) -> void:
	if body is Player:
		if body.if_pound:
			_block_hit(body, "above")

func hit_water(body: Node3D) -> void:
	if body is Player:
		if body.state == "Water" && body.velocity.length() >= 0.2 && body.is_sprinting:
			print("w")
			body.sfx._bricK()
			_block_hit(body, "water")
