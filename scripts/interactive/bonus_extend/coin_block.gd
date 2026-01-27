extends BonusBlock

@export var coins : int = 1
@export var mesh : MeshInstance3D
@export var empty_mat : StandardMaterial3D
@export var full_mat : StandardMaterial3D
@onready var sound = $CoinSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if coins:
		mesh.set_surface_override_material(0, full_mat)
	else:
		mesh.set_surface_override_material(0, empty_mat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !coins:
		mesh.set_surface_override_material(0, empty_mat)

func _block_hit(body):
	print(body)
	if coins >= 1:
		sound.play()
		body.stats.coins += 1
		coins -= 1
