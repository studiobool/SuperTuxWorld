@tool
extends BonusBlock

var coins : int = 1
const exploding_coins = preload("res://entities/interactive/exploding_coins.tscn")
@export var mesh : MeshInstance3D
@export var empty_mat : StandardMaterial3D
@export var full_mat : StandardMaterial3D
@onready var sound = $CoinSound
@onready var animation = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_apply_material()

func _apply_material() -> void:
	if coins:
		mesh.set_surface_override_material(0, full_mat)
	else:
		mesh.set_surface_override_material(0, empty_mat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_apply_material()

func _block_hit(body, hit):
	if coins:
		var instance = exploding_coins.instantiate()
		if hit == "below":
			animation.play("hit_below")
			instance.position.y = 1.0
		elif hit == "above":
			animation.play("hit_above")
			instance.position.y = -1.0
		sound.play()
		add_child(instance)
		coins -= 1
