extends CharacterBody3D

var _velos : Vector3
var is_moving = true
var active = true
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

#@onready var animation_player = $AnimationPlayer
@onready var destroy_timer = $DestroyTimer

#func _ready():
	#if _velos.x >= 0:
		#animation_player.play("default")
	#else:
		#animation_player.play_backwards("default")

func _process(delta):
	if !is_moving: return
	apply_gravity(delta)
	
	var collision = move_and_collide(_velos * delta)
	if collision:
		if collision.normal.y == 0:
			dissipate()
			return
		_velos = _velos.bounce(collision.normal)
		position.x += _velos.x * delta
	if is_on_wall(): dissipate()

func apply_gravity(delta, gravity_set = gravity):
	_velos.y += gravity_set * delta

func _on_EnemyKill_body_entered(body):
	if !is_moving: return
	if body.has_method("fireball_hit"):
		body.fireball_hit()
		dissipate()
		return
	
	if body.is_in_group("enemies"):
		if body.has_method("die"):
			if !body.invincible:
				body.die()
				dissipate()

func dissipate():
	if !active: return
	active = false
	free_fireball_slot()
	destroy_timer.start()
	#animation_player.play("dissipate")
	is_moving = false

func _on_DestroyTimer_timeout():
	call_deferred("queue_free")

func _on_VisibilityNotifier2D_screen_exited():
	if !active: return
	active = false
	free_fireball_slot()
	call_deferred("queue_free")

func free_fireball_slot():
	#Global.fireballs_on_screen -= 1
	pass
