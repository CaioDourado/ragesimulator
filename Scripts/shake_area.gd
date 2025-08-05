extends Area2D

var on_area : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func camera_tremor(camera: Camera2D):
	var tween = create_tween()
	var original_offset = camera.offset

	for i in range(3):
		var random_offset = Vector2(randi() % 8 - 4, randi() % 8 - 4)
		tween.tween_property(camera, "offset", original_offset + random_offset, 0.05)
		tween.tween_property(camera, "offset", original_offset, 0.05)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		on_area = true

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		on_area = false

func notify_impact() -> void:
	if on_area:
		camera_tremor(GameManager.get_node_or_null(GameManager.stage_path("Camera")))
