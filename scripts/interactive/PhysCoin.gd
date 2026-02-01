extends RigidBody3D

@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !mesh.visible:
		collision.disabled = true
		freeze = true
