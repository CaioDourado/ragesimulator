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
@export var WALL_JUMP_START_FORCE: Vector2 = Vector2(220, -320)
@export var WALL_JUMP_FORCE: Vector2 = Vector2(250, -400)
@export var WALL_JUMP_CONTROL_LOCK_TIME: float = 0.2
@export var WALL_JUMP_HOLD_TIME: float = 0.18
@export var WALL_JUMP_COYOTE_LOCK_TIME: float = 0.14

@export var GRAVITY: float = 1200.0
@export var FALL_GRAVITY_MULT: float = 2.0
@export var PUSHABLE_CONTACT_GRACE_TIME: float = 0.12
@export var PUSHABLE_DETECT_DISTANCE: float = 14.0
@export var WALK_ANIM_MIN_SPEED: float = 5.0
@export var FRONT_FLIP_LOOP_COUNT: int = 2

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
var is_wall_jumping: bool = false
var wall_jump_dir: int = 0
var wall_jump_control_lock_timer: float = 0.0
var wall_jump_hold_timer: float = 0.0
var wall_jump_hold_active: bool = false
var wall_jump_coyote_lock_timer: float = 0.0
var touching_pushable: bool = false
var pushable_contact_timer: float = 0.0
var current_pushable: Node = null

# Pulo variável
var jump_held_time: float = 0.0
var is_jumping: bool = false
var use_front_flip_next: bool = false
var front_flip_active: bool = false
var front_flip_loop_timer: float = 0.0
var front_flip_loop_started: bool = false

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

	var touching_wall_raw := rc_wall_right.is_colliding() or rc_wall_left.is_colliding()
	var floor_locked_by_wall_jump := wall_jump_coyote_lock_timer > 0.0 and velocity.y < 0
	var on_floor := is_on_floor() and not floor_locked_by_wall_jump
	var touching_wall := touching_wall_raw and not on_floor
	var wall_sliding := touching_wall and velocity.y > 0
	wall_jump_control_lock_timer = max(wall_jump_control_lock_timer - delta, 0.0)
	wall_jump_coyote_lock_timer = max(wall_jump_coyote_lock_timer - delta, 0.0)

	# ------------------
	# Gravidade
	# ------------------
	if is_wall_jumping:
		update_wall_jump(delta)
	elif is_jumping and not slide_jumping and not wall_sliding and velocity.y < 0 and Input.is_action_pressed("ui_jump"):
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
	if not on_floor:
		first_on_floor = true
		#if can_coyote and coyote_timer.is_stopped():
			#coyote_timer.start()
			#can_coyote = false
	else:
		slide_jumping = false
		is_wall_jumping = false
		wall_jump_dir = 0
		wall_jump_control_lock_timer = 0.0
		wall_jump_hold_timer = 0.0
		wall_jump_hold_active = false
		wall_jump_coyote_lock_timer = 0.0
		#can_coyote = true
		#coyote_timer.stop()
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
		var wall_dir := get_wall_jump_dir()
		if touching_wall_raw and wall_dir != 0 and not on_floor:
			start_wall_jump(wall_dir)
		elif on_floor:
			# Pulo normal
			play_sound(preload("res://Assets/Audio/SFX/jump5.mp3"))
			velocity.y = JUMP_VELOCITY
			is_jumping = true
			jump_held_time = 0.0
			#coyote_timer.stop()
			start_normal_jump_animation()

	# ------------------
	# Movimento horizontal
	# ------------------
	var target_speed = MAX_SPEED_RUN
	if input_dir != 0 and not just_wall_jumped and wall_jump_control_lock_timer <= 0.0:
		var accel_val = ACCEL if on_floor else AIR_ACCEL
		velocity.x = move_toward(velocity.x, input_dir * target_speed, accel_val * delta)
	elif not just_wall_jumped and wall_jump_control_lock_timer <= 0.0:
		var friction_val = FRICTION if on_floor else AIR_FRICTION
		velocity.x = move_toward(velocity.x, 0, friction_val * delta)

	# ------------------
	# Animations e movimento
	# ------------------
	move_and_slide()
	update_pushable_contact(delta)
	apply_pushable_push()
	update_front_flip_animation(delta)
	animate()
	check_fall_die()

# ------------------
# Animations
# ------------------
func animate():
	sprite_render.flip_h = side
	var real_horizontal_speed: float = abs(get_real_velocity().x)
	var own_horizontal_speed: float = abs(velocity.x)
	if is_on_floor():
		if touching_pushable:
			grounding = false
			animator.play("push_loop")
		elif input_dir != 0 and real_horizontal_speed > WALK_ANIM_MIN_SPEED:
			grounding = false
			animator.play("walk")
		elif input_dir == 0 and own_horizontal_speed > WALK_ANIM_MIN_SPEED:
			grounding = false
			animator.play("break")
		else:
			if not grounding:
				animator.play("idle")
			else:
				animator.play("ground")
	else:
		if not slide_jumping:
			if rc_wall_left.is_colliding() or rc_wall_right.is_colliding():
				stop_front_flip_animation()
				face_wall()
				animator.play("slide")
			elif front_flip_active:
				return
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
			is_wall_jumping = false
			start_front_flip_animation()
		"ground":
			grounding = false
		"jump_front_2":
			front_flip_loop_started = true
			front_flip_loop_timer = get_front_flip_loop_duration()
			animator.play("jump_front_2_loop")

