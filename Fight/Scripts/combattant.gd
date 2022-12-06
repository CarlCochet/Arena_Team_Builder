extends Node2D
class_name Combattant


signal clicked


var classe: String
var stats: Stats
var max_stats: Stats
var init_stats: Stats
var equipements: Dictionary
var sorts: Array
var noms_sorts: Array
var equipe: int
var effets: Array

var grid_pos: Vector2i
var id: int
var orientation: int
var all_path: Array
var path_actuel: Array
var all_ldv: Array
var zone: Array

var is_selected: bool
var is_hovered: bool

var cercle_bleu = preload("res://Fight/Images/cercle_personnage_bleu.png")
var cercle_rouge = preload("res://Fight/Images/cercle_personnage_rouge.png")
var outline_shader = preload("res://Fight/Shaders/combattant_outline.gdshader")
var stats_perdu = preload("res://Fight/stats_perdu.tscn")

@onready var cercle: Sprite2D = $Cercle
@onready var fleche: Sprite2D = $Fleche
@onready var classe_sprite: Sprite2D = $Classe
@onready var hp: Sprite2D = $HP
@onready var hp_label: Label = $HP/Label


func _ready():
	effets = []
	classe_sprite.material = ShaderMaterial.new()
	classe_sprite.material.shader = outline_shader
	classe_sprite.material.set_shader_parameter("width", 0.0)
	is_selected = false
	is_hovered = false
	hp_label.text = str(stats.hp) + "/" + str(max_stats.hp)


func update_visuel():
	if equipe == 0:
		cercle.texture = cercle_bleu
	else:
		cercle.texture = cercle_rouge
	classe_sprite.texture = load(
		"res://Classes/" + classe + "/" + classe.to_lower() + ".png"
	)


func select():
	classe_sprite.material.set_shader_parameter("width", 2.0)
	get_parent().stats_select.update(stats, stats)
	is_selected = true
	get_parent().sorts.update(classe, noms_sorts)


func unselect():
	classe_sprite.material.set_shader_parameter("width", 0.0)
	is_selected = false


func from_personnage(personnage: Personnage, equipe_id: int):
	classe = personnage.classe
	stats = personnage.stats.copy()
	max_stats = personnage.stats.copy()
	init_stats = personnage.stats.copy()
	equipements = personnage.equipements
	sorts = [Sort.new().from_arme(self, equipements["Arme"])]
	for sort in personnage.sorts:
		sorts.append(GlobalData.sorts[sort])
	noms_sorts = personnage.sorts
	equipe = equipe_id
	return self


func change_orientation(new_orientation: int):
	fleche.texture = load("res://Fight/Images/fleche_" + str(new_orientation) + ".png")


func affiche_path(pos_event: Vector2i):
	all_ldv = []
	zone = []
	all_path = get_parent().tilemap.get_atteignables(grid_pos, stats.pm)
	var path = get_parent().tilemap.get_chemin(grid_pos, pos_event)
	if len(path) > 0 and len(path) <= stats.pm + 1:
		path.pop_front()
		path_actuel = path
		get_parent().tilemap.clear_layer(2)
		for cell in path:
			get_parent().tilemap.set_cell(2, cell - get_parent().offset, 3, Vector2i(1, 0))
	else:
		path_actuel = []
		get_parent().tilemap.clear_layer(2)
		for cell in all_path:
			get_parent().tilemap.set_cell(2, cell - get_parent().offset, 3, Vector2i(1, 0))


func affiche_ldv(action: int, pos_event: Vector2i):
	all_path = []
	path_actuel = []
	var data
	if action == 0:
		if not equipements["Armes"].is_empty():
			data = GlobalData.equipements[equipements["Armes"]].to_json()
			data["ldv"] = 1
			data["type_ldv"] = 0
		else:
			data = {"po": [1, 1], "type_ldv": 0, "ldv": 1, "type_zone": 0, "taille_zone": 0}
	else:
		data = sorts[action]
	all_ldv = get_parent().tilemap.get_ldv(
		grid_pos, 
		data["po"][0],
		data["po"][1],
		data["type_ldv"],
		data["ldv"]
	)
	get_parent().tilemap.clear_layer(2)
	for cell in all_ldv:
		get_parent().tilemap.set_cell(2, cell - get_parent().offset, 3, Vector2i(2, 0))
	if pos_event in all_ldv:
		if data["taille_zone"] == 0:
			get_parent().tilemap.set_cell(2, pos_event - get_parent().offset, 3, Vector2i(0, 0))
			zone = [pos_event]
		else:
			zone = get_parent().tilemap.get_zone(
				grid_pos,
				pos_event,
				data["type_zone"],
				data["taille_zone"]
			)
			for cell in zone:
				get_parent().tilemap.set_cell(2, cell - get_parent().offset, 3, Vector2i(0, 0))


