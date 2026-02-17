extends RigidBody3D

var time : float = 1.0
var timer : float
var max_timer : float
var max_time : float = 10
var on_floor: bool = false
var has_started: bool = false
@onready var mesh = $MeshInstance3D

func _process(delta: float) -> void:
	if on_floor:
		max_timer = 0.0
		if timer < time:
			timer += delta
	else:
		timer = 0.0
	
	if max_timer < max_time:
		max_timer += delta
	
	if timer > time && !has_started:
		start_disappearing()
	if max_timer > max_time:
		start_disappearing()

# Called when the node enters the scene tree for the first time.
func start_disappearing() -> void:
	has_started = true
	await get_tree().create_timer(4).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(mesh, "scale", Vector3(), 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var i := 0
	while i < state.get_contact_count():
		var normal := state.get_contact_local_normal(i)
		on_floor = normal.dot(Vector3.UP) > 0 # this can be dialed in
		#  1.0 would be perfectly straight up
		#  0.0 is a wall
		# -1.0 is a ceiling
		i += 1
