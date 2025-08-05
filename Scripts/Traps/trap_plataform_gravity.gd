extends Area2D

@onready var plataform : RigidBody2D = $RigidBody2D
var active : bool = false

func _ready() -> void:
	plataform.gravity_scale = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		plataform.gravity_scale = 1

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		active = true
