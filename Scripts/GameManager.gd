extends Node

var first_home = true

var connection_check = null
var connection_status = false
var base_path_stage = "/root/Stage/Content"

var player_lifes : int = 0
var player_deaths : int = 0
var player_keys : int = 0
var player_gears : int = 0

var player: PackedScene = preload("res://Prefab/player_new.tscn")
var home_scene : PackedScene = preload("res://Scenes/Home.tscn")
var settings_scene : PackedScene = preload("res://Scenes/Settings.tscn")
var stages_select : PackedScene = preload("res://Scenes/Stages.tscn")
var stages : StageSelectLibrary = preload("res://Rescources/stage_select_library.tres")

var respawn_obj : StaticBody2D = null
var ending_obj : Area2D = null
var checkpoint_obj : Area2D = null
var camera : Camera2D = null

var chapter_now : int = 0
var stage_now : int = 0

var instantiating = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_connection()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func check_connection():
	if connection_check == null:
		connection_check = HTTPRequest.new()
		add_child(connection_check)
		connection_check.connect("request_completed", _on_request_completed)
	var error = connection_check.request("http://www.google.com")
	if error != OK:
		print("Erro ao enviar a requisição: ", error)
		
func _on_request_completed(result, response_code, headers, body):
	if result == OK and response_code == 200:
		Notifier.notificar("Conectado a internet")
		connection_status = true
	else:
		Notifier.notificar("Sem Conexão Internet")
		connection_status = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		await get_tree().create_timer(.1).timeout
		pause_game()
	
func go_to_stages():
	Loading.change_scene_swipe(stages_select,"left")
	
func go_to_settings():
	Loading.change_scene_swipe(settings_scene,"right")
	
func play_now():
	checkpoint_obj = null
	call_deferred("scene_play_now")
	
func scene_play_now():
	player_lifes = 5
	player_deaths = 0
	player_gears = 0
	player_keys = 0
	if(stages.chapters[chapter_now].stages[stage_now].tutorial):
		BgmController.no_music()
	else:
		BgmController.transit_music(chapter_now,-15, 3)
	Loading.change_scene_packed(stages.chapters[chapter_now].stages[stage_now].scene, scene_play_now_respawn)
	
func scene_play_now_no_trans():
	player_lifes = 5
	player_deaths = 0
	player_gears = 0
	player_keys = 0
	get_tree().change_scene_to_packed(stages.chapters[chapter_now].stages[stage_now].scene)
	scene_play_now_respawn()

func scene_play_now_respawn():
	await get_tree().process_frame
	await get_tree().process_frame
	camera = get_node_or_null(stage_path("Camera"))
	respawn_obj = get_node_or_null(stage_path("StartPoint"))
	ending_obj = get_node_or_null(stage_path("EndPoint"))
	if not stages.chapters[chapter_now].stages[stage_now].tutorial:
		await get_tree().create_timer(2.3).timeout
	else:
		await get_tree().create_timer(0.8).timeout
	respawn()

func respawn():
	var plnow = get_player()
	if plnow == null:
		instantiatePlayer()
	else:
		if player_lifes > 0:
			plnow.disable_collision()
			freeze_time(0.03, 1.0)
			plnow.die()
			await get_tree().create_timer(.4).timeout
			instantiatePlayer()
		else:
			plnow.disable_collision()
			plnow.die()
			await get_tree().create_timer(.4).timeout
			openAdContinue()
			
func openAdContinue():
	player_lifes = 0
	get_node(stage_path("UI")).att_label_lifes()
	get_node(stage_path("AdContinue")).open()
	
func adContinue():
	player_lifes += 5
	get_node(stage_path("UI")).att_label_lifes()
	get_tree().paused = false
	get_node(stage_path("AdContinue")).close()
	respawn()

func adContinueFail():
	get_node(stage_path("AdContinue")).open()

func adContinueGameOver():
	get_node(stage_path("AdContinue")).gameover()

func setCamPlayer(pl: Node2D):
	camera.set_target(pl)
	
func setCheckPoint(cp : Area2D) -> float:
	checkpoint_obj = cp
	return get_node(stage_path("UI")).get_timer()
	
