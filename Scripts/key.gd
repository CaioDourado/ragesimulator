extends Area2D

@export var key_texture : Texture2D
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var collider : CollisionShape2D = $CollisionShape2D
var active : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and active:
		active = false
		#GameManager.add_key()
		GameManager.animation_add_key(key_texture, global_position)
		modulate = Color(0,0,0,0)
		audio_player.play()
		await audio_player.finished
		queue_free()