func debut_tour():
	execute_effets()
	all_path = get_parent().tilemap.get_atteignables(grid_pos, stats.pm)


func fin_tour():
	stats.pa = max_stats.pa
	stats.pm = max_stats.pm
	retrait_durees()


func joue_action(action: int, tile_pos: Vector2i):
	if action == 7 and len(path_actuel) > 0:
		deplace_perso(path_actuel)
	elif action <= len(sorts):
		var sort: Sort = GlobalData.sorts[sorts[action-1]]
		var valide = sort.execute_effets(self, zone)
		print(valide)
		if valide:
			stats.pa -= sort.pa
			var stat_perdu = stats_perdu.instantiate()
			stat_perdu.set_data(-sort.pa, "pa")
			add_child(stat_perdu)
			get_parent().stats_select.update(stats, max_stats)
		get_parent().change_action(7)


func deplace_perso(chemin: Array):
	var fin = chemin[-1]
	var tile_pos = fin - get_parent().offset
	var old_grid_pos = grid_pos
	var old_map_pos = get_parent().tilemap.local_to_map(position)
	get_parent().tilemap.a_star_grid.set_point_solid(old_grid_pos, false)
	get_parent().tilemap.grid[old_grid_pos[0]][old_grid_pos[1]] = get_parent().tilemap.get_cell_atlas_coords(1, old_map_pos).x
	position = get_parent().tilemap.map_to_local(tile_pos)
	grid_pos = fin
	get_parent().tilemap.a_star_grid.set_point_solid(fin)
	get_parent().tilemap.grid[fin[0]][fin[1]] = -2
	stats.pm -= len(path_actuel)
	var stat_perdu = stats_perdu.instantiate()
	stat_perdu.set_data(-len(path_actuel), "pm")
	add_child(stat_perdu)
	get_parent().stats_select.update(stats, max_stats)


func place_perso(tile_pos: Vector2i):
	var tile_data = get_parent().tilemap.get_cell_atlas_coords(2, tile_pos)
	if (tile_data.x == 0 and equipe == 1) or (tile_data.x == 2 and equipe == 0):
		var new_grid_pos = tile_pos + get_parent().offset
		var place_libre = true
		for combattant in get_parent().combattants:
			if combattant.grid_pos == new_grid_pos:
				place_libre = false
		if place_libre:
			var old_grid_pos = grid_pos
			var old_map_pos = get_parent().tilemap.local_to_map(position)
			get_parent().tilemap.a_star_grid.set_point_solid(old_grid_pos, false)
			get_parent().tilemap.grid[old_grid_pos[0]][old_grid_pos[1]] = get_parent().tilemap.get_cell_atlas_coords(1, old_map_pos).x
			position = get_parent().tilemap.map_to_local(tile_pos)
			grid_pos = new_grid_pos
			get_parent().tilemap.a_star_grid.set_point_solid(grid_pos)
			get_parent().tilemap.grid[grid_pos[0]][grid_pos[1]] = -2


func execute_effets():
	for effet in effets:
		effet.execute()


func retrait_durees():
	pass


func _input(event):
	if event is InputEventMouseButton:
		if is_hovered:
			emit_signal("clicked")


func _on_area_2d_mouse_entered():
	for combattant in get_parent().combattants:
		if combattant.is_hovered:
			combattant._on_area_2d_mouse_exited()
	classe_sprite.material.set_shader_parameter("width", 3.0)
	is_hovered = true
	get_parent().stats_hover.update(stats, stats)
	get_parent().stats_hover.visible = true
	hp.visible = true
	if get_parent().action == 7:
		affiche_path(Vector2i(99, 99))


func _on_area_2d_mouse_exited():
	if is_hovered:
		classe_sprite.material.set_shader_parameter("width", 0.0)
		is_hovered = false
		if is_selected:
			classe_sprite.material.set_shader_parameter("width", 2.0)
		get_parent().stats_hover.visible = false
		hp.visible = false
		if get_parent().action == 7:
			get_parent().change_action(7)
