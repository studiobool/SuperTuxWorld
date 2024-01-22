extends CharacterBody3D

@onready var timer = $Timer
@onready var audio = $AudioStreamPlayer3D
@onready var area = $Area3D
@onready var mesh = $MeshInstance3D
@onready var item_pos = $ItemPosition
@export var coin = 2
var collected = false
const full_mat = preload("res://entities/blocks/full2.tres")
const empty_mat = preload("res://entities/blocks/empty2.tres")

@export_node_path() var item

func _ready():
	mesh.set_surface_override_material(0, full_mat)

func _process(_delta):
	if coin <= 0:
		collected = true
		area.monitoring = false
		$MeshInstance3D/Label3D.visible = false
		mesh.set_surface_override_material(0, empty_mat)

func _on_body_entered(body):
	if body.name == "Player" && body.velocity.y >= -1.5:
		if collected == false && timer.is_stopped():
			timer.start()
			if !item:
				body.coins += 1
				coin -= 1
			else:
				coin = 0
			audio.play()
			Input.start_joy_vibration(0, 1.0, 0.0, 0.15)
