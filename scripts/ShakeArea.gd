extends Area3D

@export var shake := 5

func do_shake(body):
	print(body)
	if body.has_method("add_shake"):
		body.add_shake(shake)
