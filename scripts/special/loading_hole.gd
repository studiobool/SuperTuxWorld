extends Control

@onready var anim_player = $AnimationPlayer
@onready var test_timer = $Timer
@export var test_in : bool
@export var test_out : bool
@export var time : float
var holed : bool

func _ready() -> void:
	test_timer.wait_time = time
	if test_in or test_out:
		visible = true
		test_timer.start()
		await test_timer.timeout
		if test_in:
			hole_in()
		elif test_out:
			hole_out()
	else:
		visible = false

func hole_in():
	holed = false
	visible = true
	anim_player.play("hole-in")
	
func hole_out():
	holed = false
	visible = true
	anim_player.play("hole-out")

func animation_finished(anim_name: StringName) -> void:
	if anim_name == "hole-out":
		visible = false
	holed = true
