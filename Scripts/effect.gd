extends Node2D

@onready var spriteRenderer : AnimatedSprite2D = $AnimatedSprite2D
var offset = null
var side = false

func _ready() -> void:
	spriteRenderer.flip_h = side
	if offset != null:
		spriteRenderer.offset = offset

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func set_side(s: bool):
	side = s

func set_offset(os : Vector2):
	offset = os
