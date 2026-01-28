extends Node3D

@onready var jump = $jump
@onready var hurt = $hurt
@onready var splash = $splash
@onready var brick = $brick

func _jump():
	jump.play()

func _hurt():
	hurt.play()

func _splash():
	splash.play()

func _brick():
	brick.play()
