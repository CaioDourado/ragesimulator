# trap_fade_in.gd
extends AnimatableBody2D

@export var fade_time: float = 0.5  # tempo (s) para revelar

var _revealed := false
var _visual: CanvasItem

func _ready() -> void:
	# pega o nó visual (TileMapLayer). Se não achar por nome, tenta o 1º CanvasItem filho
	if has_node("TileMapLayer"):
		_visual = get_node("TileMapLayer") as CanvasItem
	else:
		for c in get_children():
			if c is CanvasItem:
				_visual = c
				break

	if _visual:
		_visual.visible = true
		_visual.modulate.a = 0.0
	else:
		push_error("TrapFadeIn: nó visual (TileMapLayer) não encontrado.")

	# colisão começa desligada até terminar o fade
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true

	# conecta o trigger
	if has_node("Area2D"):
		var area := $Area2D as Area2D
		area.body_entered.connect(_on_trigger_body_entered)
	else:
		push_error("TrapFadeIn: Area2D não encontrado.")

func _on_trigger_body_entered(body: Node) -> void:
	if _revealed:
		return
	# Se quiser que qualquer corpo revele, remova a linha abaixo
	if not (body is CharacterBody2D):
		return
	_reveal()

func _reveal() -> void:
	_revealed = true
	if not _visual:
		return

	if fade_time <= 0.0:
		_visual.modulate.a = 1.0
	else:
		var tw := create_tween()
		tw.tween_property(_visual, "modulate:a", 1.0, fade_time)
		await tw.finished

	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = false
