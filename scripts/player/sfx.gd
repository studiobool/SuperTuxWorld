extends Node3D

@onready var jump = $jump

func _jump():
	jump.play()
