@tool
extends Node3D

@export var shake_reduct := 1.0

@export var max_shake := Vector3(10, 10, 5)

@export var noise : Noise
@export var noise_speed := 50.0

@export var shake := 0.0
var time := 0.0

@onready var init_rotation := rotation_degrees as Vector3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	shake = max(shake - delta * shake_reduct, 0.0)
	
	rotation_degrees = init_rotation + max_shake * get_shake_intensity() * Vector3(get_noise_from_seed(0), get_noise_from_seed(1), get_noise_from_seed(2))

func add_shake(amount : float):
	shake = clamp(shake + amount, 0.0, 1.0)

func get_shake_intensity() -> float:
	return shake * shake

func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
