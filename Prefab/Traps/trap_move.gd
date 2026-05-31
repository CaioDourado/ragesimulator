extends AnimatableBody2D

# --- Inspector ---
@export var move_speed: float = 200.0
@export_enum("Up","Right","Down","Left","Custom") var direction: String = "Down"
@export var custom_direction: Vector2 = Vector2.ZERO
@export var move_distance: float = 0.0      # 0 = infinito (não para)
@export var start_delay: float = 0.0         # atraso após ativar (s)
@export var auto_start: bool = false         # começa sem trigger
@export var trigger_on_player_only: bool = true

# --- Estado interno ---
var _active: bool = false
var _consumed: bool = false       # após completar, nunca mais ativa
var _start_pos: Vector2
var _moved: float = 0.0

func _ready() -> void:
	_start_pos = global_position

	# Conecta trigger (filho Area2D → body_entered)
	if has_node("Area2D"):
		var area: Area2D = $Area2D
		area.body_entered.connect(_on_body_entered)

	if auto_start:
		_activate()

func _physics_process(delta: float) -> void:
	if not _active:
		return

	# Se já atingiu o limite, para e marca como consumido
	if move_distance > 0.0 and _moved >= move_distance:
		_active = false
		_consumed = true
		return

	var dir := _dir_vec().normalized()
	var step := move_speed * delta

	# Clampar para não passar do limite
	if move_distance > 0.0:
		step = min(step, move_distance - _moved)

	global_position += dir * step
	_moved += step

	# Chegou exatamente no limite?
	if move_distance > 0.0 and _moved >= move_distance:
		_active = false
		_consumed = true

func _on_body_entered(body: Node) -> void:
	# Não reativa se já consumiu ou já está ativa
	if _consumed or _active:
		return
	if trigger_on_player_only and not (body is CharacterBody2D):
		return
	_activate()

func _activate() -> void:
	if _active or _consumed:
		return
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
	# Se durante o delay ela foi “consumida”, não ativa
	if _consumed:
		return
	_active = true

func _dir_vec() -> Vector2:
	match direction:
		"Up":    return Vector2.UP
		"Right": return Vector2.RIGHT
		"Down":  return Vector2.DOWN
		"Left":  return Vector2.LEFT
		_:       return custom_direction

# (Opcional) para checkpoints
func reset() -> void:
	_active = false
	_consumed = false
	_moved = 0.0
	global_position = _start_pos
