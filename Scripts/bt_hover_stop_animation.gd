extends Button

@onready var texture_node := $Icon

func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	(texture_node.texture as AnimatedTexture).current_frame = 0

func _on_mouse_entered() -> void:
	if texture_node and texture_node.texture is AnimatedTexture:
		(texture_node.texture as AnimatedTexture).pause = false

func _on_mouse_exited() -> void:
	if texture_node and texture_node.texture is AnimatedTexture:
		(texture_node.texture as AnimatedTexture).pause = true
		(texture_node.texture as AnimatedTexture).current_frame = 0
