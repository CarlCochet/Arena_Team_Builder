extends TileMap

var a_star_grid: AStarGrid2D
var grid: Array

@onready var overlay = get_used_cells(0)
@onready var arena = get_used_cells(1)


func _ready():
	var x_max = 0
	var y_max = 0
	
	for pos in arena:
		if pos.x > x_max:
			x_max = pos.x
		if pos.y > y_max:
			y_max = pos.y
	
	a_star_grid = AStarGrid2D.new()
	a_star_grid.size = Vector2i(x_max + 1, y_max + 1)
	a_star_grid.update()
	a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	grid = []
	for x in range(x_max + 1):
		var col = []
		col.resize(y_max + 1)
		col.fill(0)
		grid.append(col)
		for y in range(y_max + 1):
			a_star_grid.set_point_solid(Vector2i(x, y))
	
	a_star_grid.update()
	build_astar()
	all_paths()


func build_astar():
	for pos in arena:
		var tile_data = get_cell_atlas_coords(1, pos)
		grid[pos.x][pos.y] = tile_data.x
		if tile_data.x != 1:
			a_star_grid.set_point_solid(pos, false)
	a_star_grid.update()


func all_paths():
	var path = a_star_grid.get_id_path(arena[0], arena[-1])
	for cell in path:
		print(cell)
		set_cell(2, cell, 3, Vector2i(1, 0))


func ldv_full():
	pass


func calcul_ldv():
	pass


func calcul_zone():
	pass
