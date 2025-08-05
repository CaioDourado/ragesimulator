extends TileMapLayer

var active : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		global_position.y += 100 * delta
		if global_position.y < -1000:
			queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		active = true
