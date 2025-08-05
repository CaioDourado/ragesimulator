extends Node2D

@export var item : PackedScene
@export var intervalo: float = 2.0
@onready var timer: Timer = $Timer
@onready var target_position : Node2D = $TargetPosition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = intervalo
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	if item:
		var novo_objeto = item.instantiate()
		add_child(novo_objeto)
		novo_objeto.global_position = target_position.global_position
