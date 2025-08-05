extends Node2D

@onready var bt_back : TextureButton = $CanvasLayer/Control/Panel/BtBack

@onready var audio_player : AudioStreamPlayer = $CanvasLayer/AudioStreamPlayer

@onready var slider_sfx : VSlider = $CanvasLayer/Control/Panel/Tela/HBoxContainer/Right/ContextOptions/ContextSound/SliderSFX
@onready var slider_music : VSlider = $CanvasLayer/Control/Panel/Tela/HBoxContainer/Right/ContextOptions/ContextSound/SliderMusic

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bt_back.disabled = false
	slider_sfx.value = AudioServer.get_bus_volume_db(SFX_BUS_ID)
	slider_music.value = AudioServer.get_bus_volume_db(MUSIC_BUS_ID)

func _on_bt_back_pressed() -> void:
	bt_back.disabled = true
	play_sound(preload("res://Assets/Audio/UI/Button1.mp3"))
	await audio_player.finished
	GameManager.go_to_home()

func play_sound(resource):
	audio_player.stream = resource;
	audio_player.play()

func _on_bt_nao_pressed() -> void:
	play_sound(preload("res://Assets/Audio/UI/Touch9.mp3"))
	GameManager.go_to_home()

func _on_bt_sim_pressed() -> void:
	play_sound(preload("res://Assets/Audio/UI/Touch9.mp3"))
	SaveManager.delete_save()
	SaveManager.create_save()
	var local_save = SaveManager.load_local()
	SaveManager.load_save(local_save)
	GameManager.go_to_home()

func _on_bt_portugues_pressed() -> void:
	play_sound(preload("res://Assets/Audio/UI/Touch9.mp3"))
	saveLanguage("pt_BR")

func _on_bt_ingles_pressed() -> void:
	play_sound(preload("res://Assets/Audio/UI/Touch9.mp3"))
	saveLanguage("en")

func _on_bt_espanhol_pressed() -> void:
	play_sound(preload("res://Assets/Audio/UI/Touch9.mp3"))
	saveLanguage("es")

func _on_bt_alemao_pressed() -> void:
	play_sound(preload("res://Assets/Audio/UI/Touch9.mp3"))
	saveLanguage("de")
	
func saveLanguage(lg):
	TranslationServer.set_locale(lg)
	SaveManager.memory_card.configs.language = lg
	SaveManager.save_local()

func _on_slider_music_value_changed(value: float) -> void:
	play_sound(preload("res://Assets/Audio/UI/Touch2.mp3"))
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, value)
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < -9)
	SaveManager.memory_card.configs.audio_music = value
	SaveManager.save_local()
	
func _on_slider_sfx_value_changed(value: float) -> void:
	play_sound(preload("res://Assets/Audio/UI/Touch2.mp3"))
	AudioServer.set_bus_volume_db(SFX_BUS_ID, value)
	AudioServer.set_bus_mute(SFX_BUS_ID, value < -9)
	SaveManager.memory_card.configs.audio_sfx = value
	SaveManager.save_local()
