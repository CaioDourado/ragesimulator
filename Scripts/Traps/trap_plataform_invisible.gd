extends Area2D

@onready var sr : Sprite2D = $StaticBody2D/SpriteRenderer
var mat : ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mat = sr.material
	mat.set_shader_parameter("DissolveValue",0.0)
	#sr.self_modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var mat : ShaderMaterial = sr.material
		var tween = create_tween()
		##tween.tween_property(sr, "self_modulate:a", 1.0, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(mat, "shader_parameter/DissolveValue", 1.0, 0.7).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		await tween.finished
