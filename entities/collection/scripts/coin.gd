extends Area3D

@export var coin = 1
@onready var audio = $AudioStreamPlayer3D
var collected = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(3.5 * delta)

func _on_body_entered(body):
	if body.name == "Player" && collected == false:
		body.coins += coin
		collected = true
		audio.play()
		await audio.finished
		queue_free()
