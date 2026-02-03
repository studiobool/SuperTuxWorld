class_name WoodenBlock extends InteractBlock

const exploding_brick = preload("res://entities/interactive/fractured_wooden_brick.tscn")
@onready var collider = $CollisionShape3D

func _block_hit(_body, _hit):
	var instance = exploding_brick.instantiate()
	instance.global_position = global_position
	instance.top_level = true
	get_parent().add_child(instance)
	queue_free()
