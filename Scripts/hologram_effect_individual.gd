extends Node

@export var desativar : bool = false

@export var sprites: Array[Node]
@export var start_delay: float = 4.0
@export var shader := preload("res://Shader/fadein.gdshader")

func _ready() -> void:
	if not desativar:
		await aplicar_fadein(sprites)

func aplicar_fadein(sprite_list: Array[Node]) -> void:
	var original_materials := {}  # Guarda materiais originais dos sprites

	# Etapa 1: aplicar material com reveal_progress = 1.0
	for sprite in sprite_list:
		if sprite == null or not sprite.has_method("set_material"):
			push_warning("Esse nó não é compatível com materiais: " + str(sprite))
			continue

		# Salva o material original
		original_materials[sprite] = sprite.material

		# Aplica novo material com shader de fadein
		var shader_material := ShaderMaterial.new()
		shader_material.shader = shader
		sprite.material = shader_material
		sprite.material.set_shader_parameter("reveal_progress", 1.0)

	# Espera o delay antes de iniciar a animação
	await get_tree().create_timer(start_delay).timeout

	# Etapa 2: animar todos com tween em paralelo
	var tween := create_tween().set_parallel(true)
	for sprite in sprite_list:
		if sprite == null or sprite.material == null:
			continue
		tween.tween_method(
			func(val): sprite.material.set_shader_parameter("reveal_progress", val),
			1.0, 0.0, 0.5
		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	# Etapa 3: restaurar materiais originais
	for sprite in sprite_list:
		if sprite != null:
			sprite.material = original_materials.get(sprite, null)
