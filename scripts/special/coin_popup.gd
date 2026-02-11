extends Node3D

var tween
var direction : String
@onready var mesh = $MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tween = create_tween()
	if direction == "below":
		tween.tween_property(mesh, "position", Vector3(0, 2, 0), 0.175).set_trans(Tween.TRANS_SINE)
		tween.tween_property(mesh, "position", Vector3(0, 1.5, 0), 0.2).set_trans(Tween.TRANS_SINE)
		tween.tween_callback(queue_free)
	elif direction == "above":
		tween.tween_property(mesh, "position", Vector3(0, -2, 0), 0.175).set_trans(Tween.TRANS_SINE)
		tween.tween_property(mesh, "position", Vector3(0, -1.5, 0), 0.2).set_trans(Tween.TRANS_SINE)
		tween.tween_callback(queue_free)
