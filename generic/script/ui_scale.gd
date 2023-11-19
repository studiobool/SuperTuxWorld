extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(get_tree().root.content_scale_factor)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_text_submitted(new_text):
	get_tree().root.content_scale_factor = float(new_text)
