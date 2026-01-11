extends Sprite2D

@export var max_frames : int
@export var time : float
@export var timer := 0.06

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += 1 * delta
	if time >= timer:
		frame += 1
		time = 0
	if frame >= max_frames:
		frame = 0
