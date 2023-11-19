extends CharacterBody3D

@onready var timer = $Timer
@onready var audio = $AudioStreamPlayer3D
@onready var area = $Area3D
@onready var mesh = $MeshInstance3D
@export var coin = 2
var collected = false
const full_mat = preload("res://entities/blocks/full.tres")
const empty_mat = preload("res://entities/blocks/empty.tres")

func _process(_delta):
	if coin <= 0:
			collected = true
			area.monitoring = false
			$MeshInstance3D/Label3D.visible = false
			mesh.set_surface_override_material(0, empty_mat)

func _on_body_entered(body):
	if body.name == "Player" && body.velocity.y >= 0:
		if collected == false && timer.is_stopped():
			timer.start()
			body.coins += 1
			coin -= 1
			audio.play()
