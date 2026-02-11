@tool
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
		var tween = create_tween()
		var target_position = mesh.global_position + Vector3(0, 2, 0)
		tween.tween_property(mesh, "global_position", target_position, 0.25).set_trans(Tween.TRANS_SINE)
		await tween.finished
		mesh.visible = false
		tween.kill()