func instantiatePlayer():
	if not instantiating:
		instantiating = true
		var pl : CharacterBody2D = player.instantiate()
		var current_scene = get_node_or_null(stage_path(""))
		if checkpoint_obj:
			pl.global_position = checkpoint_obj.global_position + Vector2(0, -32)
			get_node(stage_path("UI")).set_timer(checkpoint_obj.get_time_setted())
		else:
			if respawn_obj:
				pl.global_position = respawn_obj.global_position + Vector2(0, -18)
			
		if current_scene:
			current_scene.add_child(pl)
			pl.play_sound(preload("res://Assets/Audio/SFX/respawn.mp3"))
		else:
			print("Erro: Nenhuma cena carregada para instanciar o player.")
			return
		setCamPlayer(pl)
		instantiating = false

func freeze_time(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout
	Engine.time_scale = 1

func get_player() -> Node2D:
	return get_node(stage_path("Player"))

func get_player_lifes() -> int:
	return player_lifes
	
func get_stages() -> StageSelectLibrary:
	return stages
	
func get_chapter_now() -> int:
	return chapter_now
	
func get_stage_now() -> int:
	return stage_now
	
func get_current_stage() -> StageLibrary:
	return stages.chapters[chapter_now].stages[stage_now]
	
func set_stage(i: int, c: int):
	stage_now = i
	chapter_now = c

func player_die():
	player_lifes -= 1
	player_deaths += 1
	get_node(stage_path("UI")).att_label_lifes()

func start_stage():
	get_node(stage_path("UI")).start_timer()
	
# FUNÇÃO QUE FINALIZA A FASE E CONTABILIZA TUDO
func end_stage():
	unlock_next_stage()
	get_node(stage_path("Buttons")).visible = false
	get_node(stage_path("UI")).pause_timer()
	var timer_now = get_node(stage_path("UI")).get_timer()
	SaveManager.save_stage_data(get_node(stage_path("UI")).get_timer(), player_deaths, player_gears)
	SaveManager.save_quests()
	SaveManager.save_game()
	if stages.chapters[chapter_now].stages[stage_now].tutorial:
		if stage_now+1 >= stages.chapters[chapter_now].stages.size():
			next_stage()
		else:
			next_stage_no_trans()
	else:
		get_node(stage_path("PosGameUI")).finish_stage(timer_now, player_gears, player_deaths, stage_now)

func unlock_next_stage():
	var unlock_chap = chapter_now
	var unlock_stage = stage_now + 1
	if unlock_stage >= stages.chapters[unlock_chap].stages.size():
		unlock_chap += 1
		unlock_stage = 0
	
	if unlock_chap < stages.chapters.size():
		if unlock_stage < stages.chapters[unlock_chap].stages.size():
			stages.chapters[unlock_chap].stages[unlock_stage].open = true
			SaveManager.save_stage_open(unlock_chap, unlock_stage)

func check_stage_quests() -> Array:
	var stage_data : StageLibrary = stages.chapters[chapter_now].stages[stage_now]
	# clock, gear, deaths
	var data_return = [false, false, false]
	var timer_now = get_node(stage_path("UI")).get_timer()
	if timer_now < stage_data.quest_time:
		data_return[0] = true
	if player_gears == stage_data.quest_gears:
		data_return[1] = true
	if player_deaths < stage_data.quest_deaths:
		data_return[2] = true
	return data_return

func go_to_home():
	if get_tree().current_scene.name == "Stages" or get_tree().current_scene.name == "Settings":
		if get_tree().current_scene.name == "Stages":
			Loading.change_scene_swipe(home_scene,"right")
		else:
			Loading.change_scene_swipe(home_scene,"left")
	else:
		Loading.change_scene_replaced(home_scene)

func pause_game():
	var pause_node = get_node_or_null(stage_path("UI"))
	if pause_node != null:
		get_node(stage_path("UI")).pause_timer()
		get_node(stage_path("PauseMenu")).pause_game()

func next_stage():
	stage_now += 1
	if stage_now >= stages.chapters[chapter_now].stages.size():
		chapter_now += 1
		stage_now = 0
	checkpoint_obj = null
	call_deferred("scene_play_now")
	
func next_stage_no_trans():
	stage_now += 1
	if stage_now >= stages.chapters[chapter_now].stages.size():
		chapter_now += 1
		stage_now = 0
	checkpoint_obj = null
	call_deferred("scene_play_now_no_trans")

func finish_stage():
	get_node(stage_path("UI")).pause_timer()
	get_player().set_ending()

func stage_path(path : String) -> String:
	return str(base_path_stage,"/",path)

func time_converter(tempo_decorrido: float) -> String:
	var minutos = int(tempo_decorrido) / 60
	var segundos = int(tempo_decorrido) % 60
	var milissegundos = int((tempo_decorrido - int(tempo_decorrido)) * 1000)
	return "%02d:%02d:%03d" % [minutos, segundos, milissegundos]
	
func add_key():
	player_keys += 1

func use_key_old():
	if player_keys > 0:
		player_keys -= 1
		return true
	else:
		return false

func get_keys():
	return player_keys

func add_gear():
	player_gears += 1
	
func get_gears():
	return player_gears
	
func animation_add_gear(item_texture: Texture, pos_inicial: Vector2, index: int = 0):
	anim_add_collectable("gear",item_texture, pos_inicial, "UI/Control/Gears", Rect2(0, 0, 32, 32), true, 
		func():
			player_gears += 1
			#get_node(stage_path("UI")).att_label_gears()
			get_node(stage_path("UI")).att_label_gears(index)
	)

func animation_add_key(item_texture: Texture, pos_inicial: Vector2):
	anim_add_collectable("key",item_texture, pos_inicial, "UI/Control/KeyPosition", Rect2(0, 0, 32, 32), false,
		func():
			add_key()
	)

func anim_add_collectable(type: String, item_texture: Texture, pos_inicial: Vector2, nodePath : String, spriteAtlas : Rect2, delete: bool, callable: Callable):
	var ui_inventory =  get_node(stage_path(nodePath))
	var item_ui = TextureRect.new()
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = item_texture
	atlas_texture.region = spriteAtlas
	item_ui.texture = atlas_texture
	item_ui.use_parent_material = true
	
	item_ui.anchor_left = 0.0
	item_ui.anchor_right = 0.0
	item_ui.anchor_top = 0.5
	item_ui.anchor_bottom = 0.5
	var position_x_item = 0
	if type=="key":
		item_ui.size = Vector2(48, 48)
		if(player_keys>0):
			position_x_item = player_keys * 32
	if type=="gear":
		item_ui.size = Vector2(32, 32)
		position_x_item = player_gears * 32
	item_ui.position = Vector2(position_x_item, -item_ui.size.y / 2)
	
	ui_inventory.add_child(item_ui)
	
	var destino_ui = item_ui.position
	var pos_inicial_ui = converter_mundo_para_ui(pos_inicial)
	item_ui.position = pos_inicial_ui - ui_inventory.global_position
	var tween = create_tween()
	tween.tween_property(item_ui, "position", destino_ui, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	if delete:
		item_ui.queue_free()
		
	callable.call()

func use_key(pos_final: Vector2, callable: Callable):
	if player_keys > 0:
		var ui_node = get_node(stage_path("UI"))
		var keys = get_node(stage_path("UI/Control/KeyPosition"))
		var last_key : TextureRect = keys.get_child(keys.get_child_count() - 1)
		
		if last_key:
			print(last_key.size)
			var pos_inicial_ui = last_key.global_position
			print(pos_inicial_ui)
			
			#var pos_inicial_world = last_key.get_viewport().get_canvas_transform().affine_inverse().get_origin() + Vector2(last_key.size.x/2,40)
			var canvas_transform_inverso = last_key.get_viewport().get_canvas_transform().affine_inverse()
			print(canvas_transform_inverso.origin)
			var pos_inicial_world = canvas_transform_inverso.origin + Vector2(21,76)
			print(pos_inicial_world)
			
			var item_copy = Sprite2D.new()
			item_copy.texture = last_key.texture
			item_copy.global_position = pos_inicial_world
			item_copy.scale = Vector2(.5,.5)
			last_key.queue_free()
			get_node(stage_path("")).add_child(item_copy)
			
			var tween = create_tween()
			ui_node.play_swap()
			tween.tween_property(item_copy, "global_position", pos_final, .5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(item_copy, "modulate", Color(1,1,1,0), 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
			await tween.finished
			item_copy.queue_free()
			player_keys -= 1
			callable.call()
	

func converter_mundo_para_ui(posicao_global: Vector2) -> Vector2:
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	
	if camera:
		var canvas_transform = viewport.get_canvas_transform()
		return canvas_transform * posicao_global
	return Vector2.ZERO

func save_game():
	SaveManager.save_game()

func set_first_home(status: bool):
	first_home = status
	
