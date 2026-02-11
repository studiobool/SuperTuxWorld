@tool
class_name CoinBlock extends BonusBlock

@export var coins : int = 1
@onready var sound = $CoinSound
const coin_popup = preload("res://entities/effects/coin_popup.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_apply_material()
	if coins >= 1:
		is_usable = true
	else:
		is_usable = false

func is_hit(body, hit):
	if is_usable:
		if hit == "below":
			var instance = coin_popup.instantiate()
			instance.direction = "below"
			add_child(instance)
		elif hit == "above":
			var instance = coin_popup.instantiate()
			instance.direction = "above"
			add_child(instance)
		sound.play()
		body.stats.coins += 1
		coins -= 1
