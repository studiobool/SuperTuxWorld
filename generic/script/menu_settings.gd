extends Control

@onready var options = $Options
@onready var video = $Video
@onready var audio = $Audio

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func settings():
	options.visible = true
	video.visible = false
	audio.visible = false

func back():
	options.visible = false
	video.visible = false
	audio.visible = false

func _on_options_pressed():
	settings()

func _on_video_pressed():
	options.visible = false
	video.visible = true
	audio.visible = false

func _on_audio_pressed():
	options.visible = false
	video.visible = false
	audio.visible = true
