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
	a_star_grid.size = Vector2i(x_max, y_max)
	
	grid = []
	for x in range(x_max):
		var col = []
		col.resize(y_max)
		col.fill(0)
		grid.append(col)
	
	build_astar()


func build_astar():
	for pos in arena:
		var tile_data = get_cell_atlas_coords(1, pos)
		print(tile_data.x)


func all_paths():
	pass


func ldv_full():
	pass


func calcul_ldv():
	pass


func calcul_zone():
	pass
