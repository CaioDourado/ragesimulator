extends Node2D

@onready var plataform : AnimatableBody2D = $AnimatedRB

@export var speed : float = 1
@export var side : Vector2
var new_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_pos = plataform.global_position + side

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var tween = create_tween()
		tween.tween_property(plataform, "global_position", new_pos, speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
