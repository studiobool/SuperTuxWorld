extends Area3D

var is_player_in : bool

@export var level : PackedScene
@export var level_icon : Texture2D
@export var level_name : String

@onready var lvl_icon = $LevelIcon
@onready var lvl_nme = $LevelIcon/LevelName

# Called when the node enters the scene tree for the first time.
func _ready():
	lvl_icon.texture = level_icon
	lvl_nme.text = level_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if is_player_in && Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_packed(level)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		is_player_in = true
		$Control.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		is_player_in = false
		$Control.visible = false
