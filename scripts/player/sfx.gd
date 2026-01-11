extends Node3D

@onready var jump = $jump
@onready var hurt = $hurt

func _jump():
	jump.play()

func _hurt():
	hurt.play()
