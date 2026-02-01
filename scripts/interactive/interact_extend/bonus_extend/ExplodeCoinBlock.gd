@tool
class_name ExplodeBonusBlock extends BonusBlock

const exploding_coins = preload("res://entities/interactive/exploding_coins.tscn")
@onready var sound = $CoinSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_apply_material()

func is_hit(body, hit):
	if is_usable:
		var instance = exploding_coins.instantiate()
		if hit == "below":
			instance.position.y = 1.0
		elif hit == "above":
			instance.position.y = -1.0
		sound.play()
		add_child(instance)
		is_usable = false
		_apply_material()
