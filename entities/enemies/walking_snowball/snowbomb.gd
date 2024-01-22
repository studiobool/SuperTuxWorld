extends Node

var ticking = false
@export var walk_speed = 6.25
@export var run_speed = 7.5
@onready var timer = $"../Timer"
@onready var fizz = $"../FizzSound"
@onready var explosion = preload("res://entities/special/explosion.tscn")

func oof():
	if !ticking:
		timer.start()
		fizz.play()
		ticking = true

func _process(delta):
	if ticking:
		$"..".SPEED = 0.0
		await get_tree().create_timer(1).timeout
		$"..".SPEED = walk_speed
		$"..".SPEED = lerp($"..".SPEED, run_speed, delta * 11.5)

func _on_timer_timeout():
	$"..".state == 0
	explode()
	$"..".dead()
	fizz.stop()
	print("oof")

func _on_player_detection_body_entered(_body):
	if ticking:
		$"..".state == 0
		$"..".dead()
		fizz.stop()
		explode()
		print("oof")
	else:
		oof()

func _a():
	var direction = ($"..".player.transform.origin - $"..".global_transform.origin).normalized()
	$"..".player.velocity += Vector3(direction.x * 32, direction.y + 8, direction.z * 32)
	print("ouch")

func explode():
	var explosion_instance = explosion.instantiate()
	explosion_instance.position = $"..".position
	add_child(explosion_instance)
	explosion_instance.set_as_top_level(true)
