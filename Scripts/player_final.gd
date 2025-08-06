extends CharacterBody2D

var entrance : bool = true
var ending : bool = false
var dead : bool = false

@export var effects : Array[PackedScene]

@export var MAX_SPEED := 220.0
@export var MAX_SPEED_RUN := 300.0
@export var ACCEL := 1200.0
@export var FRICTION := 1000.0
@export var JUMP_VELOCITY = -400.0
@export var WALL_SLIDE_SPEED := 80.0
@export var WALL_JUMP_FORCE := Vector2(250, -400)

@onready var collider : CollisionShape2D = $CollisionShape2D
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
	
@onready var rc_wall_right : RayCast2D = $RightCast
@onready var rc_wall_left : RayCast2D = $LeftCast
@onready var coyote_timer : Timer = $CoyoteTimer

@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var sprite_render : Sprite2D = $Sprite2D

var input_dir : int = 0
var can_coyote : bool = true
var running_speed := 0.0
var just_wall_jumped := false
var side = false
var slide_jumping = false
var first_on_floor = false
var grounding = false

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
				input_dir = Input.get_axis("ui_left", "ui_right")
				if input_dir == -1: side = true
				if input_dir == 1: side = false
				var touching_wall := (rc_wall_right.is_colliding() or rc_wall_left.is_colliding()) and not is_on_floor()
				
				if not is_on_floor():
					first_on_floor = true
					velocity.y += get_gravity().y * delta
					# Se acabou de sair do chão, inicia o timer de coyote
					if not coyote_timer.is_stopped():
						pass # já está contando
					elif can_coyote:
						coyote_timer.start()
						can_coyote = false
				else:
					slide_jumping = false
					# Está no chão, pode pular
					can_coyote = true
					coyote_timer.stop()
					if first_on_floor:
						first_on_floor = false
						grounding = true
						effect_landing()
					
				if touching_wall:
					velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
					
				just_wall_jumped = false
				if Input.is_action_just_pressed("ui_jump"):
					if (is_on_floor() or not coyote_timer.is_stopped()):
						velocity.y = JUMP_VELOCITY
						coyote_timer.stop() # usou o coyote jump
					elif not is_on_floor() and touching_wall:
						slide_jumping = true
						animator.play("slide_jump_trans")
						
				#if is_on_floor():
				if input_dir != 0:
					running_speed = move_toward(running_speed, MAX_SPEED_RUN, 1000 * delta)
				else:
					running_speed = move_toward(running_speed, 0, 2000 * delta)
				#else:
					#running_speed = MAX_SPEED
					
				var speed_limit = running_speed 
				if input_dir != 0 and not just_wall_jumped:
					var accel := ACCEL if is_on_floor() else ACCEL * 0.6
					velocity.x = move_toward(velocity.x, input_dir * speed_limit, accel * delta)
				elif not just_wall_jumped:
					var friction := FRICTION if is_on_floor() else FRICTION * 0.4
					velocity.x = move_toward(velocity.x, 0, friction * delta)
				animate()
				move_and_slide()
				check_fall_die()
			else:
				collider.disabled = true
				velocity = Vector2(0,0)
				animator.play("die")
	
func animate():
	sprite_render.flip_h = side
	if is_on_floor():
		if velocity.x != 0:
			grounding = false
			if velocity.x != 0 and input_dir == 0 :
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
				var animation = animator.get_animation("slide")
				if rc_wall_left.is_colliding():
					animation.track_set_key_value(animation.find_track("Sprite2D:offset",Animation.TYPE_VALUE), 0, Vector2(-1, 0))
				else:
					animation.track_set_key_value(animation.find_track("Sprite2D:offset",Animation.TYPE_VALUE), 0, Vector2(1, 0))
				animator.play("slide")
			else:
				if velocity.y > 0:
					if velocity.x != 0:
						animator.play("fall_front")
					else:
						animator.play("fall")
				else:
					if velocity.x != 0:
						animator.play("jump_front")
					else:
						animator.play("jump")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match(anim_name):
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
			velocity.x = WALL_JUMP_FORCE.x
			side = false
			if rc_wall_right.is_colliding():
				side = true
				velocity.x = velocity.x * -1
			velocity.y = WALL_JUMP_FORCE.y
			just_wall_jumped = true
		"slide_jump":
			slide_jumping = false
		"ground":
			grounding = false

func effect_step():
	var step : Node2D = effects[0].instantiate()
	step.set_side(side)
	step.global_position = Vector2(global_position.x,global_position.y+16)
	get_tree().current_scene.add_child(step)

func effect_landing():
	var landing : Node2D = effects[1].instantiate()
	landing.global_position = Vector2(global_position.x,global_position.y+16)
	get_tree().current_scene.add_child(landing)

func effect_slide():
	var slide : Node2D = effects[2].instantiate()
	slide.set_side(side)
	slide.set_offset(Vector2(-3,0))
	if side:
		slide.set_offset(Vector2(2,0))	
	slide.global_position = Vector2(global_position.x, global_position.y)
	get_tree().current_scene.add_child(slide)

func effect_walljump():
	var walljump : Node2D = effects[3].instantiate()
	walljump.set_side(side)
	walljump.set_offset(Vector2(2,0))
	if side:
		walljump.set_offset(Vector2(-3,0))	
	walljump.global_position = Vector2(global_position.x, global_position.y)
	get_tree().current_scene.add_child(walljump)

func check_fall_die():
	if position.y > 20:
		GameManager.respawn()
		
func die():
	dead = true;

func set_ending():
	ending = true

func disable_collision():
	collider.disabled = true

func play_sound(source):
	audio_player.stream = source
	audio_player.play()

func play_death_sound():
	play_sound(preload("res://Assets/Audio/SFX/death.mp3"))
