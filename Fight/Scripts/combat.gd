extends Node2D
class_name Combat


var scene_combattant = preload("res://Fight/combattant.tscn")
var stats_perdu = preload("res://Fight/stats_perdu.tscn")
var combattants: Array
var combattant_selection: Combattant
var selection_id: int
var indexeur_global: int
var etat: int
var action: int
var offset: Vector2i
var tilemap: TileMap
var spell_pressed: bool
var tour: int

@onready var sorts: Control = $Sorts
@onready var timeline: Control = $Timeline
@onready var stats_select: TextureRect = $AffichageStatsSelect
@onready var stats_hover: TextureRect = $AffichageStatsHover
@onready var affichage_fin: Control = $AffichageFin
@onready var texte_fin: Label = $AffichageFin/TexteFin
@onready var bouton_retour: TextureButton = $AffichageFin/BoutonRetour


func _ready():
	tilemap = load("res://Fight/Map/" + GlobalData.map_actuelle + ".tscn").instantiate()
	add_child(tilemap)
	etat = 0
	spell_pressed = false
	indexeur_global = 0
	offset = tilemap.offset
	creer_personnages()
	tour = 1
	timeline.init(combattants, selection_id)


func creer_personnages():
	ajoute_equipe(GlobalData.equipe_actuelle, tilemap.start_bleu, 0)
	ajoute_equipe(GlobalData.equipe_test, tilemap.start_rouge, 1)

	combattants.sort_custom(func(a, b): return a.stats.initiative > b.stats.initiative)
	for k in range(len(combattants)):
		indexeur_global = k
		combattants[k].id = indexeur_global
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


@rpc(any_peer, call_local)
func passe_tour():
	combattant_selection.fin_tour()
	tilemap.clear_layer(2)
	combattants[selection_id].unselect()
	selection_id += 1
	if selection_id >= len(combattants):
		selection_id = 0
		tour += 1
		if tour >= 15:
			tilemap.update_mort_subite(tour)
	timeline.init(combattants, selection_id)
	combattants[selection_id].select()
	combattant_selection = combattants[selection_id]
	change_action(7)
	combattant_selection.debut_tour()


@rpc(any_peer, call_local)
func lance_game():
	_on_perso_clicked(0)
	etat = 1
	tilemap.clear_layer(2)
	change_action(7)
	combattant_selection.debut_tour()


@rpc(any_peer, call_local)
func change_action(new_action: int):
	if new_action >= len(combattant_selection.sorts):
		new_action = 7
	if new_action == action:
		action = 7
	else:
		action = new_action
	if 0 <= action and action < len(combattant_selection.sorts):
		combattant_selection.affiche_ldv(action)
		combattant_selection.affiche_zone(action, tilemap.local_to_map(get_viewport().get_mouse_position()) + offset)
	else:
		combattant_selection.affiche_path(tilemap.local_to_map(get_viewport().get_mouse_position()) + offset)


@rpc(any_peer, call_local)
func joue_action(action_id, grid_pos):
	combattant_selection.joue_action(action_id, grid_pos)


@rpc(any_peer, call_local)
func change_orientation(orientation_id, combattant_id):
	combattants[combattant_id].change_orientation(orientation_id)

@rpc(any_peer, call_local)
func place_perso(map_pos, combattant_id):
	combattants[combattant_id].place_perso(map_pos)


@rpc(any_peer, call_local)
func affiche_path(grid_pos):
	combattant_selection.affiche_path(grid_pos)


@rpc(any_peer, call_local)
func affiche_zone(action_id, grid_pos):
	combattant_selection.affiche_zone(action_id, grid_pos)


func trigger_victoire(equipe: int):
	etat = 3
	texte_fin.text = "VICTOIRE\n" + ("BLEU" if equipe == 0 else "ROUGE")
	affichage_fin.visible = true


func check_morts():
	var new_combattants = []
	var delete_glyphes = []
	var new_selection_id = 0
	var compte_init = len(combattants)
	var comptes_equipes = [0, 0]
	var old_id = combattant_selection.id
	combattants[selection_id].unselect()
	for combattant in combattants:
		if combattant.id == combattants[selection_id].id:
			new_selection_id = len(new_combattants)
		if combattant.stats.hp <= 0:
			for glyphe in tilemap.glyphes:
				if glyphe.lanceur.id == combattant.id:
					delete_glyphes.append(glyphe.id)
			combattant.meurt()
		elif combattant.is_invocation and combattant.invocateur.stats.hp <= 0:
			combattant.meurt()
		else: 
			new_combattants.append(combattant)
			comptes_equipes[combattant.equipe] += 1
	combattants = new_combattants
	if comptes_equipes[0] == 0:
		trigger_victoire(1)
	if comptes_equipes[1] == 0:
		trigger_victoire(0)
	if len(delete_glyphes) > 0:
		tilemap.delete_glyphes(delete_glyphes)
	tilemap.clear_layer(2)
	if new_selection_id >= len(combattants):
		new_selection_id = 0
		tour += 1
		if tour >= 15:
			tilemap.update_mort_subite(tour)
	selection_id = new_selection_id
	combattants[selection_id].select()
	combattant_selection = combattants[selection_id]
	change_action(7)
	if old_id != combattant_selection.id:
		combattant_selection.debut_tour()
	timeline.init(combattants, selection_id)
	if compte_init != len(combattants):
		check_morts()


