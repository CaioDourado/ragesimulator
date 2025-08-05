extends StaticBody2D

@onready var static_body : StaticBody2D = $BeltMove
@onready var sprite_render : AnimatedSprite2D = $SpriteRender
@export var speed : float = 100
@export var side : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_belt()
	
func invert() -> void:
	side = !side
	set_belt()
	
func set_belt():
	var now_speed = speed
	sprite_render.flip_h = side
	if side:
		now_speed = speed * -1
	static_body.constant_linear_velocity.x = now_speed
