extends CharacterBody2D

# ------------------
# Estados do personagem
# ------------------
var entrance: bool = true
var ending: bool = false
var dead: bool = false

# ------------------
# Efeitos
# ------------------
@export var effects: Array[PackedScene]

# ------------------
# Configurações de movimento
# ------------------
@export var MAX_SPEED: float = 220.0
@export var MAX_SPEED_RUN: float = 300.0
@export var ACCEL: float = 1200.0
@export var FRICTION: float = 1000.0

@export var AIR_ACCEL: float = 1000.0
@export var AIR_FRICTION: float = 600.0

@export var JUMP_VELOCITY: float = -400.0
@export var MIN_JUMP_TIME: float = 0.05
@export var MAX_JUMP_TIME: float = 0.2
@export var WALL_SLIDE_SPEED: float = 80.0
@export var WALL_JUMP_FORCE: Vector2 = Vector2(250, -400)

@export var GRAVITY: float = 1200.0
@export var FALL_GRAVITY_MULT: float = 2.0

# ------------------
# Nodes
# ------------------
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var rc_wall_right: RayCast2D = $RightCast
@onready var rc_wall_left: RayCast2D = $LeftCast
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var sprite_render: Sprite2D = $Sprite2D

# ------------------
# Variáveis de controle
# ------------------
var input_dir: int = 0
var side: bool = false
var running_speed: float = 0.0
var just_wall_jumped: bool = false
var slide_jumping: bool = false
var first_on_floor: bool = false
var grounding: bool = false
var can_coyote: bool = true

# Pulo variável
var jump_held_time: float = 0.0
var is_jumping: bool = false

# ------------------
# Ready
# ------------------
func _ready() -> void:
	dead = false

# ------------------
# Physics Process
# ------------------
func _physics_process(delta: float) -> void:
	if entrance:
		animator.play("entrance")
		return
	elif ending:
		animator.play("ending")
		return
	elif dead:
		collider.disabled = true
		velocity = Vector2.ZERO
		animator.play("die")
		return

	# ------------------
	# Entrada do jogador
	# ------------------
	input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir == -1:
		side = true
	elif input_dir == 1:
		side = false

	var touching_wall := (rc_wall_right.is_colliding() or rc_wall_left.is_colliding()) and not is_on_floor()
	var wall_sliding := touching_wall and velocity.y > 0

	# ------------------
	# Gravidade
	# ------------------
	if is_jumping and not slide_jumping and not wall_sliding and velocity.y < 0 and Input.is_action_pressed("ui_jump"):
		velocity.y = JUMP_VELOCITY
		jump_held_time += delta
		if jump_held_time > MAX_JUMP_TIME:
			is_jumping = false
	else:
		velocity.y += GRAVITY * (FALL_GRAVITY_MULT if velocity.y > 0 else 1.0) * delta
		is_jumping = false

	# ------------------
	# Coyote Timer
	# ------------------
	if not is_on_floor():
		first_on_floor = true
		if can_coyote and coyote_timer.is_stopped():
			coyote_timer.start()
			can_coyote = false
	else:
		slide_jumping = false
		can_coyote = true
		coyote_timer.stop()
		if first_on_floor:
			first_on_floor = false
			grounding = true
			effect_landing()

	# ------------------
	# Wall Slide
	# ------------------
	if wall_sliding:
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)

	just_wall_jumped = false

	# ------------------
	# Pulo / Wall Jump Assistido
	# ------------------
	if Input.is_action_just_pressed("ui_jump"):
		if is_on_floor() or not coyote_timer.is_stopped():
			# Pulo normal
			velocity.y = JUMP_VELOCITY
			is_jumping = true
			jump_held_time = 0.0
			coyote_timer.stop()
		elif wall_sliding:
			# Wall jump assistido, independente do input horizontal
			slide_jumping = true
			animator.play("slide_jump_trans")
			is_jumping = false

			# Aplica força diagonal baseada na parede
			if rc_wall_right.is_colliding():
				velocity.x = -WALL_JUMP_FORCE.x
				side = true
			else:
				velocity.x = WALL_JUMP_FORCE.x
				side = false
			velocity.y = WALL_JUMP_FORCE.y
			just_wall_jumped = true

	# ------------------
	# Movimento horizontal
	# ------------------
	var target_speed = MAX_SPEED_RUN
	if input_dir != 0 and not just_wall_jumped:
		var accel_val = ACCEL if is_on_floor() else AIR_ACCEL
		velocity.x = move_toward(velocity.x, input_dir * target_speed, accel_val * delta)
	elif not just_wall_jumped:
		var friction_val = FRICTION if is_on_floor() else AIR_FRICTION
		velocity.x = move_toward(velocity.x, 0, friction_val * delta)

	# ------------------
	# Animations e movimento
	# ------------------
	animate()
	move_and_slide()
	check_fall_die()

# ------------------
# Animations
# ------------------
func animate():
	sprite_render.flip_h = side
	if is_on_floor():
		if velocity.x != 0:
			grounding = false
			if input_dir == 0:
				animator.play("break")
			else:
				animator.play("walk")
		else:
			if not grounding:
				animator.play("idle")
			else:
				animator.play("ground")
	else:
		if not slide_jumping:
			if rc_wall_left.is_colliding() or rc_wall_right.is_colliding():
				animator.play("slide")
			else:
				if velocity.y > 0:
					animator.play("fall_front" if velocity.x != 0 else "fall")
				else:
					animator.play("jump_front" if velocity.x != 0 else "jump")

# ------------------
# Eventos de animação
# ------------------
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
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
		"slide_jump_trans":
			animator.play("slide_jump")
			effect_walljump()
		"slide_jump":
			slide_jumping = false
		"ground":
			grounding = false

# ------------------
# Efeitos
# ------------------
func effect_step():
	var step: Node2D = effects[0].instantiate()
	step.set_side(side)
	step.global_position = global_position + Vector2(0, 16)
	get_tree().current_scene.add_child(step)

func effect_landing():
	var landing: Node2D = effects[1].instantiate()
	landing.global_position = global_position + Vector2(0, 16)
	get_tree().current_scene.add_child(landing)

func effect_slide():
	var slide: Node2D = effects[2].instantiate()
	slide.set_side(side)
	slide.set_offset(Vector2(-3,0) if not side else Vector2(2,0))
	slide.global_position = global_position
	get_tree().current_scene.add_child(slide)

func effect_walljump():
	var walljump: Node2D = effects[3].instantiate()
	walljump.set_side(side)
	walljump.set_offset(Vector2(2,0) if not side else Vector2(-3,0))
	walljump.global_position = global_position
	get_tree().current_scene.add_child(walljump)

# ------------------
# Queda mortal
# ------------------
func check_fall_die():
	if position.y > 20:
		GameManager.respawn()

# ------------------
# Funções públicas
# ------------------
func die():
	dead = true

func set_ending():
	ending = true

func disable_collision():
	collider.disabled = true

# ------------------
# Sons
# ------------------
func play_sound(source):
	audio_player.stream = source
	audio_player.play()

func play_death_sound():
	play_sound(preload("res://Assets/Audio/SFX/death.mp3"))
