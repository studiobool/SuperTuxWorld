extends Area3D

@onready var collision = $StaticBody3D2/CollisionShape3D
@onready var mesh = $StaticBody3D2/MeshInstance3D
@onready var crack_timer = $CrackTimer
@onready var respawn_timer = $RespawnTimer
var inside : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if collision.disabled == true:
		mesh.visible = false
	else:
		mesh.visible = true


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D && body.collision_layer == 2:
		crack_timer.start()
	inside = true

func _on_crack_timer_timeout() -> void:
	collision.disabled = true
	respawn_timer.start()

func _on_respawn_timer_timeout() -> void:
	collision.disabled = false


func _on_body_exited(body: Node3D) -> void:
	inside = false
