extends CanvasLayer

@onready var controlArea : Control = $ControlArea/NotifyContainer
var notification_in: PackedScene = preload("res://Prefab/notification.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func notificar(text : String):
	var note : Label = notification_in.instantiate()
	var control_size = controlArea.get_viewport_rect().size
	
	note.text = text
	controlArea.add_child(note)
	controlArea.move_child(note, 0)
	note.size = note.size + Vector2(30, 0)
	note.position = Vector2(control_size.x - note.size.x - 20, 20)
	
	await get_tree().create_timer(3.0).timeout
	note.queue_free()