func get_wall_jump_dir() -> int:
	if rc_wall_right.is_colliding():
		return -1
	if rc_wall_left.is_colliding():
		return 1
	return 0

func face_wall():
	if rc_wall_left.is_colliding():
		side = true
	elif rc_wall_right.is_colliding():
		side = false
	sprite_render.flip_h = side

func start_normal_jump_animation():
	if input_dir == 0:
		front_flip_active = false
		return

	if use_front_flip_next:
		start_front_flip_animation()
	else:
		front_flip_active = false
		animator.play("jump_front")
	use_front_flip_next = not use_front_flip_next

func start_front_flip_animation():
	front_flip_active = true
	front_flip_loop_started = false
	front_flip_loop_timer = 0.0
	animator.play("jump_front_2")

func stop_front_flip_animation():
	front_flip_active = false
	front_flip_loop_started = false
	front_flip_loop_timer = 0.0

func update_front_flip_animation(delta: float):
	if is_on_floor():
		front_flip_active = false
		front_flip_loop_started = false
		front_flip_loop_timer = 0.0
		return

	if not front_flip_active or slide_jumping:
		return

	if front_flip_loop_started:
		front_flip_loop_timer = max(front_flip_loop_timer - delta, 0.0)
		if front_flip_loop_timer <= 0.0 and velocity.y > 0:
			front_flip_active = false
			animator.play("fall_front")

func update_pushable_contact(delta: float):
	var pushable_ahead := get_pushable_ahead() if is_on_floor() and input_dir != 0 else null
	var found_pushable := pushable_ahead != null

	if found_pushable:
		current_pushable = pushable_ahead
		pushable_contact_timer = PUSHABLE_CONTACT_GRACE_TIME
	elif not is_on_floor() or input_dir == 0:
		current_pushable = null
		pushable_contact_timer = 0.0
	else:
		pushable_contact_timer = max(pushable_contact_timer - delta, 0.0)
		if pushable_contact_timer <= 0.0:
			current_pushable = null

	touching_pushable = pushable_contact_timer > 0.0

func apply_pushable_push():
	if touching_pushable and current_pushable != null and current_pushable.has_method("push"):
		current_pushable.push(input_dir)

func get_pushable_ahead() -> Node:
	var space_state := get_world_2d().direct_space_state
	var ray_offsets := [0.0, 6.0]
	for offset_y in ray_offsets:
		var origin := global_position + Vector2(input_dir * 6.0, offset_y)
		var target := origin + Vector2(input_dir * PUSHABLE_DETECT_DISTANCE, 0.0)
		var query := PhysicsRayQueryParameters2D.create(origin, target)
		query.exclude = [self]
		var result := space_state.intersect_ray(query)
		if result.has("collider"):
			var collider_node := result["collider"] as Node
			if collider_node != null and is_pushable(collider_node):
				return get_pushable_node(collider_node)
	return null

func get_pushable_node(node: Node) -> Node:
	if node.is_in_group("Pushable"):
		return node
	if node.get_parent() != null and node.get_parent().is_in_group("Pushable"):
		return node.get_parent()
	return null

func is_pushable(node: Node) -> bool:
	return get_pushable_node(node) != null

func get_front_flip_loop_duration() -> float:
	var animation: Animation = animator.get_animation("jump_front_2_loop")
	if animation == null:
		return 0.25
	return animation.length * FRONT_FLIP_LOOP_COUNT

func start_wall_jump(direction: int):
	slide_jumping = true
	is_wall_jumping = true
	wall_jump_dir = direction
	wall_jump_control_lock_timer = WALL_JUMP_CONTROL_LOCK_TIME
	wall_jump_hold_timer = 0.0
	wall_jump_hold_active = true
	wall_jump_coyote_lock_timer = WALL_JUMP_COYOTE_LOCK_TIME
	is_jumping = false
	#coyote_timer.stop()
	play_sound(preload("res://Assets/Audio/SFX/jump5.mp3"))
	animator.play("slide_jump_trans")
	side = direction < 0
	velocity.x = WALL_JUMP_START_FORCE.x * direction
	velocity.y = WALL_JUMP_START_FORCE.y
	just_wall_jumped = true

func update_wall_jump(delta: float):
	if not Input.is_action_pressed("ui_jump"):
		wall_jump_hold_active = false

	if wall_jump_hold_active and wall_jump_hold_timer < WALL_JUMP_HOLD_TIME and velocity.y < 0:
		wall_jump_hold_timer += delta
		velocity.x = move_toward(velocity.x, WALL_JUMP_FORCE.x * wall_jump_dir, AIR_ACCEL * delta)
		velocity.y = min(velocity.y, WALL_JUMP_FORCE.y)
	else:
		velocity.y += GRAVITY * (FALL_GRAVITY_MULT if velocity.y > 0 else 1.0) * delta
		if not wall_jump_hold_active or wall_jump_hold_timer >= WALL_JUMP_HOLD_TIME or velocity.y >= 0:
			is_wall_jumping = false

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
	var effect_side := wall_jump_dir > 0 if wall_jump_dir != 0 else not side
	walljump.set_side(effect_side)
	walljump.set_offset(Vector2(2,0) if not effect_side else Vector2(-3,0))
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
