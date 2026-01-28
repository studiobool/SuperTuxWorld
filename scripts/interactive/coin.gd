extends Area3D

var collected : bool = false
@export var mesh : MeshInstance3D
@onready var sound = $CoinSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mesh.rotation.y += 3 * delta


func _on_body_entered(body: Node3D) -> void:
	if body is Player && !collected:
		collected = true
		body.stats.coins += 1
		sound.play()
		visible = false
