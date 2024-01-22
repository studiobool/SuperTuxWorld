extends Area3D

@export var explosion_force = 240.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for o in get_overlapping_bodies():
		if o is CharacterBody3D:
			var direction = (o.global_position - global_position).normalized()
			direction *= explosion_force * delta
			o.velocity += Vector3(direction.x, direction.y, direction.z)
			if o.is_in_group("Enemy"):
				o.dead()
		elif o is RigidBody3D:
			var direction = (o.global_position - global_position).normalized()
			direction *= explosion_force * delta
			o.apply_central_impulse(direction)
