@tool
class_name BonusBlock extends InteractBlock

@export var is_usable: bool = true
@export var mesh: MeshInstance3D
@export var empty_mat: StandardMaterial3D
@export var full_mat: StandardMaterial3D
@onready var animation = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_apply_material()

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
			animation.play("hit_below")
		elif hit == "above":
			animation.play("hit_above")
		is_hit(body, hit)

func is_hit(body, hit):
	pass
