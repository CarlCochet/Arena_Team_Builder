extends TileMap


var a_star_grid: AStarGrid2D
var grid: Array
var start_bleu: Array
var start_rouge: Array
var x_max: int
var y_max: int
var offset: Vector2i
var mode = false
var zonetype = GlobalData.TypeZone.CARRE
var glyphes: Array
var glyphes_indexeur: int
var cases_maudites: Dictionary
var combat: Combat
var ms_data: Dictionary

@onready var overlay = get_used_cells(2)
@onready var arena = get_used_cells(1)
@onready var obstacles = get_used_cells(7)


func _ready():
	x_max = 0
	y_max = 0
	offset = Vector2i(0, 8)
	cases_maudites = {}
	combat = get_parent()
	
	for pos in arena:
		if pos.x > x_max:
			x_max = pos.x
		if pos.y > y_max:
			y_max = pos.y
	
	glyphes_indexeur = 0
	get_start()
	build_grids()
	load_map_data()
	combat.move_child(self, 0)


func get_start():
	for pos in overlay:
		var tile_data = get_cell_atlas_coords(2, pos)
		if tile_data.x == 0:
			start_rouge.append(pos)
		if tile_data.x == 2:
			start_bleu.append(pos)


func update_glyphes():
	clear_layer(3)
	clear_layer(4)
	for combattant in combat.combattants:
		if not combattant.check_etats(["INVISIBLE"]):
			combattant.visible = true
			combattant.is_visible = true
	for glyphe in glyphes:
		glyphe.active_full()
		if not glyphe.deleted:
			glyphe.affiche()
	combat.check_morts()


func update_effets_map():
	clear_layer(6)
	for case in cases_maudites:
		set_cell(6, cases_maudites[case] - offset, 5, Vector2i(0, 0))


func check_glyphe_effet(pos: Vector2i, effet: String) -> bool:
	for glyphe in glyphes:
		if glyphe.centre == pos and glyphe.effets.has(effet):
			return true
	return false


func delete_glyphes(glyphes_ids: Array):
	var new_glyphes = []
	for glyphe in glyphes:
		if not glyphe.id in glyphes_ids:
			new_glyphes.append(glyphe)
	glyphes = new_glyphes
	update_glyphes()


func build_grids():
	grid = []
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
	
	for pos in arena:
		var tile_data = get_cell_atlas_coords(1, pos)
		grid[pos.x][pos.y + offset.y] = tile_data.x
		if tile_data.x > 0:
			a_star_grid.set_point_solid(pos + offset, false)
	
	for pos in obstacles:
		grid[pos.x][pos.y + offset.y] = 0


