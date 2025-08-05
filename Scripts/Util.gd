extends Node

func stage_to_dict_zero(stage: StageLibrary) -> Dictionary:
	return {
		"open": false,
		"best_time": 0,
		"deaths": 0,
		"gears": 0,
		"flags": [],
		"quest_status_time": false,
		"quest_status_gears": false,
		"quest_status_deaths": false
	}

func stage_to_dict(stage: StageLibrary) -> Dictionary:
	return {
		"open": stage.open,
		"best_time": stage.get_best_time(),
		"deaths": stage.get_deaths(),
		"gears": stage.get_gears_coolected(),
		"flags": stage.get_flags(),
		"quest_status_time": false,
		"quest_status_gears": false,
		"quest_status_deaths": false
	}

func chapter_to_dict(chapter: ChapterLibrary, zero: bool = false) -> Dictionary:
	var chapter_dict: Dictionary = {}
	#chapter_dict["name"] = chapter.name
	var stages_array: Array = []
	for stage in chapter.stages:
		if zero:
			stages_array.append(stage_to_dict_zero(stage))
		else:
			stages_array.append(stage_to_dict(stage))
	chapter_dict["stages"] = stages_array
	return chapter_dict
	
func stage_select_to_dict(stage_select: StageSelectLibrary, zero: bool = false) -> Dictionary:
	var root_dict: Dictionary = {}
	var chapters_array: Array = []
	for chapter in stage_select.chapters:
		chapters_array.append(chapter_to_dict(chapter, zero))
	root_dict["chapters"] = chapters_array
	root_dict["chapters"][0]["stages"][0].open = true
	return root_dict
