extends Node2D

@onready var audio_player : AudioStreamPlayer = $CanvasLayer/AudioStreamPlayer

@export var start_delay : float = 1.0
@export var screen_time : float = 0.3

@export var shader := preload("res://Shader/fadein.gdshader")
@export var textures : Array[TextureRect]
@export var labels : Array[TextureRect]

@onready var bt_config : Button = $CanvasLayer/Control/Background/Painel/BtConfig
@onready var bt_play : Button = $CanvasLayer/Control/Background/Painel/BtJogar
@onready var bt_stages : Button = $CanvasLayer/Control/Background/Painel/BtFases

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BgmController.transit_music(0, -25, 2)
	bt_play.disabled = false
	bt_stages.disabled = false
	bt_config.disabled = false
	
	bt_config.pressed.connect(gotToSettings)
	bt_play.pressed.connect(goToGMPlayNow)
	bt_stages.pressed.connect(goToGMStages)
	loadGameData()
	if GameManager.first_home:
		mainMenuBtEffect()
	GameManager.set_first_home(false)

func mainMenuBtEffect():
	#for sprite in textures:
		#var shader_material := ShaderMaterial.new()
		#shader_material.shader = shader
		#sprite.material = shader_material
		#sprite.material.set_shader_parameter("reveal_progress", 1.0)
		
	for label in labels:
		label.modulate.a = 0
		
	#await get_tree().create_timer(start_delay).timeout
	
	var tween := create_tween().set_parallel(true)
	#for sprite in textures:
		#tween.tween_method(
			#func(val): sprite.material.set_shader_parameter("reveal_progress", val),
			#1.0, 0.0, screen_time
		#).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		
	#await get_tree().create_timer(screen_time).timeout
	
	tween = create_tween().set_parallel(true)
	for label in labels:
		tween.tween_property(label, "modulate", Color(1, 1, 1, 1), 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		
	await get_tree().create_timer(0.2).timeout
	
	for sprite in textures:
		sprite.material = null
		var canvasMaterial = CanvasItemMaterial.new()
		canvasMaterial.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		sprite.material = canvasMaterial

func loadGameData():
	if SaveManager.get_save() == null:
		var local_save = SaveManager.load_local()
		if local_save == null:
			local_save = SaveManager.create_save()
		else:
			SaveManager.load_save(local_save)
		#if OS.get_name() == "Android":
			#print("Setting Google Plays Services")
			#GooglePlayServices.sign_in_success.connect(_signInSuccess)
			#GooglePlayServices.sign_in_failed.connect(_signInFail)
			#GooglePlayServices.load_success.connect(onLoadGame)
			#GooglePlayServices.load_failed.connect(onLoadGameFail)
			#GooglePlayServices.save_success.connect(onSaveSuccess)
			#GooglePlayServices.save_failed.connect(onSaveFail)
			#signInAndLoad()
	else:
		print("==> Game: Saved Game Already Loaded")
		print(SaveManager.memory_card)

func goToGMPlayNow():
	bt_play.disabled = true
	GameManager.play_now()
	
func goToGMStages():
	play_sound(preload("res://Assets/Audio/UI/Touch3.mp3"))
	bt_stages.disabled = true
	GameManager.go_to_stages()

func gotToSettings():
	play_sound(preload("res://Assets/Audio/UI/Touch3.mp3"))
	bt_config.disabled = true
	GameManager.go_to_settings()

func play_sound(resource):
	audio_player.stream = resource;
	audio_player.play()