func load_map_data():
	var file = FileAccess.open("res://Jeu/map_data.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	ms_data = json_data


func update_mort_subite(tour: int):
	if not GlobalData.mort_subite_active:
		return
	
	var distance = ms_data[GlobalData.map_actuelle]["distance"] - (tour - 15)
	var directions = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
	for i in range(4):
		var centre_array = ms_data[GlobalData.map_actuelle]["centres"][i]
		var centre = Vector2(centre_array[0], centre_array[1])
		for k in range(-distance, distance+1):
			var cell_pos = centre + directions[i] * distance + k * directions[(i + 1) % 4]
			erase_cell(1, cell_pos)
			for combattant in combat.combattants:
				if combattant.grid_pos == Vector2i(cell_pos) + offset:
					combattant.stats.hp = 0
			combat.check_morts()
			if combat.etat == 3:
				return
	combat.check_morts()
	build_grids()
	for combattant in combat.combattants:
		grid[combattant.grid_pos[0]][combattant.grid_pos[1]] = -2
		a_star_grid.set_point_solid(combattant.grid_pos)


func get_atteignables(pos: Vector2i, pm: int) -> Array:
	var atteignables: Array = []
	for x in range(pos.x - pm, pos.x + pm + 1):
		for y in range(pos.y - pm, pos.y + pm + 1):
			if a_star_grid.is_in_bounds(pos.x, pos.y) and a_star_grid.is_in_bounds(x, y) and (x != pos.x or y != pos.y):
				var path = a_star_grid.get_id_path(pos, Vector2i(x,y))
				if len(path) <= pm + 1:
					for cell in path:
						if cell not in atteignables:
							atteignables.append(cell)
	atteignables.erase(pos)
	return atteignables


func get_chemin(debut: Vector2i, fin: Vector2i) -> Array:
	var path = []
	if a_star_grid.is_in_bounds(debut.x, debut.y) and a_star_grid.is_in_bounds(fin.x, fin.y) and (debut.x != fin.x or debut.y != fin.y):
		path = a_star_grid.get_id_path(debut, fin)
	return path


func get_ldv(pos: Vector2i, po_min: int, po_max: int, type_ldv: GlobalData.TypeLDV, doit_check_ldv: int) -> Array:
	var atteignables: Array = []
	for x in range(pos.x - po_max, pos.x + po_max + 1):
		for y in range(pos.y - po_max, pos.y + po_max + 1):
			if check_ldv(x, y, pos, po_min, po_max, type_ldv, doit_check_ldv):
				atteignables.append(Vector2i(x,y))
	return atteignables


func check_ldv(x: int, y: int, pos: Vector2i, po_min: int, po_max: int, type_ldv: GlobalData.TypeLDV, doit_check_ldv: int) -> bool:
	if x < 0 or x >= len(grid) or y < 0 or y >= len(grid[0]):
		return false
	if abs(pos.x - x) + abs(pos.y - y) > po_max:
		return false
	if abs(pos.x - x) + abs(pos.y - y) < po_min:
		return false
	if grid[x][y] == 0 or grid[x][y] == -1:
		return false
	if type_ldv == GlobalData.TypeLDV.LIGNE and (x != pos.x and y != pos.y):
		return false
	if type_ldv == GlobalData.TypeLDV.DIAGONAL and (abs(x - pos.x) != abs(y - pos.y)):
		return false
	if doit_check_ldv == 1 and not calcul_ldv(pos, Vector2i(x,y)):
		return false
	return true


func calcul_ldv(debut: Vector2i, fin: Vector2i) -> bool:
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


func get_zone(source: Vector2i, target: Vector2i, type_zone: GlobalData.TypeZone, taille_min: int, taille_max: int) -> Array:
	var zone = []
	var orientation = source - target
	for x in range(target.x - taille_max, target.x + taille_max + 1):
		for y in range(target.y - taille_max, target.y + taille_max + 1):
			if check_zone(x, y, target, type_zone, taille_min, taille_max, orientation):
				zone.append(Vector2i(x, y))
	return zone


func check_zone(x: int, y: int, target: Vector2i, type_zone: GlobalData.TypeZone, taille_min: int, taille_max: int, orientation: Vector2i) -> bool:
	if x < 0 or x >= len(grid) or y < 0 or y >= len(grid[0]):
		return false
	if abs(target.x - x) + abs(target.y - y) > taille_max and type_zone != GlobalData.TypeZone.CARRE:
		return false
	if abs(target.x - x) + abs(target.y - y) < taille_min:
		return false
	if grid[x][y] == 0 or grid[x][y] == -1:
		return false
	if type_zone == GlobalData.TypeZone.CROIX and (x != target.x and y != target.y):
		return false
	if type_zone == GlobalData.TypeZone.BATON and (
		orientation.x != 0 and x != target.x or 
		orientation.y != 0 and y != target.y
		):
		return false
	if type_zone == GlobalData.TypeZone.LIGNE and (
		orientation.x > 0 and (x > target.x or y != target.y) or
		orientation.x < 0 and (x < target.x or y != target.y) or
		orientation.y > 0 and (y > target.y or x != target.x) or
		orientation.y < 0 and (y < target.y or x != target.x)
		):
		return false
	if type_zone == GlobalData.TypeZone.MARTEAU and (
		orientation.x > 0 and x > target.x or
		orientation.x < 0 and x < target.x or
		orientation.y > 0 and y > target.y or
		orientation.y < 0 and y < target.y
		):
		return false
	return true


func affiche_astar_obstacles():
	clear_layer(5)
	for x in range(0, 40):
		for y in range(0, 40):
			if a_star_grid.is_in_bounds(x, y) and a_star_grid.is_point_solid(Vector2i(x, y)):
				set_cell(5, Vector2i(x, y) - offset, 3, Vector2i(0, 0))


func affiche_ldv_obstacles():
	clear_layer(5)
	for x in range(0, 40):
		for y in range(0, 40):
			if x < len(grid) and y < len(grid[0]):
				if grid[x][y] == 0 or grid[x][y] == -2:
					set_cell(5, Vector2i(x, y) - offset, 3, Vector2i(0, 0))


func _input(event):
	if Input.is_key_pressed(KEY_F2) and event is InputEventKey and not event.echo:
		mode = not mode
	if Input.is_key_pressed(KEY_1) and event is InputEventKey and not event.echo:
		zonetype = GlobalData.TypeZone.CARRE
	if Input.is_key_pressed(KEY_2) and event is InputEventKey and not event.echo:
		zonetype = GlobalData.TypeZone.CERCLE
	if Input.is_key_pressed(KEY_3) and event is InputEventKey and not event.echo:
		zonetype = GlobalData.TypeZone.BATON
	if Input.is_key_pressed(KEY_4) and event is InputEventKey and not event.echo:
		zonetype = GlobalData.TypeZone.LIGNE
	if Input.is_key_pressed(KEY_5) and event is InputEventKey and not event.echo:
		zonetype = GlobalData.TypeZone.CROIX
	if Input.is_key_pressed(KEY_6) and event is InputEventKey and not event.echo:
		zonetype = GlobalData.TypeZone.MARTEAU
