extends CanvasLayer

@onready var device : TextureRect = $ColorRect/Device
@onready var animator : AnimationPlayer = $Animator
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var continue_label : Label = $ColorRect/Device/Screen/NoMore/Continue
@onready var counter_label: Label = $ColorRect/Device/Screen/Counter
@onready var failed_label: Label = $ColorRect/Device/Screen/Failed

var counter_timer: Timer
var counter_value := 10

@onready var btAdContinue : TextureButton = $ColorRect/Device/Screen/BtContinue
@onready var btRestart : TextureButton = $ColorRect/Device/BtRestart
@onready var btQuit : Button = $ColorRect/Device/Screen/BtQuit
@onready var loading : TextureRect = $ColorRect/Loading

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setAnimationIndex("open","ColorRect/Device:position",
		[[0,Vector2(device.position-Vector2(200,0))],[1,device.position]]
	);
	setAnimationIndex("close","ColorRect/Device:position",
		[[0,device.position],[1,Vector2(device.position+Vector2(200,0))]]
	);
	continue_label.text = str(tr("continue")," ?")
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open():
	visible = true
	loading.visible = false
	get_tree().paused = true
	device.visible = true
	btAdContinue.visible = true
	counter_label.visible = true
	btQuit.visible = true
	continue_label.visible = true
	failed_label.visible = false
	animator.play("open")
	await animator.animation_finished
	animator.play("idle")
	#visibleButtons(true)
	start_countdown()
	
func close():
	loading.visible = false
	#visibleButtons(true)
	animator.play("close")
	await animator.animation_finished
	visible = false
	get_tree().paused = false

func gameover():
	pass

func _on_bt_restart_pressed() -> void:
	visible = false
	get_tree().paused = false
	counter_timer.stop()
	GameManager.play_now()
	
func visibleButtons(status : bool):
	btAdContinue.visible = status
	btRestart.visible = status
	btQuit.visible = status

func _on_bt_menu_pressed() -> void:
	visible = false
	get_tree().paused = false
	counter_timer.stop()
	GameManager.go_to_home()

func _on_bt_continue_pressed() -> void:
	#visibleButtons(false)
	device.visible = false
	loading.visible = true
	counter_timer.stop()
	AdManager.get_reward("Continue")

func _on_bt_quit_pressed() -> void:
	visible = false
	get_tree().paused = false
	GameManager.go_to_home()
	
func start_countdown():
	counter_value = 10
	counter_label.text = str(counter_value)
	
	counter_timer = Timer.new()
	counter_timer.wait_time = 1
	counter_timer.autostart = true
	counter_timer.one_shot = false
	add_child(counter_timer)
	counter_timer.timeout.connect(_on_timer_timeout)
	
func _on_timer_timeout() -> void:
	counter_value -= 1
	audio_player.play()
	counter_label.text = str(counter_value)
	
	if counter_value <= 0:
		counter_timer.stop()
		btAdContinue.visible = false
		counter_label.visible = false
		btQuit.visible = false
		continue_label.visible = false
		failed_label.visible = true
		await get_tree().create_timer(2).timeout
		GameManager.go_to_home()

func setAnimationIndex(animation_name: String, path : String, indexs : Array):
	var animation = animator.get_animation(animation_name)
	var track_index = animation.find_track(path, Animation.TYPE_VALUE)
	if track_index != -1:
		for index in indexs:
			animation.track_set_key_value(track_index, index[0], index[1])
