extends Node

@export var async : bool = false
@export var self_object : bool = false
@export var self_child : bool = false
@export var start_delay : float = 1.0
@export var delay : float = 0.05
var shader := preload("res://Shader/fadein.gdshader")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self_object:
		preparar_sprite(self)
	else:
		preparar_camadas()
	
	await get_tree().create_timer(start_delay).timeout
	
	if self_object:
		fadein_sprite_da_layer(self)
	else:
		aplicar_fadein_em_camadas()
		
func preparar_camadas() -> void:
	for i in range(1, get_child_count()):
		var layer = get_child(i)
		var sprite = layer.get_node_or_null("texture")
		if sprite:
			preparar_sprite(sprite)

func preparar_sprite(sprite: Node) -> void:
	if sprite.material == null:
		var shader_material := ShaderMaterial.new()
		shader_material.shader = shader
		sprite.material = shader_material
	elif sprite.material is ShaderMaterial:
		sprite.material.shader = shader
		
	sprite.material.set_shader_parameter("reveal_progress", 1.0)
	
func aplicar_fadein_em_camadas() -> void:
	for i in range(1, get_child_count()):
		var layer = self.get_child(i)
		await fadein_sprite_da_layer(layer)
		await get_tree().create_timer(delay).timeout

func fadein_sprite_da_layer(layer: Node) -> void:
	var sprite = layer.get_node_or_null("texture")
		
	if self_object:
		sprite = self
	
	if sprite == null:
		push_warning("Nenhum Sprite2D encontrado em " + str(layer.name))
		return

	if sprite.material == null:
		var shader_material := ShaderMaterial.new()
		shader_material.shader = shader
		sprite.material = shader_material
	elif sprite.material is ShaderMaterial:
		sprite.material.shader = shader

	sprite.material.set_shader_parameter("reveal_progress", 1.0)

	var tween := create_tween().set_parallel(async)
	tween.tween_method(
		func(val): sprite.material.set_shader_parameter("reveal_progress", val),
		1.0, 0.0, 0.3
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	sprite.material = null
