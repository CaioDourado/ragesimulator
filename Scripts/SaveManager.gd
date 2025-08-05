extends Node

var memory_card = null
var deaths = 0
var chapter_now = 0
var stage_now = 0

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")

func create_save():
	memory_card = {
		"characters" : {},
		#"stageselect" : Util.stage_select_to_dict(GameManager.get_stages()),
		"stageselect" : Util.stage_select_to_dict(GameManager.get_stages(), true),
		"achievements": {},
		"configs" : {
			"audio_sfx" : 0,
			"audio_music" : 0,
			"language" : "pt_BR"
		},
		"purchases": {},
		"noad" : false
	}
	save_local()

func save_local():
	var path = "user://memorycard.json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(memory_card)
		print(json_string)
		file.store_string(json_string)
		file.close()
	else:
		print("Não foi possível gerar um memorycard o arquivo para escrita.")
		
func load_local():
	var path = "user://memorycard.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var result = JSON.parse_string(json_string)
			if not result.has("erro"):
				return result as Dictionary
			else:
				print("Erro ao fazer parse do JSON:", result.error_string)
				return null
		else:
			print("Não foi possível abrir o arquivo para leitura.")
			return null
	else:
		print("Arquivo não existe, retornando dados padrão.")
		return null

func save_game():
	save_local()
	if OS.get_name() == "Android":
		GooglePlayServices.saveData(memory_card)

func get_save():
	return memory_card
	
func load_save(data: Dictionary):
	var last : Vector2
	var first = true
	var stages : StageSelectLibrary = GameManager.get_stages()
	memory_card = data
	for i in memory_card.stageselect.chapters.size():
		for j in memory_card.stageselect.chapters[i].stages.size():
			stages.chapters[i].stages[j].set_open(memory_card.stageselect.chapters[i].stages[j].open)
			stages.chapters[i].stages[j].set_best_time(memory_card.stageselect.chapters[i].stages[j].best_time)
			stages.chapters[i].stages[j].set_deaths(memory_card.stageselect.chapters[i].stages[j].deaths)
			stages.chapters[i].stages[j].set_gears(memory_card.stageselect.chapters[i].stages[j].gears)
			
			if memory_card.stageselect.chapters[i].stages[j].has("quest_status_time"):
				stages.chapters[i].stages[j].set_quest_status_time(memory_card.stageselect.chapters[i].stages[j].quest_status_time)
			else:
				memory_card.stageselect.chapters[i].stages[j].quest_status_time = false
				
			if memory_card.stageselect.chapters[i].stages[j].has("quest_status_gears"):
				stages.chapters[i].stages[j].set_quest_status_gears(memory_card.stageselect.chapters[i].stages[j].quest_status_gears)
			else:
				memory_card.stageselect.chapters[i].stages[j].quest_status_gears = false
				
			if memory_card.stageselect.chapters[i].stages[j].has("quest_status_deaths"):
				stages.chapters[i].stages[j].set_quest_status_deaths(memory_card.stageselect.chapters[i].stages[j].quest_status_deaths)
			else:
				memory_card.stageselect.chapters[i].stages[j].quest_status_deaths = false
				
			deaths += memory_card.stageselect.chapters[i].stages[j].deaths
	
	for i in stages.chapters.size():
		for j in stages.chapters[i].stages.size():
			if first and stages.chapters[i].stages[j].open == false:
				first = false
				GameManager.chapter_now = last.x
				GameManager.stage_now = last.y
			last = Vector2(i,j)
				
	
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, memory_card.configs.audio_music)
	AudioServer.set_bus_mute(MUSIC_BUS_ID, memory_card.configs.audio_music < -9)
	
	AudioServer.set_bus_volume_db(SFX_BUS_ID, memory_card.configs.audio_sfx)
	AudioServer.set_bus_mute(SFX_BUS_ID, memory_card.configs.audio_sfx < -9)
	
	TranslationServer.set_locale(memory_card.configs.language)
			
	if first == true:
		GameManager.chapter_now = (stages.chapters.size()-1)
		GameManager.stage_now = (stages.chapters[GameManager.chapter_now].stages.size()-1)

func save_stage_open(c: int, s: int):
	print("==> Game: Save new Stage Open")
	sync_memory_card_to_stageselect()
	memory_card.stageselect.chapters[c].stages[s].open = true
	GameManager.get_stages().chapters[c].stages[s].set_open(true)
	
func save_stage_data(time: float, deaths: int, gears: int):
	var chapter_now = GameManager.get_chapter_now()
	var stage_now = GameManager.get_stage_now()
	
	if memory_card.stageselect.chapters[chapter_now].stages[stage_now].best_time == 0:
		memory_card.stageselect.chapters[chapter_now].stages[stage_now].best_time = time
		GameManager.get_stages().chapters[chapter_now].stages[stage_now].set_best_time(time)
	elif time < memory_card.stageselect.chapters[chapter_now].stages[stage_now].best_time:
		memory_card.stageselect.chapters[chapter_now].stages[stage_now].best_time = time
		GameManager.get_stages().chapters[chapter_now].stages[stage_now].set_best_time(time)
		
	memory_card.stageselect.chapters[chapter_now].stages[stage_now].deaths += deaths
	var n_deaths = memory_card.stageselect.chapters[chapter_now].stages[stage_now].deaths
	GameManager.get_stages().chapters[chapter_now].stages[stage_now].set_deaths(n_deaths)
	
	if gears > memory_card.stageselect.chapters[chapter_now].stages[stage_now].gears:
		memory_card.stageselect.chapters[chapter_now].stages[stage_now].gears = gears
		GameManager.get_stages().chapters[chapter_now].stages[stage_now].set_gears(gears)

func save_quests():
	var chapter_now = GameManager.get_chapter_now()
	var stage_now = GameManager.get_stage_now()
	var quests = GameManager.check_stage_quests()
	
	memory_card.stageselect.chapters[chapter_now].stages[stage_now].quest_status_time = quests[0]
	memory_card.stageselect.chapters[chapter_now].stages[stage_now].quest_status_gears = quests[1]
	memory_card.stageselect.chapters[chapter_now].stages[stage_now].quest_status_deaths = quests[2]
	
	GameManager.get_stages().chapters[chapter_now].stages[stage_now].quest_status_time = quests[0]
	GameManager.get_stages().chapters[chapter_now].stages[stage_now].quest_status_gears = quests[1]
	GameManager.get_stages().chapters[chapter_now].stages[stage_now].quest_status_deaths = quests[2]

func delete_save():
	var file_name = "user://memorycard.json"
	var dir = DirAccess.open("user://")
	if dir:
		if dir.file_exists(file_name):
			var err = dir.remove_absolute(file_name)
			if err == OK:
				print("Arquivo de save excluído com sucesso!")
			else:
				print("Falha ao excluir o arquivo, erro:", err)
		else:
			print("Arquivo de save não existe.")
	else:
		print("Não foi possível acessar a pasta user://")

func sync_memory_card_to_stageselect():
	var stages = GameManager.get_stages()
	for i in range(stages.chapters.size()):
		if has_index(memory_card.stageselect.chapters, i):
			for j in range(stages.chapters[i].stages.size()):
				if not has_index(memory_card.stageselect.chapters[i].stages, j):
					var stg_n = Util.stage_to_dict(stages.chapters[i].stages[j])
					memory_card.stageselect.chapters[i].stages.append(stg_n)
		else:
			var cpt_n = Util.chapter_to_dict(stages.chapters[i])
			memory_card.stageselect.chapters.append(cpt_n)
	save_game()
					
func has_index(array: Array, index: int) -> bool:
	return index >= 0 and index < array.size()
