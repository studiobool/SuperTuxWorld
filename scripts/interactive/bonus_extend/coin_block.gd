extends BonusBlock

@export var coins : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _block_hit(body):
	print(body)
	if coins >= 1:
		body.stats.coins += 1
		coins -= 1
