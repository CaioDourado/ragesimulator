extends Node2D

@export var musics : Array[AudioStreamMP3]
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func play_music(index, volume) -> void:
	audio_player.stream = musics[index]
	audio_player.volume_db = volume
	audio_player.play()

func transit_music(index, volume, timer=1) -> void:
	var tween = create_tween()
	
	if audio_player.stream != musics[index]:
		tween.tween_property(audio_player, "volume_db", -40, 1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		audio_player.stream = musics[index]
	
	if not audio_player.playing:
		audio_player.play()
	
	tween = create_tween()
	tween.tween_property(audio_player, "volume_db", volume, timer).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func no_music() -> void:
	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", -40, 3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	audio_player.stop()
