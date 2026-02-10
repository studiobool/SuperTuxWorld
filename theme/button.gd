extends Button

@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_hovered():
		label.set("theme_override_colors/font_color", Color(0.4, 0.651, 1.0, 1.0))
	else:
		label.set("theme_override_colors/font_color", Color.WHITE)
