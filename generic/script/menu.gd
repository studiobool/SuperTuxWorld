extends Control

@onready var main = $Main
@onready var settings = $"Settings Menu"
@onready var options = $Options
@onready var video = $Video

func _on_open_test_level_pressed():
	get_tree().change_scene_to_file("res://scenes/level/level_test.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_return_pressed():
	main.visible = true
	settings.back()

func _on_options_pressed():
	main.visible = false
	settings.settings()
