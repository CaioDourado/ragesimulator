extends CharacterBody2D

@export var push_speed: float = 55.0
@export var push_accel: float = 700.0
@export var friction: float = 900.0
@export var gravity: float = 1000.0
@export var fall_gravity_mult: float = 1.0

var push_direction: int = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * (fall_gravity_mult if velocity.y > 0 else 1.0) * delta
	else:
		velocity.y = min(velocity.y, 0.0)

	if push_direction != 0:
		velocity.x = move_toward(velocity.x, push_direction * push_speed, push_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	push_direction = 0
	move_and_slide()

func push(direction: int) -> void:
	push_direction = sign(direction)
