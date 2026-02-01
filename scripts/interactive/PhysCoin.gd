extends RigidBody3D

@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D
@export var sound : AudioStream
var old_vel : float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !mesh.visible:
		collision.disabled = true
		freeze = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var diff = linear_velocity.y - old_vel
	if diff > 1:
		_play_audio()
	old_vel = linear_velocity.y

func _play_audio() -> void:
	var audio = AudioStreamPlayer3D.new()
	audio.stream = sound
	audio.unit_size = 2.5
	audio.attenuation_filter_cutoff_hz = 20500
	audio.pitch_scale = randf_range(0.99,1.1)
	add_child(audio)
	audio.play()
