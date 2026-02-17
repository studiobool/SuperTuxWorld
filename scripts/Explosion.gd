extends Node3D

var tween
var who : Node3D = null
@onready var light = $OmniLight3D
@onready var shockwave = $Area3D3
@onready var second_shockwave = $Area3D4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tween = create_tween()
	tween.tween_property(light, "light_energy", 0, 1.5)

func _process(delta: float) -> void:
	if shockwave.interval_reached:
		second_shockwave.enabled = false
	
	for a in shockwave.get_overlapping_bodies():
		if who is Player:
			print("b")
		if a is InteractBlock:
			_break_interact_block(a, who)

func _break_interact_block(body : InteractBlock, character):
	var who = null
	if character is Player:
		who = character
	body._block_hit(who, "")

func _on_sound_finished() -> void:
	queue_free()
