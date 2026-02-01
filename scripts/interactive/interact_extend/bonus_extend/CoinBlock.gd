@tool
class_name CoinBlock extends BonusBlock

@export var coins : int = 1
@onready var sound = $CoinSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_apply_material()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if coins >= 1:
		is_usable = true
	else:
		is_usable = false
		_apply_material()

func is_hit(body, hit):
	if is_usable:
		sound.play()
		body.stats.coins += 1
		coins -= 1
