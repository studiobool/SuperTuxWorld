extends RigidBody3D

var direction

# Called when the node enters the scene tree for the first time.
func _ready():
	direction = ($Marker3D.transform.origin - global_transform.origin).normalized()
	apply_central_impulse(direction * 32)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	await get_tree().create_timer(0.7).timeout
	if linear_velocity.y <= 0:
		await get_tree().create_timer(0.5).timeout
		if linear_velocity.y <= 0:
			queue_free()
