extends VBoxContainer

@export var hole_transition : Control
@onready var timer = $Timer
var go_to_scene : String

func select_level(scene: String) -> void:
	hole_transition.hole_in()
	timer.start()
	go_to_scene = scene

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file(go_to_scene)

func exit() -> void:
	get_tree().quit()
