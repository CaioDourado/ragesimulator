extends Area2D

@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		audio_player.play()
		body.global_position = Vector2(global_position.x, global_position.y-8)
		GameManager.finish_stage()
