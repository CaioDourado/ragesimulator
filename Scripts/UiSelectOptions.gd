extends Node

@export var audio_player : AudioStreamPlayer
@export var sound : AudioStreamMP3

@export var textures : Array[Texture2D]
@export var colors : Array[Color]
@export var context_parent_path: NodePath
@export var disable_context: bool = true

var botoes := []
var contextos := []

func _ready() -> void:
	# Carrega botões
	for child in get_children():
		if child is TextureButton:
			if child.name == SaveManager.memory_card.configs.language:
				selectButton(child)
			else:
				unselectButton(child)
			botoes.append(child)
			child.pressed.connect(_on_botao_pressionado.bind(child))
	
	# Carrega contextos, se não estiver desabilitado
	if not disable_context:
		var context_parent = get_node_or_null(context_parent_path)
		if context_parent:
			for child in context_parent.get_children():
				contextos.append(child)
				child.visible = false # Todos começam invisíveis
		contextos[0].visible = true

func _on_botao_pressionado(botao_selecionado):
	play_sound(sound)
	for i in botoes.size():
		var botao = botoes[i]
		
		# Seleciona ou desseleciona visualmente
		if botao == botao_selecionado:
			selectButton(botao)
		else:
			unselectButton(botao)

		# Se contextos estiverem habilitados e existem:
		if not disable_context and i < contextos.size():
			contextos[i].visible = (botao == botao_selecionado)

func selectButton(botao):
	botao.texture_normal = textures[1]
	var label = botao.find_child("Title", true, false)
	if label and label is Label:
		label.label_settings.font_color = colors[1]

func unselectButton(botao):
	botao.texture_normal = textures[0]
	var label = botao.find_child("Title", true, false)
	if label and label is Label:
		label.label_settings.font_color = colors[0]

func play_sound(resource):
	audio_player.stream = resource;
	audio_player.play()
