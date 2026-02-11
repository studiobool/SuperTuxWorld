@tool
extends Node3D

@export var ready_rotate : bool
@export var is_rotating : bool
@export var rotate : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ready_rotate:
		is_rotating = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible && is_rotating:
		rotation += rotate * delta
