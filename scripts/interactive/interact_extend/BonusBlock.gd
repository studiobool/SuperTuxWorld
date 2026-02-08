@tool
class_name BonusBlock extends InteractBlock

var tween
@export var is_usable: bool = true
@export var mesh: MeshInstance3D
@export var empty_mat: Material
@export var full_mat: Material
@onready var animation = $AnimationPlayer

func _apply_material() -> void:
	if is_usable:
		mesh.set_surface_override_material(0, full_mat)
	else:
		mesh.set_surface_override_material(0, empty_mat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_apply_material()

func _block_hit(body, hit):
	if is_usable:
		if hit == "below":
			animate(Vector3(0, 0.3, 0))
		elif hit == "above":
			animate(Vector3(0, -0.3, 0))
		is_hit(body, hit)

func is_hit(body, hit):
	pass

func animate(pos):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(mesh, "position", pos, 0.02)
	tween.tween_property(mesh, "position", Vector3(0, 0, 0), 0.2)
