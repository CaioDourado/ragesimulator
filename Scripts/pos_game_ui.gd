extends CanvasLayer

var skip = false

@export var typing_speed: float = 0.05
var current_text: String = ""

@onready var bt_jump : Button = $Control/BtJump

@onready var bt_stages : TouchScreenButton = $Control/Container/Panel/Control/btStages
@onready var bt_restart : TouchScreenButton = $Control/Container/Panel/Control/btRestart
@onready var bt_next : TouchScreenButton = $Control/Container/Panel/Control/btNext

@onready var time_check : TextureRect = $Control/Container/Control/Control/TimeCheckbox
@onready var time_checker : TextureRect = $Control/Container/Control/Control/TimeCheckbox/TimeChecker
@onready var time_icon : TextureRect = $Control/Container/Control/Control/TimeIcon
@onready var time_text : Label = $Control/Container/Control/Control/TimeText

@onready var gear_check : TextureRect = $Control/Container/Control/Control2/GearCheck
@onready var gear_checker : TextureRect = $Control/Container/Control/Control2/GearCheck/GearChecker
@onready var gear_icon : TextureRect = $Control/Container/Control/Control2/GearIcon
@onready var gear_text : Label = $Control/Container/Control/Control2/GearText

@onready var death_check : TextureRect = $Control/Container/Control/Control3/DeathCheck
@onready var death_checker : TextureRect = $Control/Container/Control/Control3/DeathCheck/DeathChecker
@onready var death_icon : TextureRect = $Control/Container/Control/Control3/DeathIcon
@onready var death_text : Label = $Control/Container/Control/Control3/DeathText

@onready var capsule : TextureRect = $Control/Container/Capsule
@onready var capsule_glass : TextureRect = $Control/Container/Capsule/Glass
@onready var capsule_player : TextureRect = $Control/Container/Capsule/Player
@onready var capsule_holofort : TextureRect = $Control/Container/Capsule/Holofort
@onready var capsule_liquid : TextureRect = $Control/Container/Capsule/Glass/Liquid
@onready var congratulations_text : Label = $Control/Container/Capsule/Congratulations
@onready var fogos : GPUParticles2D = $Control/FogosArtificio

@onready var label_simulation_complete : Label = $Control/SimulationComplete
@onready var bg_color : ColorRect = $Control/BackgroundColor
@onready var bg_grade : TextureRect = $Control/BgGrade
@onready var loading : TextureRect = $Control/Loading

@onready var bottom_bar : TextureRect = $Control/Container/BottomBar

@onready var quest_1 = $Control/Container/Panel/Quests/Quest1

var can_click = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	bt_jump.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func finish_stage(timer: float, gears: int, deaths: int, stage_now: int):
	visible = true
	exec_animations(tr("simulation_complete"), timer, gears, deaths)
	
func _on_bt_stages_pressed() -> void:
	onBtClick(func():
		if can_click:
			visible = false
			GameManager.go_to_home()
			can_click = false
	)

func _on_bt_restart_pressed() -> void:
	onBtClick(func():
		if can_click:
			visible = false
			get_tree().paused = false
			GameManager.play_now()
			can_click = false
	)

func _on_bt_next_pressed() -> void:
	onBtClick(func():
		if can_click:
			GameManager.next_stage()
			can_click = false
	)

func type_text(text: String):
	for i in range(text.length()):
		current_text += text[i]
		label_simulation_complete.text = current_text  # Atualiza o texto da Label
		await get_tree().create_timer(typing_speed).timeout

func exec_animations(text: String, timer: float, gears: int, deaths: int):
	var viewport_size = get_viewport().size
	execute_tween(bg_color, "position", Vector2(0,176), .5)
	await get_tree().create_timer(.7).timeout
	await type_text(text)
	await get_tree().create_timer(.3).timeout
	execute_tween(bg_color, "position", Vector2(0,0), .5)
	await execute_tween(bg_color, "size", Vector2(viewport_size.x,viewport_size.y), .5)
	await execute_tween(label_simulation_complete, "modulate", Color(0,0,0,0), .5)
	bt_jump.visible = true
	await get_tree().create_timer(.2).timeout
	
	await exec_check_tween(loading, "modulate", Color(1,1,1,1), .4, null, false)
	await exec_check_tween(loading, "modulate", Color(1,1,1,0), .4, null, true)
	
	await animation_counters(timer, gears, deaths)
	
	await exec_check_tween(bottom_bar, "position", Vector2(bottom_bar.position.x - bottom_bar.size.x - 30, bottom_bar.position.y), .5, null, true)
	await exec_check_tween(capsule, "modulate", Color(1,1,1,1), .5, .5, true)
	
	await exec_check_tween(capsule_player, "position", Vector2(capsule_player.position.x, -70), 1, null, true)
	await exec_check_change_sprite(capsule_player, 0, 0, 16, 16, .8, false)
	await exec_check_tween(capsule_holofort, "modulate", Color(1,1,1,1), .1, null, false)
	
	if not skip:
		fogos.emitting = true
		await get_tree().create_timer(.8).timeout
	
	await exec_check_change_sprite(capsule_player, 912, 0, 16, 16, null, false)
	
	if not skip:
		congratulations_text.text = str(tr("congratulations_specimen")," #",(deaths+1))
		
	await exec_check_tween(congratulations_text, "modulate", Color(1,1,1,1), .5, 3, false)
	fogos.emitting = false
	await exec_check_tween(congratulations_text, "modulate", Color(1,1,1,0), .1, null, false)
	await exec_check_tween(capsule_holofort, "modulate", Color(1,1,1,0), .1, null, false)
	capsule_glass.modulate = Color(1,1,1,1)	
	await exec_check_tween(capsule_glass, "position", Vector2(capsule_glass.position.x,capsule_glass.position.y+500), 1, null, true)
	await exec_check_change_sprite(capsule_player, 928, 0, 16, 16, .5, false)
	await exec_check_tween(capsule_liquid, "modulate", Color(1,1,1,1), 1, null, true)
	if not skip:
		capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid2.png")
		await get_tree().create_timer(.02).timeout
		capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid3.png")
		await get_tree().create_timer(.02).timeout
		capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid4.png")
		await get_tree().create_timer(.02).timeout
		capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid5.png")
		await get_tree().create_timer(.02).timeout
		capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid6.png")
		await get_tree().create_timer(.02).timeout
		capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid7.png")
		await get_tree().create_timer(.02).timeout
	capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid8.png")
	await exec_check_change_sprite(capsule_player, 944, 0, 16, 16, null, true)
	await exec_check_tween(capsule_player, "position", Vector2(capsule_player.position.x, capsule_player.position.y-15), .5, null, true)
	bt_jump.visible = false
	
