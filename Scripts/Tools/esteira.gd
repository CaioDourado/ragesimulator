@tool
extends Node2D
class_name Esteira

@export_range(1, 12, 1)
var comprimento: int = 2 : set = set_comprimento

@export var espacamento: float = 32.0 : set = set_espacamento
@export var speed: float = 100.0 : set = set_speed
@export var side: bool = false : set = set_side

@export var template_sprite_path: NodePath = "CenterHolder/Template"
@export var collision_path: NodePath = "Collider"
@export var static_body_path: NodePath = "BeltMove"
@export var force_path: NodePath = "BeltMove/ForceCollider"

var left: AnimatedSprite2D
var right: AnimatedSprite2D
var centro_holder: Node2D
var template_sprite: AnimatedSprite2D
var collider_shape: CollisionShape2D
var static_body: StaticBody2D
var force_shape: CollisionShape2D

func _ready():
	_atualizar()
	if !Engine.is_editor_hint():
		_aplicar_forca()

func set_comprimento(value):
	comprimento = value
	_atualizar()

func set_espacamento(value):
	espacamento = value
	_atualizar()

func set_speed(value):
	speed = value
	if Engine.is_editor_hint():
		_atualizar()
	else:
		_aplicar_forca()

func set_side(value):
	side = value
	if Engine.is_editor_hint():
		_atualizar()
	else:
		_aplicar_forca()

func _atualizar():
	left = get_node_or_null("Left")
	right = get_node_or_null("Right")
	centro_holder = get_node_or_null("CenterHolder")
	if !centro_holder:
		return
	template_sprite = centro_holder.get_node_or_null("Template")
	collider_shape = get_node_or_null(collision_path)
	static_body = get_node_or_null(static_body_path)
	force_shape = get_node_or_null(force_path)

	if !left or !right or !centro_holder or !template_sprite:
		return

	# Limpa blocos anteriores (exceto o template)
	for child in centro_holder.get_children():
		if child.name != "Template":
			child.queue_free()

	# Cria os blocos centrais
	for i in range(1, comprimento):
		var clone = template_sprite.duplicate(true)
		clone.visible = true
		clone.position.x = espacamento * i
		clone.flip_h = side
		centro_holder.add_child(clone)

	# Move o Right pro final
	

	# Ajusta tamanho da colisão
	if force_shape and force_shape.shape is RectangleShape2D:
		var shape = force_shape.shape.duplicate()
		shape.size.x = espacamento * comprimento + 32
		force_shape.shape = shape
		force_shape.position.x = shape.size.x / 2.0 - 16

	if collider_shape and collider_shape.shape is RectangleShape2D:
		var shape = collider_shape.shape.duplicate()
		shape.size.x = espacamento * comprimento + 32
		collider_shape.shape = shape
		collider_shape.position.x = shape.size.x / 2.0 - 16
	
	if side:
		left.position.x = espacamento * comprimento
		right.position.x = 0
	else:
		right.position.x = espacamento * comprimento
		left.position.x = 0
	left.flip_h = side
	right.flip_h = side
		

	_aplicar_forca()

func _aplicar_forca():
	if Engine.is_editor_hint():
		return
	if !static_body or !is_instance_valid(static_body):
		return

	var vel = -speed if side else speed
	static_body.constant_linear_velocity.x = vel
