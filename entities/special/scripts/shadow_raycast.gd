extends RayCast3D

@export var shadow_mesh : MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	shadow_mesh.set_as_top_level(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var p = get_collision_point()
	var n = get_collision_normal()
	var xform = align_with_y(global_transform, n)
	shadow_mesh.global_transform = xform
	shadow_mesh.global_position = p

func align_with_y(xform, new_y): 
	xform.basis.y = new_y 
	xform.basis.x = -xform.basis.z.cross(new_y) 
	xform.basis = xform.basis.orthonormalized() 
	return xform
