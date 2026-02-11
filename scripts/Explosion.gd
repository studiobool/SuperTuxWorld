extends Node3D

var tween
var who : Node3D
@onready var light = $OmniLight3D
@onready var shockwave = $Area3D3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tween = create_tween()
	tween.tween_property(light, "light_energy", 0, 1.5)

func _process(delta: float) -> void:
	for a in shockwave.get_overlapping_bodies():
		print("a")
		if who is Player:
			print("b")

func _on_sound_finished() -> void:
	queue_free()
