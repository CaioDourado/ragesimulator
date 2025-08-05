extends Node

@export var tilemap: TileMapLayer
@export var output_path: String = "res://mapa.txt"

func _ready():
	print("Iniciando conversão...")
	var used_cells = tilemap.get_used_cells()
	
	# Encontra limites da área ocupada
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	for cell in used_cells:
		min_x = min(min_x, cell.x)
		min_y = min(min_y, cell.y)
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)

	# Constrói o mapa como texto
	var output = ""
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var tile = tilemap.get_cell_source_id(Vector2i(x, y))
			output += "X" if tile != -1 else " "
		output += "\n"

	# Salva o conteúdo em um .txt
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	file.store_string(output)
	file.close()

	print("Mapa salvo em: %s" % output_path)
