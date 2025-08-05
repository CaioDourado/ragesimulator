extends Node2D

var selected_chapter : int = 0
var selected_stage : int  = 0

@export var lights : Array[TextureRect]

@onready var bt_back : TextureButton = $CanvasLayer/Control/Device/BtBack
@onready var bt_play : TextureButton = $CanvasLayer/Control/Device/BtPlay

@onready var btLeft : TextureButton = $CanvasLayer/Control/Device/Screen/BtLeft
@onready var btRight : TextureButton = $CanvasLayer/Control/Device/Screen/BtRight
@onready var title : Label = $CanvasLayer/Control/Device/Screen/TitleImg/Title
@onready var stages_node : Control = $CanvasLayer/Control/Device/ScreenBackground/BtStages/Grid

@onready var lbclock : Label = $CanvasLayer/Control/Device/Screen/ClockIcon/Label
@onready var lbdeath : Label = $CanvasLayer/Control/Device/Screen/DeathsIcon/Label
@onready var lbgear : Label = $CanvasLayer/Control/Device/Screen/GearsIcon/Label
@onready var lbtotalcheck : Label = $CanvasLayer/Control/Device/ScreenBackground/TotalChecks

@onready var audio_player : AudioStreamPlayer = $CanvasLayer/AudioStreamPlayer

var bt_stage: PackedScene = preload("res://Prefab/bt_stage.tscn")
var btns : Array[TextureButton]
var totalcheckeds = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bt_play.disabled = false
	bt_back.disabled = false
	selected_chapter = GameManager.get_chapter_now()
	selected_stage = GameManager.get_stage_now()
	att_screen()
			
func att_screen() -> void:
	totalcheckeds = 0
	clear_screen()
	if selected_chapter > 0:
		title.text = str(tr("help_capitulo")," ",selected_chapter,": ",tr(GameManager.get_stages().chapters[selected_chapter].name))
	else:
		title.text = tr(GameManager.get_stages().chapters[selected_chapter].name)
	var stages : Array[StageLibrary] = GameManager.get_stages().chapters[selected_chapter].stages
	for i in stages.size():
		var btn : TextureButton = bt_stage.instantiate()
		btns.append(btns)
		var str_nbr = str(i+1)
		if i+1 < 10:
			str_nbr = str("0",str_nbr)
		btn.set_data(i, stages[i].open, str_nbr, stages[i].tutorial, stages[i].quest_status_time, stages[i].quest_status_gears, stages[i].quest_status_deaths)
		stages_node.add_child(btn)
		if i == selected_stage:
			btn.select()
		if stages[i].quest_status_time: totalcheckeds+=1
		if stages[i].quest_status_gears: totalcheckeds+=1
		if stages[i].quest_status_deaths: totalcheckeds+=1
		
	lbtotalcheck.text = str(totalcheckeds)
	if selected_chapter<=0:
		lbtotalcheck.visible = false
	else:
		lbtotalcheck.visible = true
			
	if (selected_chapter+1) >= GameManager.get_stages().chapters.size():
		btRight.visible = false
	else:
		btRight.visible = true
		
	if selected_chapter <= 0:
		btLeft.visible = false
	else:
		btLeft.visible = true
			
func clear_screen():
	btns.clear()
	for child in stages_node.get_children():
		child.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_bt_back_pressed() -> void:
	bt_back.disabled = true
	play_sound(preload("res://Assets/Audio/UI/Button1.mp3"))
	await audio_player.finished
	GameManager.go_to_home()

func _on_bt_play_pressed() -> void:
	if selected_stage != -1:
		bt_play.disabled = true
		play_sound(preload("res://Assets/Audio/UI/Button1.mp3"))
		await audio_player.finished
		if GameManager.get_stages().chapters[selected_chapter].stages[selected_stage].open:
			GameManager.set_stage(selected_stage, selected_chapter)
			GameManager.play_now()
		else:
			var last_stg = get_last_stage()
			GameManager.set_stage(last_stg[1], last_stg[0])
			GameManager.play_now()

func set_chapter(i : int):
	selected_chapter = i
	
func set_stage(i : int):
	selected_stage = i
	var quest_number = 0
	var stages : StageSelectLibrary = GameManager.get_stages()
	var stage_now : StageLibrary = stages.chapters[selected_chapter].stages[selected_stage]
	lbclock.text = str(GameManager.time_converter(stage_now.best_time))
	lbdeath.text = str(stage_now.deaths)
	lbgear.text = str(stage_now.gears_collected,"/",stage_now.quest_gears)
	
	if(stage_now.quest_status_time): quest_number += 1
	if(stage_now.quest_status_gears): quest_number += 1
	if(stage_now.quest_status_deaths): quest_number += 1
	
	match(quest_number):
		0: 
			lights[0].visible = false
			lights[1].visible = false
			lights[2].visible = false
		1:
			lights[0].visible = true
			lights[1].visible = false
			lights[2].visible = false
		2:
			lights[0].visible = true
			lights[1].visible = true
			lights[2].visible = false
		3:
			lights[0].visible = true
			lights[1].visible = true
			lights[2].visible = true

func _on_bt_left_pressed() -> void:
	if selected_chapter > 0:
		selected_chapter -= 1
		selected_stage = 0
		play_sound(preload("res://Assets/Audio/UI/Touch1.mp3"))
		att_screen()

func _on_bt_right_pressed() -> void:
	if selected_chapter < GameManager.get_stages().chapters.size():
		selected_chapter += 1
		selected_stage = 0
		play_sound(preload("res://Assets/Audio/UI/Touch1.mp3"))
		att_screen()

func play_sound(resource):
	audio_player.stream = resource;
	audio_player.play()

func get_last_stage():
	var last = Vector2(0,0)
	var first = true
	var chapters = GameManager.get_stages().chapters
	for i in chapters.size():
		for j in chapters[i].stages.size():
			if chapters[i].stages[j].open:
				last = Vector2(i,j)
	return last
