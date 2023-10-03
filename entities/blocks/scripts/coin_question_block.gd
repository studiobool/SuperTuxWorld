extends CharacterBody3D

@onready var timer = $Timer
@onready var audio = $AudioStreamPlayer3D
@export var coin = 2
var collected = false

func _on_body_entered(body):
	if body.name == "Player" && timer.is_stopped() && collected == false:
		timer.start()
		body.coins += 1
		coin -= 1
		audio.play()
		if coin <= 0:
			collected = true
			await audio.finished
			queue_free()
