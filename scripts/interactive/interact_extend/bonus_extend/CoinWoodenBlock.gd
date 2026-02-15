@tool
class_name CoinWoodenBlock extends BonusBlock

@export var coins : int = 5
@export var empty_mesh : Mesh
@export var full_mesh : Mesh
@onready var sound = $CoinSound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_apply_material()
	if coins >= 1:
		is_usable = true
		mesh.mesh = full_mesh
		if mesh.get_surface_override_material(1):
			mesh.set_surface_override_material(1, full_mat)
	else:
		is_usable = false
		mesh.mesh = empty_mesh

func is_hit(body, _hit):
	if is_usable && body is Player:
		sound.play()
		body.stats.coins += 1
		coins -= 1
