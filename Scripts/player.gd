extends CharacterBody2D

var entrance : bool = true
var ending : bool = false
var dead : bool = false

var jump_pressed : bool = false
var jump_time : float = 0.0

var sliding : bool = false
var sliding_side = 0

@export var MAX_JUMP_HOLD_TIME : float = 0.25 # até quanto tempo o pulo pode ser segurado
@export var JUMP_HOLD_FORCE : float = 400.0   # força adicional enquanto segura

@export var SPEED : float
@export var JUMP_VELOCITY : float
@export var SLIDE_VELOCITY : float = 2

@onready var spawner : StaticBody2D = $"../StartRespawn"
@onready var sr : Sprite2D = $SpriteRenderer
@onready var animator : AnimationPlayer = $Animator
@onready var collider : CollisionShape2D = $CollisionShape2D

@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var idle_time : float = 0

func _ready() -> void:
	dead = false

func _physics_process(delta: float) -> void:
	if entrance:
		animator.play("entrance")
	else:
		if ending:
			animator.play("ending")
		else:
			if not dead:
				if not is_on_floor():
					velocity += get_gravity() * delta
					
				if is_on_floor():
					sliding = false
					
				# Início do pulo
				if Input.is_action_just_pressed("ui_jump") and is_on_floor():
					play_sound(preload("res://Assets/Audio/SFX/jump5.mp3"))
					velocity.y = JUMP_VELOCITY * -1
					jump_pressed = true
					jump_time = 0.0

				# Enquanto estiver segurando o pulo
				if Input.is_action_pressed("ui_jump") and jump_pressed:
					jump_time += delta
					if jump_time <= MAX_JUMP_HOLD_TIME:
						velocity.y -= JUMP_HOLD_FORCE * delta
					else:
						jump_pressed = false

				#if Input.is_action_just_pressed("ui_jump") and sliding and not is_on_floor():
					#if sliding_side != 0:
						#if sliding_side == -1:
							#velocity = Vector2(200, -200)
						#else:
							#velocity = Vector2(-200, -200)
							
				# Soltou o botão antes do tempo máximo
				if Input.is_action_just_released("ui_jump"):
					jump_pressed = false

				var direction := Input.get_axis("ui_left", "ui_right")
				if direction:
					if not is_on_floor():
						velocity.x = direction * SPEED * 1.5
					else:
						velocity.x = direction * SPEED
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED)
					
				animation(delta)
				move_and_slide()
				check_fall_die()
			else:
				collider.disabled = true
				velocity = Vector2(0,0)
				animator.play("die")


func animation(delta: float):
	if not is_on_floor():
		if not sliding:
			if velocity.y > 0:
				animator.play("fall")
			else:
				animator.play("jump")
		else:
			animator.play("slide")
	else:
		if velocity.x != 0:
			idle_time = 0
			if velocity.x < 0:
				sr.flip_h = true
			else:
				sr.flip_h = false
			animator.play("walk")
		else:
			idle_time += delta
			if idle_time < 10:
				animator.play("idle")
			else:
				animator.play("idle2")

func check_fall_die():
	if position.y > 20:
		GameManager.respawn()
		
func die():
	dead = true;

func _on_animator_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"die":
			GameManager.player_die()
			queue_free()
		"entrance":
			entrance = false
			GameManager.start_stage()
		"ending":
			GameManager.end_stage()
			queue_free()
		"idle":
			animator.play("idle2")
			
func set_ending():
	ending = true

func disable_collision():
	collider.disabled = true

func play_sound(source):
	audio_player.stream = source
	audio_player.play()

func play_death_sound():
	play_sound(preload("res://Assets/Audio/SFX/death.mp3"))

func _on_area_esquerda_body_entered(body: Node2D) -> void:
	if body.is_in_group("Parede"):
		sliding = true
		sliding_side = -1
		
func _on_area_direita_body_entered(body: Node2D) -> void:
	if body.is_in_group("Parede"):
		sliding = true
		sliding_side = 1

func _on_area_esquerda_body_exited(body: Node2D) -> void:
	if body.is_in_group("Parede"):
		sliding = false
		sliding_side = 0

func _on_area_direita_body_exited(body: Node2D) -> void:
	if body.is_in_group("Parede"):
		sliding = false
		sliding_side = 0
