extends CanvasLayer

@onready var animator : AnimationPlayer = $Animator
@onready var leftdoor : TextureRect = $Control/LeftDoor
@onready var rightdoor : TextureRect = $Control/RightDoor

@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	pass
	#reconfig_viewport()
	#setAnimationIndex("close","Control/RightDoor:position",[[1, Vector2(viewport_size.x/2 - rightdoor.get_viewport_transform().basis_xform(rightdoor.size).x/2,0)]])
	#setAnimationIndex("close","Control/LeftDoor:position",[[1, Vector2(0,0)]])
	#setAnimationIndex("close","Control/RightDoor:position",[[1, Vector2(viewport_size.x/2 - rightdoor.get_viewport_transform().basis_xform(rightdoor.size).x/2,0)]])

func change_scene(target: String, callback: Callable) -> void:
	#reconfig_viewport()
	$Animator.play("close")
	await $Animator.animation_finished
	get_tree().change_scene_to_file(target)
	$Animator.play("open")
	callback.call()

func change_scene_packed(target: PackedScene, callback: Callable) -> void:
	#reconfig_viewport()
	$Animator.play("close")
	await $Animator.animation_finished
	get_tree().change_scene_to_packed(target)
	$Animator.play("open")
	callback.call()

func change_scene_replaced(target: PackedScene) -> void:
	#reconfig_viewport()
	$Animator.play("close")
	await $Animator.animation_finished
	get_tree().paused = false
	var new_scene = target.instantiate()
	
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
	$Animator.play("open")
	
func change_scene_replaced_fade(target: PackedScene) -> void:
	$Animator.play("fade")
	await get_tree().create_timer(.4).timeout
	get_tree().paused = false
	#await $Animator.animation_finished
	var new_scene = target.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
	
func change_scene_swipe(target: PackedScene, direction: String = "up") -> void:
	var current_instance = get_tree().current_scene
	var new_instance = target.instantiate()

	var current_node = current_instance.get_node_or_null("CanvasLayer").get_child(0)
	var new_node = new_instance.get_node_or_null("CanvasLayer").get_child(0)

	get_tree().root.add_child(new_instance)

	var screen_size = get_viewport().get_visible_rect().size
	var offset = Vector2.ZERO

	match direction:
		"up":
			offset = Vector2(0, -screen_size.y)
		"down":
			offset = Vector2(0, screen_size.y)
		"left":
			offset = Vector2(-screen_size.x, 0)
		"right":
			offset = Vector2(screen_size.x, 0)
		_:
			push_error("Direção inválida: use 'up', 'down', 'left' ou 'right'")
			return

	# Define a posição inicial da nova cena (fora da tela, na direção oposta ao swipe)
	new_node.position = -offset

	# Cria tween paralelo
	var tween = create_tween().set_parallel(true)
	tween.tween_property(current_node, "position", offset, 0.5)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(new_node, "position", Vector2(0, 0), 0.5)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	current_instance.queue_free()
	get_tree().current_scene = new_instance

func setAnimationIndex(animation_name: String, path : String, indexs : Array):
	var animation = animator.get_animation(animation_name)
	var track_index = animation.find_track(path, Animation.TYPE_VALUE)
	if track_index != -1:
		for index in indexs:
			animation.track_set_key_value(track_index, index[0], index[1])

func reconfig_viewport():
	var viewport_size = get_viewport().size
	var lfdoor = leftdoor.get_viewport_transform().basis_xform(leftdoor.size)
	var rtdoor = rightdoor.get_viewport_transform().basis_xform(rightdoor.size)
	
	var lfModif = (viewport_size.x/2) - lfdoor.x
	var rtModif = (viewport_size.x/2) - rtdoor.x
	
	var lf_new_pos = Vector2(((viewport_size.x/2) + lfdoor.x) * -1,0)
	setAnimationIndex("idle","Control/LeftDoor:position",[[0, lf_new_pos]])
	setAnimationIndex("close","Control/LeftDoor:position",[[0, lf_new_pos]])
	setAnimationIndex("open","Control/LeftDoor:position",[[2, lf_new_pos]])
	
	var rt_new_pos = Vector2((viewport_size.x/2),0)
	setAnimationIndex("idle","Control/RightDoor:position",[[0, rt_new_pos]])
	setAnimationIndex("close","Control/RightDoor:position",[[0, rt_new_pos]])
	setAnimationIndex("open","Control/RightDoor:position",[[2, rt_new_pos]])

func playDoorClose():
	audio_player.stream = preload("res://Assets/Audio/UI/DoorClose.mp3")
	audio_player.play()

func playDoorOpen():
	audio_player.stream = preload("res://Assets/Audio/UI/DoorOpen.mp3")
	audio_player.play()
