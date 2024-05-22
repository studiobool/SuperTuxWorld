extends Node

@onready var pause_menu = $PauseMenu

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed("esc") and !pause_menu.visible:
		pause_menu.open_pause_menu()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_pause_menu_back_to_main_pressed():
	get_tree().change_scene_to_file("res://addons/EasyMenus/Scenes/main_menu.tscn")


func _on_pause_menu_return_to_world_pressed():
	get_tree().change_scene_to_file("res://scenes/level/movement_test_map.tscn")
