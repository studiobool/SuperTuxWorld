extends Area3D

var collected : bool = false
@export var mesh : MeshInstance3D
@export var rotate : bool = true
@onready var sound = $CoinSound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mesh.visible && rotate:
		mesh.rotation.y += 3 * delta
	if !mesh.visible:
		visible = false

func _on_body_entered(body: Node3D) -> void:
	if body is Player && !collected:
		collected = true
		body.stats.coins += 1
		sound.play()
		mesh.visible = false
