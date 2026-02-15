extends Area3D

var enabled : bool = true
@export var shake := 5

func do_shake(body):
	if enabled:
		if body.has_method("add_shake"):
			body.add_shake(shake)
