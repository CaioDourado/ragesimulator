extends Panel

@export var proporcao: float = 0.4

func _notification(what):
	if what == NOTIFICATION_RESIZED and get_parent():
		var largura_pai = get_parent().size.x
		var nova_largura = largura_pai * proporcao
		size.x = nova_largura
