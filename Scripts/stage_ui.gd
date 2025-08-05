extends CanvasLayer

@export var desativar : bool = false
@export var timeout : float = 4.5
@export var gears_fill : Texture2D

@onready var lifes_img : TextureRect = $Control/Life
@onready var lifes : Label = $Control/Life/Counter
@onready var timer_img : TextureRect = $Control/Clock
@onready var timer : Label = $Control/Clock/Timer
@onready var gears : Label = $Control/Gears/Counter
@onready var gears_img : Control = $Control/Gears
@onready var fps_label : Label = $Control/FPS
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

var tempo_decorrido: float = 0.0
var rodando: bool = false  # Define se o cronômetro está ativo

func _ready() -> void:
	if not desativar:
		disapear_all()
		await get_tree().create_timer(timeout).timeout
		appear_all()
	GameManager.check_connection()

func _process(delta: float) -> void:
	fps_label.text = str("FPS: ",Engine.get_frames_per_second())
	if rodando:
		tempo_decorrido += delta
		atualizar_tempo()

func atualizar_tempo():
	timer.text = GameManager.time_converter(tempo_decorrido)

func start_timer():
	rodando = true;

func pause_timer():
	rodando = false  # Para a contagem de tempo

func resume_timer():
	rodando = true  # Continua contando

func reset_timer():
	tempo_decorrido = 0.0
	atualizar_tempo()
	
func set_timer(t : float):
	tempo_decorrido = t

func get_timer() -> float:
	return tempo_decorrido

func att_label_lifes():
	lifes.text = str("x",GameManager.get_player_lifes())

func att_label_gears(index: int):
	#gears.text = str("x",GameManager.get_gears())
	gears_img.get_child(index).texture = gears_fill
	
func play_swap():
	audio_player.stream = preload("res://Assets/Audio/SFX/item_move.mp3")
	audio_player.play()

func disapear_all():
	lifes_img.modulate.a = 0
	gears_img.modulate.a = 0
	lifes.modulate.a = 0
	timer_img.modulate.a = 0
	gears.modulate.a = 0
	fps_label.modulate.a = 0

func appear_all():
	var tween := create_tween().set_parallel(true)
	tween.tween_property(lifes, "modulate", Color(1, 1, 1, 1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(lifes_img, "modulate", Color(1, 1, 1, 1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(timer_img, "modulate", Color(1, 1, 1, 1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(gears, "modulate", Color(1, 1, 1, 1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(gears_img, "modulate", Color(1, 1, 1, 1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(fps_label, "modulate", Color(1, 1, 1, 1), 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
