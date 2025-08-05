extends Camera2D

var limit_top_now = -196
var limit_bottom_now = 20
var target: Node2D
@export var follow_speed: float = 5.0

func _process(delta):
	if target != null:
		var distance = global_position.distance_to(target.global_position)
		if distance <= .1:
			global_position = target.global_position
		else:
			global_position = lerp(global_position, target.global_position, follow_speed * delta)

func set_target(no : Node2D):
	target = no
