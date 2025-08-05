extends Resource
class_name StageLibrary

enum QuestFlags { NODEATH, NOCHECKPOINT, NOLEFT }

@export var scene : PackedScene
@export var open : bool = false
@export var quest_time: float
@export var quest_deaths: int
@export var quest_gears: int
@export var tutorial : bool = false

var best_time : float
var deaths : int
var gears_collected : int
var flags : Array[QuestFlags] = []

var quest_status_time = false
var quest_status_gears = false
var quest_status_deaths = false

func get_best_time() -> float:
	return best_time

func get_deaths() -> int:
	return deaths
	
func get_gears_coolected() -> int:
	return gears_collected
	
func get_flags() -> Array:
	var retorno = Array()
	for index in flags:
		retorno.append(str(index))
	return retorno
	
func set_open(o: bool):
	open = o

func set_best_time(t: float):
	best_time = t

func set_deaths(d : int):
	deaths = d
	
func set_gears(g: int):
	gears_collected = g

func set_flags(f: Array):
	pass

func set_quest_status_time(status: bool):
	quest_status_time = status
	
func set_quest_status_gears(status: bool):
	quest_status_gears = status
	
func set_quest_status_deaths(status: bool):
	quest_status_deaths = status