func onBtClick(callback: Callable):
	await execute_tween_impact(capsule_player, "position", Vector2(capsule_player.position.x, capsule_player.position.y-800), 1)
	await get_tree().create_timer(.3).timeout
	capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid7.png")
	await get_tree().create_timer(.02).timeout
	capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid6.png")
	await get_tree().create_timer(.02).timeout
	capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid5.png")
	await get_tree().create_timer(.02).timeout
	capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid4.png")
	await get_tree().create_timer(.02).timeout
	capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid3.png")
	await get_tree().create_timer(.02).timeout
	capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid2.png")
	await get_tree().create_timer(.02).timeout
	capsule_liquid.texture = load("res://Assets/ui/PosGame/liquid/liquid1.png")
	await get_tree().create_timer(.02).timeout
	capsule_liquid.texture = null
	await get_tree().create_timer(.02).timeout
	await execute_tween(capsule_glass, "position", Vector2(capsule_glass.position.x,capsule_glass.position.y-500), 1)
	await get_tree().create_timer(.1).timeout
	callback.call()
	
func animation_counters(timer: float, gears: int, deaths: int):
	var quests = GameManager.check_stage_quests()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(time_check, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(gear_check, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(death_check, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	tween = create_tween().set_parallel(true)
	tween.tween_property(time_icon, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(gear_icon, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(death_icon, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	tween = create_tween().set_parallel(true)
	tween.tween_property(time_text, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(gear_text, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(death_text, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	tween = create_tween().set_parallel(true)
	tween.tween_method(update_time_text, 0.0, timer, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(update_gear_text, 0, gears, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(update_death_text, 0, deaths, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	if quests[0] == true:
		tween = create_tween().set_parallel(true)
		tween.tween_property(time_checker, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(time_checker, "scale", Vector2(1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await tween.finished
	if quests[1] == true:
		tween = create_tween().set_parallel(true)
		tween.tween_property(gear_checker, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(gear_checker, "scale", Vector2(1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await tween.finished
	if quests[2] == true:
		tween = create_tween().set_parallel(true)
		tween.tween_property(death_checker, "modulate", Color(1,1,1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(death_checker, "scale", Vector2(1,1), .3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await tween.finished

func update_time_text(val: float):
	time_text.text = GameManager.time_converter(val)

func update_gear_text(val):
	gear_text.text = str(val)
	
func update_death_text(val):
	death_text.text = str(val)
	
func exec_check_tween(obj, param, val, time, timeout, required = false):
	if skip:
		if required:
			obj.set(param, val)
	else:
		await execute_tween(obj, param, val, time)
		if timeout != null:
			await get_tree().create_timer(timeout).timeout

func exec_check_count_label(label, goal, step, time, is_time = false, timeout = null, required = false):
	if skip:
		if required:
			if is_time:		
				label.text = GameManager.time_converter(goal)
			else:
				label.text = str(goal)
	else:
		await count_on_label(label, goal, step, time, is_time)
		if timeout != null:
			await get_tree().create_timer(timeout).timeout

func exec_check_change_sprite(obj, x, y, w, h, timeout = null, required = false):
	if skip:
		if required:
			change_obj_sprite(obj, x, y, w, h)
	else:
		await change_obj_sprite(obj, x, y, w, h)
		if timeout != null:
			await get_tree().create_timer(timeout).timeout

func change_obj_sprite(obj, x, y, w, h):
	var atlas_texture = obj.texture
	var nova_textura = atlas_texture.duplicate()
	nova_textura.region = Rect2(x, y, w, h)
	obj.texture = nova_textura

func count_on_label(label, goal, step, time, is_time = false):
	var aux = 0
	while(aux < goal):
		aux += step
		if is_time:
			label.text = GameManager.time_converter(aux)
		else:
			label.text = str(aux)
		await get_tree().create_timer(time).timeout
	if is_time:		
		label.text = GameManager.time_converter(goal)
	else:
		label.text = str(goal)
	
func execute_tween(obj, param, val, time):
	var tween = create_tween()
	tween.tween_property(obj, param, val, time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func execute_tween_impact(obj, param, val, time):
	var tween = create_tween()
	tween.tween_property(obj, param, val, time).set_trans(Tween.TRANS_EXPO)
	await tween.finished


func _on_bt_jump_pressed() -> void:
	skip = true