func _on_perso_clicked(id: int):
	if etat == 0:
		combattants[selection_id].unselect()
		selection_id = id
		timeline.init(combattants, selection_id)
		combattants[selection_id].select()
		combattant_selection = combattants[selection_id]


func _input(event):
	if etat == 1:
		if (Input.is_key_pressed(KEY_F1) or Input.is_key_pressed(KEY_SPACE)) and event is InputEventKey and not event.echo:
#			passe_tour()
			rpc("passe_tour")
		if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
			rpc("retour_pressed")
		if event is InputEventMouseMotion:
			if action == 7:
				for combattant in combattants:
					if combattant.is_hovered:
						return
				combattant_selection.affiche_path(tilemap.local_to_map(event.position) + offset)
			else:
				combattant_selection.affiche_zone(action, tilemap.local_to_map(event.position) + offset)
		if event is InputEventMouseButton and event.pressed:
			if spell_pressed:
				spell_pressed = false
				return
#			combattant_selection.joue_action(action, tilemap.local_to_map(event.position) + offset)
			rpc("joue_action", action, tilemap.local_to_map(event.position) + offset)
		if Input.is_key_pressed(KEY_APOSTROPHE) and event is InputEventKey and not event.echo:
#			change_action(0)
			rpc("change_action", 0)
		if Input.is_key_pressed(KEY_1) and event is InputEventKey and not event.echo:
#			change_action(1)
			rpc("change_action", 1)
		if Input.is_key_pressed(KEY_2) and event is InputEventKey and not event.echo:
#			change_action(2)
			rpc("change_action", 2)
		if Input.is_key_pressed(KEY_3) and event is InputEventKey and not event.echo:
#			change_action(3)
			rpc("change_action", 3)
		if Input.is_key_pressed(KEY_4) and event is InputEventKey and not event.echo:
#			change_action(4)
			rpc("change_action", 4)
		if Input.is_key_pressed(KEY_5) and event is InputEventKey and not event.echo:
#			change_action(5)
			rpc("change_action", 5)
		if Input.is_key_pressed(KEY_6) and event is InputEventKey and not event.echo:
#			change_action(6)
			rpc("change_action", 6)
		if Input.is_key_pressed(KEY_UP) and event is InputEventKey and not event.echo:
#			combattant_selection.change_orientation(0)
			rpc("change_orientation", 0, selection_id)
		if Input.is_key_pressed(KEY_RIGHT) and event is InputEventKey and not event.echo:
#			combattant_selection.change_orientation(1)
			rpc("change_orientation", 1, selection_id)
		if Input.is_key_pressed(KEY_DOWN) and event is InputEventKey and not event.echo:
#			combattant_selection.change_orientation(2)
			rpc("change_orientation", 2, selection_id)
		if Input.is_key_pressed(KEY_LEFT) and event is InputEventKey and not event.echo:
#			combattant_selection.change_orientation(3)
			rpc("change_orientation", 3, selection_id)
	if etat == 0:
		if (Input.is_key_pressed(KEY_F1) or Input.is_key_pressed(KEY_SPACE)) and event is InputEventKey and not event.echo:
#			lance_game()
			rpc("lance_game")
		if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
			rpc("retour_pressed")
		if event is InputEventMouseButton:
#			combattant_selection.place_perso(tilemap.local_to_map(event.position))
			rpc("place_perso", tilemap.local_to_map(event.position), selection_id)


func _on_fleche_0_pressed():
#	combattant_selection.change_orientation(0)
	rpc("change_orientation", 0, selection_id)


func _on_fleche_1_pressed():
#	combattant_selection.change_orientation(1)
	rpc("change_orientation", 1, selection_id)


func _on_fleche_2_pressed():
#	combattant_selection.change_orientation(2)
	rpc("change_orientation", 2, selection_id)


func _on_fleche_3_pressed():
#	combattant_selection.change_orientation(3)
	rpc("change_orientation", 3, selection_id)


func _on_passe_tour_pressed():
	if etat == 1:
		rpc("passe_tour")
#		passe_tour()
	if etat == 0:
		rpc("lance_game")
#		lance_game()


func _on_bouton_retour_pressed():
	rpc("retour_pressed")


@rpc(any_peer, call_local)
func retour_pressed():
	get_tree().change_scene_to_file("res://UI/choix_map.tscn")
