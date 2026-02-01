class_name InteractBlock extends StaticBody3D

const MINIMUM_VELOCITY_LENGTH_THRESHOLD: float = 0.3

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
		if body.is_on_ceiling() && body.velocity.y >= -1:
			_block_hit(body, "below")

func hit_above(body: Node3D) -> void:
	if body is Player:
		if body.if_pound:
			_block_hit(body, "above")

func hit_water(body: Node3D) -> void:
	if body is Player:
		if body.state == "Water" && MINIMUM_VELOCITY_LENGTH_THRESHOLD && body.is_sprinting:
			body.sfx._brick()
			_block_hit(body, "water")
