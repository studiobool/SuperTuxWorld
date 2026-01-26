extends Node3D

@onready var jump = $jump
@onready var hurt = $hurt
@onready var splash = $splash

func _jump():
	jump.play()

func _hurt():
	hurt.play()

func _splash():
	splash.play()
