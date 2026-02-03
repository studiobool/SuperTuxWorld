@tool
class_name CoinBlock extends BonusBlock

@export var coins : int = 1
@onready var sound = $CoinSound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_apply_material()
	if coins >= 1:
		is_usable = true
	else:
		is_usable = false

func is_hit(body, _hit):
	if is_usable:
		sound.play()
		body.stats.coins += 1
		coins -= 1
