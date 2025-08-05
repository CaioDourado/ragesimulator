extends Area2D

var active : bool = false
var time_seted : float
@onready var animator : AnimatedSprite2D = $Animator
@onready var timer : Label = $Timer
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	timer.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if active:
		#animator.play("used")
	pass


func _on_body_entered(body: Node2D) -> void:
	if GameManager.connection_status:
		if body is CharacterBody2D:
			if not active:
				play_sound(preload("res://Assets/Audio/SFX/checkpoint.mp3"))
				time_seted = GameManager.setCheckPoint(self)
				timer.text = GameManager.time_converter(time_seted)
				timer.visible = true
				active = true
	else:
		timer.text = "Sem Conexão"
		timer.visible = true
		
func get_time_setted() -> float:
	return time_seted

func play_sound(source):
	audio_player.stream = source
	audio_player.play()
