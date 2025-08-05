extends CanvasLayer

var screen_half : Vector2
var config_open = false

@onready var panel : ColorRect = $ColorRect
@onready var clipboard : TextureRect = $ColorRect/ClipBoard
@onready var config_panel : TextureRect = $ColorRect/ClipBoard/ConfigRect
@onready var animator : AnimationPlayer = $Animator
@onready var clock_label : Label = $ColorRect/ClipBoard/Screen/GridContainer/ClockIcon/Label
@onready var gear_label : Label = $ColorRect/ClipBoard/Screen/GridContainer/GearIcon/Label
@onready var death_label : Label = $ColorRect/ClipBoard/Screen/GridContainer/DeathIcon/Label

@onready var slider_sfx : VSlider = $ColorRect/ClipBoard/ConfigRect/SliderSFX
@onready var slider_music : VSlider = $ColorRect/ClipBoard/ConfigRect/SliderMusic

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setAnimationIndex("open","ColorRect/ClipBoard:position",
		[[0,Vector2(clipboard.position-Vector2(200,0))],[1,clipboard.position]]
	);
	setAnimationIndex("close","ColorRect/ClipBoard:position",
		[[0,clipboard.position],[1,Vector2(clipboard.position+Vector2(200,0))]]
	);
	
	visible = false
	panel.visible = false
	clipboard.visible = false
	
	slider_sfx.value = AudioServer.get_bus_volume_db(SFX_BUS_ID)
	slider_music.value = AudioServer.get_bus_volume_db(MUSIC_BUS_ID)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pause_game():
	setQuests()
	visible = true
	get_tree().paused = true
	animator.play("open")
	await animator.animation_finished
	animator.play("idle")

func resume_game():
	animator.play("close")
	await animator.animation_finished
	visible = false
	get_node(GameManager.stage_path("UI")).resume_timer()
	get_tree().paused = false
	
func restart_game():
	#get_tree().reload_scene()
	visible = false
	get_tree().paused = false
	GameManager.play_now()
	
func quit_game():
	visible = false
	GameManager.go_to_home()

func _on_bt_resume_pressed() -> void:
	resume_game()

func _on_bt_restart_pressed() -> void:
	restart_game()

func _on_bt_quit_pressed() -> void:
	quit_game()
	
func _on_config_button_pressed() -> void:
	var new_pos = config_panel.position+Vector2(200,0)
	if config_open:
		new_pos = config_panel.position-Vector2(200,0)
	var tween = create_tween()
	tween.tween_property(config_panel, "position", new_pos, .5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	config_open = !config_open

func setAnimationIndex(animation_name: String, path : String, indexs : Array):
	var animation = animator.get_animation(animation_name)
	var track_index = animation.find_track(path, Animation.TYPE_VALUE)
	if track_index != -1:
		for index in indexs:
			animation.track_set_key_value(track_index, index[0], index[1])

func setQuests():
	var stage_now : StageLibrary = GameManager.get_current_stage()
	var gears_now : int = GameManager.get_gears()
	clock_label.text = GameManager.time_converter(stage_now.quest_time)
	death_label.text = str(stage_now.quest_deaths)
	gear_label.text = str(gears_now," / ",stage_now.quest_gears)


func _on_slider_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, value)
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < -9)
	
func _on_slider_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_ID, value)
	AudioServer.set_bus_mute(SFX_BUS_ID, value < -9)
