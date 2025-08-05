extends Node2D

@export var lifetime : float = 0
@export var collider : CollisionShape2D
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
var first_collision = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if lifetime > 0:
		var timer = Timer.new()
		timer.wait_time = lifetime
		timer.one_shot = true
		add_child(timer)
		timer.start()
		timer.timeout.connect(_on_lifetime_timeout)

func _on_lifetime_timeout():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)  # Fade out em 1 segundo
	tween.tween_callback(Callable(self, "queue_free"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.global_position.y > 40:
		self.queue_free()

func _on_body_entered(body: Node) -> void:
	if(first_collision):
		first_collision = false
		audio_player.play()
