extends Node2D

var start_pos : Vector2
@export var distance : float = 50
@onready var prensser : Node2D = $StaticBody2D
@onready var tween := create_tween()
@onready var shake_area := $StaticBody2D/ShakeArea
@onready var audio_player := $AudioStreamPlayer2D

@onready var sound_squeze : AudioStreamMP3 = preload("res://Assets/Audio/SFX/prensa.mp3")
@onready var sound_mechanism : AudioStreamMP3 = preload("res://Assets/Audio/SFX/mechanism.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = prensser.global_position
	iniciar_ciclo()

func iniciar_ciclo():
	tween = create_tween()
	tween.set_loops()  # Loop infinito

	tween.tween_property(prensser, "global_position", Vector2(start_pos.x, start_pos.y + distance), 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "executar_impacto_com_som"))
	tween.tween_interval(2.0)  # espera 2 segundos
	#tween.tween_callback(Callable(self, "executar_som_mechanism"))
	tween.tween_property(prensser, "global_position", start_pos, 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_interval(2.0)  # espera 2 segundos

func executar_impacto_com_som():
	shake_area.notify_impact()
	audio_player.stream = sound_squeze
	audio_player.play()

func executar_som_mechanism():
	audio_player.stream = sound_mechanism
	audio_player.play()
