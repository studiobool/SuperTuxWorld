extends Node3D

@onready var master = self.get_parent()
@onready var raycast = $RayCast3D
@onready var marker = $Marker3D
@onready var marker2 = $Marker3D2
@export var track : Node3D
@export var object_collision: CollisionShape3D
var object

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if master.state == "Water":
		marker.position.y = 0
		marker2.position.y = 0
	else:
		marker.position.y = .75
		marker2.position.y = .75
	
	# Drops object
	if Input.is_action_just_pressed("interact") && object:
		drop_object(master.velocity * object.mass)
		marker.rotation = Vector3.ZERO
	
	# Drops object with more force
	if Input.is_action_just_pressed("fire") && object:
		var knockback = marker2.global_position - object.global_position
		var throw_force = object.get_node("Interact").throw_override
		if throw_force:
			drop_object((-knockback * throw_force) + (master.velocity * object.mass))
		else:
			drop_object((-knockback * object.mass * 6) + (master.velocity * object.mass))
		marker.rotation = Vector3.ZERO
	
	# Detects if raycast finds object then if interacted grabs object
	if raycast.get_collider() && raycast.get_collider() is RigidBody3D:
		if raycast.get_collider().has_node("Interact"):
			if Input.is_action_just_pressed("interact"):
				if object == null:
					marker.global_rotation = raycast.get_collider().global_rotation
					raycast.get_collider().freeze = true
					object = raycast.get_collider()
					object.get_node("CollisionShape3D").disabled = true
					object_collision.shape = object.get_node("CollisionShape3D").shape
					object_collision.disabled = false

func drop_object(force):
	object.get_node("CollisionShape3D").disabled = false
	# Some hack in case object collision hasn't been re-enabled
	if object.get_node("CollisionShape3D").disabled == false:
		object.freeze = false
		object_collision.disabled = true
		object.apply_central_impulse(force)
		object = null
	else:
		print("dropping again")
		drop_object(force)

func _physics_process(_delta: float) -> void:
	# Rotates in match with the character
	global_rotation = master.model.global_rotation
	object_collision.global_position = marker.global_position
	object_collision.global_rotation = marker.global_rotation
	if object:
		object.global_position = marker.global_position
		object.global_rotation = marker.global_rotation
	
