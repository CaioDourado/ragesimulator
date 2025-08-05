extends Node2D

@onready var press_start : Label = $CanvasLayer/Control/PressStart
@onready var animator : AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var press : Label = $CanvasLayer/Control/PressStart

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BgmController.play_music(0, -10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and press_start.visible:
			BgmController.transit_music(0, -25, 3)
			GameManager.go_to_home()

func playLogoHBT():
	animator.play("pulse")
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property(press, "modulate", Color(1,1,1,1), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(press, "modulate", Color(1,1,1,.5), .5).set_trans(Tween.TRANS_SINE)
