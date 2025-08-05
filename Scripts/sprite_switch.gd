extends TextureRect

@export var texture_main: Texture2D
@export var texture_switch: Texture2D
@export var on_time: float = 1.0     # Tempo com textura ligada
@export var off_time: float = 0.2    # Tempo com textura apagada
@export var start_delay: float = 2.0 # Tempo de espera antes de começar a piscar

var is_on := true
var switch_timer: Timer
var start_timer: Timer

func _ready() -> void:
	# Timer que controla o piscar
	switch_timer = Timer.new()
	switch_timer.one_shot = true
	switch_timer.timeout.connect(_on_switch_timeout)
	add_child(switch_timer)

	# Timer inicial (delay antes de começar)
	start_timer = Timer.new()
	start_timer.one_shot = true
	start_timer.wait_time = start_delay
	start_timer.timeout.connect(_on_start_timeout)
	add_child(start_timer)
	start_timer.start()

	# Começa com a textura principal
	texture = texture_main

func _on_start_timeout() -> void:
	switch_timer.start(on_time)

func _on_switch_timeout() -> void:
	if is_on:
		texture = texture_switch
		switch_timer.start(off_time)
	else:
		texture = texture_main
		switch_timer.start(on_time)
	is_on = !is_on
