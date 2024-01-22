extends Node

@export var instant_exit : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("esc") && OS.is_debug_build():
		if instant_exit:
			get_tree().quit()
