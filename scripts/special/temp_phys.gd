extends RigidBody3D

@onready var mesh = $MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(4).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(mesh, "scale", Vector3(), 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)
