extends Control
signal pause
signal resume
signal return_to_world_pressed
signal back_to_main_pressed

@onready var content : VBoxContainer = $%Content
@onready var options_menu : Control = $%OptionsMenu
@onready var resume_game_button: Button = $%ResumeGameButton
	
func open_pause_menu():
	#Stops game and shows pause menu
	get_tree().paused = true
	GlobalManager.is_paused = true
	show()
	emit_signal("pause")
	resume_game_button.grab_focus()
	
func close_pause_menu():
	get_tree().paused = false
	GlobalManager.is_paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	hide()
	emit_signal("resume")

func _on_resume_game_button_pressed():
	close_pause_menu()

func _on_options_button_pressed():
	content.hide()
	options_menu.show()
	options_menu.on_open()


func _on_options_menu_close():
	options_menu.hide()
	content.show()
	resume_game_button.grab_focus()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_return_to_world_button_pressed():
	close_pause_menu()
	emit_signal("return_to_world_pressed")

func _on_back_to_menu_button_pressed():
	close_pause_menu()
	emit_signal("back_to_main_pressed")

func _input(event):
	if (event.is_action_pressed("ui_escape") or event.is_action_pressed("ui_cancel")) and visible and !options_menu.visible:
		accept_event()
		close_pause_menu()
