extends TextureButton

var number : String
var open : bool
var index : int
var tutorial : bool = false
var selected : bool = false
var quest_time: bool = false
var quest_gears: bool = false
var quest_deaths: bool = false

@onready var nbr : Label = $Number

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if open:
		modulate.a = 1
		change_texture(29,0,29,38);
		if quest_time and quest_gears and quest_deaths:
			change_texture(116,0,29,38)
		else:
			if quest_time and quest_gears:
				change_texture(87,0,29,38)
			else:
				if quest_time and quest_deaths:
					change_texture(203,0,29,38)
				else:
					if quest_gears and quest_deaths:
						change_texture(174,0,29,38)
					else:
						if quest_time:
							change_texture(58,0,29,38)
						if quest_gears:
							change_texture(232,0,29,38)
						if quest_deaths:
							change_texture(261,0,29,38)
		nbr.text = number
		#self.mouse_entered.connect(_on_mouse_entered)
		#self.mouse_exited.connect(_on_mouse_exited)
	else:
		modulate.a = .2
		change_texture(0,0,29,38);
		nbr.text = ""
		
	if tutorial:
		change_texture(145,0,29,38);

#func _on_mouse_entered():
	#if not selected:
		#var tween = get_tree().create_tween()
		#tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)

#func _on_mouse_exited():
	#if not selected:
		#var tween = get_tree().create_tween()
		#tween.tween_property(self, "scale", Vector2(1, 1), 0.15)

func _on_pressed() -> void:
	if open:
		if not selected:
			get_node("/root/Stages").play_sound(preload("res://Assets/Audio/UI/Touch9.mp3"))
			unselect_all()
			select(0)
		#else:
			#selected = false
			#scale = Vector2(1.2,1.2)
		
func select(delay : float = .2):
	await get_tree().create_timer(delay).timeout
	selected = true
	#scale = Vector2(1.5,1.5)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
	var node = get_node("/root/Stages").set_stage(index)

func unselect():
	selected = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)

func unselect_all():
	var node = get_node("/root/Stages/CanvasLayer/Control/Device/ScreenBackground/BtStages/Grid")
	for child in node.get_children():
		child.unselect()

func set_data(i : int, op : bool, nbr : String, tut: bool, qt: bool, qg: bool, qd: bool):
	index = i
	open = op
	number = nbr
	tutorial = tut
	quest_time = qt
	quest_gears = qg
	quest_deaths = qd
	

func change_texture(x: int, y: int, w: int, h: int):
	var atlas_texture = texture_normal
	var nova_textura = atlas_texture.duplicate()
	nova_textura.region = Rect2(x, y, w, h)
	texture_normal = nova_textura
