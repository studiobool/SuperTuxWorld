class_name ExplodeBonusBlock extends BonusBlock

const exploding_coins = preload("res://entities/interactive/exploding_coins.tscn")
@onready var sound = $CoinSound

func _process(_delta: float) -> void:
	_apply_material()

func is_hit(body, hit):
	if is_usable:
		var instance = exploding_coins.instantiate()
		if hit == "below":
			instance.position.y = 0.5
		elif hit == "above":
			instance.position.y = -0.5
		sound.play()
		add_child(instance)
		is_usable = false
