class_name WoodenBlock extends InteractBlock

const exploding_brick = preload("res://entities/interactive/fractured_wooden_brick.tscn")
@onready var collider = $CollisionShape3D

func _block_hit(body, hit):
	var instance = exploding_brick.instantiate()
	instance.top_level = true
	instance.global_position = global_position
	get_parent().add_child(instance)
	queue_free()
