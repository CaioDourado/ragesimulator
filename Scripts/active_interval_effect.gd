extends Control

@export var tempo : float = 1.0
var blink_timer: Timer

func _ready() -> void:
	visible = false
	blink_timer = Timer.new()
	blink_timer.wait_time = tempo
	blink_timer.autostart = true
	blink_timer.one_shot = false
	add_child(blink_timer)
	blink_timer.timeout.connect(_on_timer_timeout)
	
func _on_timer_timeout() -> void:
	visible = not visible  # Alterna visibilidade (true/false)
