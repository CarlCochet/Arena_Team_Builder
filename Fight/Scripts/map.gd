extends TileMap


var a_star_grid: AStarGrid2D
var grid: Array
var start_bleu: Array
var start_rouge: Array
var x_max
var y_max
var offset
var mode = false

@onready var overlay = get_used_cells(2)
@onready var arena = get_used_cells(1)


func _ready():
	x_max = 0
	y_max = 0
	offset = Vector2i(0, 8)
	grid = []
	
	for pos in arena:
		if pos.x > x_max:
			x_max = pos.x
		if pos.y > y_max:
			y_max = pos.y
	
	a_star_grid = AStarGrid2D.new()
	a_star_grid.size = Vector2i(x_max + 1, y_max + 1) + offset
	a_star_grid.update()
	a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER

	for x in range(x_max + 1):
		var col = []
		col.resize(y_max + 1 + offset.y)
		col.fill(-1)
		grid.append(col)
		for y in range(y_max + 1 + offset.y):
			a_star_grid.set_point_solid(Vector2i(x, y), true)
	
	get_start()
	build_astar_grid()
	affichage_atteignables(Vector2i(11, 6), 8)


func get_start():
	for pos in overlay:
		var tile_data = get_cell_atlas_coords(2, pos)
		if tile_data.x == 0:
			start_rouge.append(pos)
		if tile_data.x == 2:
			start_bleu.append(pos)
	start_bleu.shuffle()
	start_rouge.shuffle()


func build_astar_grid():
	for pos in arena:
		var tile_data = get_cell_atlas_coords(1, pos)
		grid[pos.x][pos.y + offset.y] = tile_data.x
		if tile_data.x > 0:
			a_star_grid.set_point_solid(pos + offset, false)


func affichage_atteignables(pos: Vector2i, pm: int):
	var atteignables: Array = []
	
	for x in range(pos.x - pm, pos.x + pm):
		for y in range(pos.y - pm, pos.y + pm):
			if a_star_grid.is_in_bounds(pos.x, pos.y) and a_star_grid.is_in_bounds(x, y):
				var path = a_star_grid.get_id_path(pos, Vector2i(x,y))
				if len(path) <= pm:
					for cell in path:
						if cell not in atteignables:
							atteignables.append(cell)
	
	for cell in atteignables:
		set_cell(2, cell - offset, 3, Vector2i(1, 0))
	set_cell(2, pos - offset, 3, Vector2i(2, 0))


func affichage_chemin(debut: Vector2i, fin: Vector2i):
	if a_star_grid.is_in_bounds(debut.x, debut.y) and a_star_grid.is_in_bounds(fin.x, fin.y):
		var path = a_star_grid.get_id_path(debut, fin)
		for cell in path:
			set_cell(2, cell - offset, 3, Vector2i(1, 0))


func ldv_full(pos: Vector2i, po: int):
	var atteignables: Array = []
	
	for x in range(pos.x - po, pos.x + po):
		for y in range(pos.y - po, pos.y + po):
			if abs(pos.x - x) + abs(pos.y - y) <= po:
				var ldv = calcul_ldv(pos, Vector2i(x,y))
				if ldv:
					atteignables.append(Vector2i(x,y))

	for cell in atteignables:
		set_cell(2, cell - offset, 3, Vector2i(2, 0))
	set_cell(2, pos - offset, 3, Vector2i(0, 0))


func calcul_ldv(debut: Vector2i, fin: Vector2i):
	if debut.x < 0 or debut.x >= len(grid) or debut.y < 0 or debut.y >= len(grid[0]):
		return false
	if fin.x < 0 or fin.x >= len(grid) or fin.y < 0 or fin.y >= len(grid[0]):
		return false
	if grid[fin.x][fin.y] == 0 or grid[fin.x][fin.y] == -1:
		return false
	
	var delta = Vector2i(abs(debut.x - fin.x), abs(debut.y - fin.y))
	var pos = Vector2i(debut.x, debut.y)
	var n = delta.x + delta.y
	var vector = Vector2i(1 if fin.x > debut.x else -1, 1 if fin.y > debut.y else -1)
	var error = delta.x - delta.y
	delta *= Vector2i(2, 2)
	
	while n > 0:
		if error > 0:
			pos.x += vector.x
			error -= delta.y
		elif error == 0:
			pos += vector
			n -= 1
			error += delta.x - delta.y
		else:
			pos.y += vector.y
			error += delta.x
		if grid[pos.x][pos.y] == 0 or grid[pos.x][pos.y] == -2:
			break
		n -= 1
	return pos.x == fin.x and pos.y == fin.y


func calcul_zone(pos: Vector2i, type_zone: int, taille_zone: int):
	pass


func _input(event):
	if Input.is_key_pressed(KEY_F2) and event is InputEventKey and not event.echo:
		mode = not mode
	if event is InputEventMouseMotion:
		pass
		var map_pos = local_to_map(event.position)
#		clear_layer(2)
#		if mode:
#			ldv_full(map_pos + offset, 10)
#		else:
#			affichage_atteignables(map_pos + offset, 8)
