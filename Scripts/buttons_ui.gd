extends CanvasLayer

@export var desativar : bool = false
@export var timeout : float = 4.5

@onready var bt_left : TouchScreenButton = $Control/Control/BtLeft
@onready var bt_right : TouchScreenButton = $Control/Control/BtRight
@onready var bt_jump : TouchScreenButton = $Control/Control2/BtJump
@onready var bt_pause : TouchScreenButton = $Control/Control3/BtPause

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not desativar:
		disapear_all()
		await get_tree().create_timer(timeout).timeout
		appear_all()
	
func disapear_all():
	bt_left.modulate.a = 0
	bt_right.modulate.a = 0
	bt_jump.modulate.a = 0
	bt_pause.modulate.a = 0

func appear_all():
	var tween := create_tween().set_parallel(true)
	tween.tween_property(bt_left, "modulate", Color(1, 1, 1, 1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bt_right, "modulate", Color(1, 1, 1, 1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bt_jump, "modulate", Color(1, 1, 1, 1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bt_pause, "modulate", Color(1, 1, 1, 1), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
