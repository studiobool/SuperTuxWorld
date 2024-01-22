extends Node

func oof():
	$"..".state == 0
	$"..".dead()
	$"..".anim_tree.set("parameters/conditions/dead", !$"..".chase)
	print("oof")
