extends Node2D

@export var move_limit : float = 20
@export var move : bool = false

var limite_y = 0
var active_move = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	limite_y = global_position.y - move_limit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active_move:
		if global_position.y > limite_y:
			global_position.y -= 150 * delta


func _on_collider_move_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if move:
			active_move = true

func _on_collider_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		GameManager.respawn()
