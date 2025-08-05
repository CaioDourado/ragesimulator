extends Area2D

@export var invert : bool = false
var opened : bool = false
@onready var collectablePos : Node2D = $Collider
@onready var animator : AnimationPlayer = $Animator
@onready var spritecomputer : Sprite2D = $SpriteComputer
@onready var spritedoor : Sprite2D = $SpriteDoor
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	if invert:
		spritedoor.flip_h = true
		spritecomputer.flip_h = true
		spritecomputer.position.x = 32
		collectablePos.position.x = 31

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not opened:
		GameManager.use_key((collectablePos.global_position+Vector2(0,0)),
			func():
				audio_player.play()
				animator.play("open")
				opened = true
		)
		#if GameManager.use_key():
			#animator.play("open")
			#opened = true

func _on_animator_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"open":
			animator.play("opened")
