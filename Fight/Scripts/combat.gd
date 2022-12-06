extends Node2D
class_name Combat


var scene_combattant = preload("res://Fight/combattant.tscn")
var stats_perdu = preload("res://Fight/stats_perdu.tscn")
var combattants: Array
var combattant_selection: Combattant
var selection_id: int
var etat: int
var action: int
var offset: Vector2i

@onready var sorts: Control = $Sorts
@onready var timeline: Control = $Timeline
@onready var tilemap: TileMap = $TileMap
@onready var stats_select: TextureRect = $AffichageStatsSelect
@onready var stats_hover: TextureRect = $AffichageStatsHover


func _ready():
	etat = 0
	offset = tilemap.offset
	randomize()
	creer_personnages()
	timeline.init(combattants)


func creer_personnages():
	ajoute_equipe(GlobalData.equipe_actuelle, tilemap.start_bleu, 0)
	ajoute_equipe(GlobalData.equipe_test, tilemap.start_rouge, 1)

	combattants.sort_custom(func(a, b): return a.stats.initiative > b.stats.initiative)
	for k in range(len(combattants)):
		combattants[k].id = k
		combattants[k].connect("clicked", _on_perso_clicked.bind(k))
	selection_id = 0
	combattants[selection_id].select()
	combattant_selection = combattants[selection_id]


func ajoute_equipe(equipe: Equipe, tile_couleur: Array, id_equipe):
	var i = 0
	for personnage in equipe.personnages:
		if not personnage.classe.is_empty():
			var nouveau_combattant = scene_combattant.instantiate()
			nouveau_combattant.position = tilemap.map_to_local(tile_couleur[i])
			nouveau_combattant.grid_pos = tile_couleur[i] + offset
			tilemap.a_star_grid.set_point_solid(nouveau_combattant.grid_pos)
			tilemap.grid[nouveau_combattant.grid_pos[0]][nouveau_combattant.grid_pos[1]] = -2
			i += 1
			combattants.append(nouveau_combattant.from_personnage(personnage, id_equipe))
			add_child(nouveau_combattant)
			nouveau_combattant.update_visuel()


func passe_tour():
	combattant_selection.fin_tour()
	tilemap.clear_layer(2)
	combattants[selection_id].unselect()
	selection_id += 1
	if selection_id >= len(combattants):
		selection_id = 0
	timeline.select(selection_id)
	combattants[selection_id].select()
	combattant_selection = combattants[selection_id]
	change_action(7)
	combattant_selection.debut_tour()


func lance_game():
	_on_perso_clicked(0)
	etat = 1
	tilemap.clear_layer(2)
	change_action(7)
	combattant_selection.debut_tour()


func change_action(new_action: int):
	if new_action > len(combattant_selection.sorts):
		new_action = 7
	if new_action == action:
		action = 7
	else:
		action = new_action
	if 0 <= action and action <= len(combattant_selection.sorts):
		combattant_selection.affiche_ldv(action, tilemap.local_to_map(get_viewport().get_mouse_position()) + offset)
	else:
		combattant_selection.affiche_path(tilemap.local_to_map(get_viewport().get_mouse_position()) + offset)


func _on_perso_clicked(id: int):
	if etat == 0:
		combattants[selection_id].unselect()
		selection_id = id
		timeline.select(selection_id)
		combattants[selection_id].select()
		combattant_selection = combattants[selection_id]


func _input(event):
	if etat == 1:
		if Input.is_key_pressed(KEY_F1) and event is InputEventKey and not event.echo:
			passe_tour()
		if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
			get_tree().change_scene_to_file("res://UI/choix_ennemis.tscn")
		if event is InputEventMouseMotion:
			if action == 7:
				for combattant in combattants:
					if combattant.is_hovered:
						return
				combattant_selection.affiche_path(tilemap.local_to_map(event.position) + offset)
			else:
				combattant_selection.affiche_ldv(action, tilemap.local_to_map(event.position) + offset)
		if event is InputEventMouseButton and event.pressed:
			combattant_selection.joue_action(action, tilemap.local_to_map(event.position) + offset)
		if Input.is_key_pressed(KEY_APOSTROPHE) and event is InputEventKey and not event.echo:
			change_action(0)
		if Input.is_key_pressed(KEY_1) and event is InputEventKey and not event.echo:
			change_action(1)
		if Input.is_key_pressed(KEY_2) and event is InputEventKey and not event.echo:
			change_action(2)
		if Input.is_key_pressed(KEY_3) and event is InputEventKey and not event.echo:
			change_action(3)
		if Input.is_key_pressed(KEY_4) and event is InputEventKey and not event.echo:
			change_action(4)
		if Input.is_key_pressed(KEY_5) and event is InputEventKey and not event.echo:
			change_action(5)
		if Input.is_key_pressed(KEY_6) and event is InputEventKey and not event.echo:
			change_action(6)
		if Input.is_key_pressed(KEY_UP) and event is InputEventKey and not event.echo:
			combattant_selection.change_orientation(0)
		if Input.is_key_pressed(KEY_RIGHT) and event is InputEventKey and not event.echo:
			combattant_selection.change_orientation(1)
		if Input.is_key_pressed(KEY_DOWN) and event is InputEventKey and not event.echo:
			combattant_selection.change_orientation(2)
		if Input.is_key_pressed(KEY_LEFT) and event is InputEventKey and not event.echo:
			combattant_selection.change_orientation(3)
	if etat == 0:
		if Input.is_key_pressed(KEY_F1) and event is InputEventKey and not event.echo:
			lance_game()
		if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
			get_tree().change_scene_to_file("res://UI/choix_ennemis.tscn")
		if event is InputEventMouseButton:
			combattant_selection.place_perso(tilemap.local_to_map(event.position))
