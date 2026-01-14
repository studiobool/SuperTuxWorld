extends Node

@export var is_fire : bool
@export var is_wing : bool
var grav_multi : float = 1
var jump_multi : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_wing:
		grav_multi = 0.375
		jump_multi = 2
	else:
		grav_multi = 1
		jump_multi = 1
