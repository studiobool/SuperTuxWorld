@tool
extends BonusBlock

@export var coins : int = 1
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
	print(body)
	if coins >= 1:
		if hit == "below":
			animation.play("hit_below")
		elif hit == "above":
			animation.play("hit_above")
		sound.play()
		body.stats.coins += 1
		coins -= 1
