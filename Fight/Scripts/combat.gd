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
var noms_cartes_combat: Array[String]
var cartes_queue: Array[String]
var adversaire_pret: bool

@onready var sorts: Control = $Sorts
@onready var sorts_bonus: Control = $SortsBonus
@onready var cartes_combat: Control = $CartesCombat
@onready var fleche_carte_combat: Sprite2D = $FlecheCarteCombat
@onready var timeline: Control = $Timeline
@onready var stats_select: TextureRect = $AffichageStatsSelect
@onready var stats_hover: TextureRect = $AffichageStatsHover
@onready var affichage_fin: Control = $AffichageFin
@onready var texte_fin: Label = $AffichageFin/TexteFin
@onready var bouton_retour: TextureButton = $AffichageFin/BoutonRetour
@onready var timer: Timer = $Timer
@onready var timer_label: Label = $TimerLabel
@onready var attente_adversaire: Label = $AttenteAdversaire
@onready var chat_log: Control = $ChatLog


func _ready():
	tilemap = load("res://Fight/Map/" + GlobalData.map_actuelle + ".tscn").instantiate()
	add_child(tilemap)
	etat = 0
	spell_pressed = false
	adversaire_pret = not GlobalData.is_multijoueur
	indexeur_global = 0
	offset = tilemap.offset
	if not GlobalData.is_multijoueur:
		fleche_carte_combat.visible = false
	creer_personnages()
	tour = 1
	if GlobalData.is_multijoueur:
		timer.start(60)
	timeline.init(combattants, selection_id)


func _process(_delta):
	timer_label.text = str(int(timer.time_left))


func creer_personnages():
	ajoute_equipe(GlobalData.equipe_actuelle, tilemap.start_bleu, 0)
	ajoute_equipe(GlobalData.equipe_test, tilemap.start_rouge, 1)
	init_cartes()
	
	combattants.sort_custom(func(a, b): return a.initiative_random > b.initiative_random)
	for k in range(len(combattants)):
		indexeur_global = k
		combattants[k].id = indexeur_global
		combattants[k].nom = (GlobalData.classes_mapping[combattants[k].classe] + "_" + str(combattants[k].id)) if combattants[k].nom.is_empty() else combattants[k].nom
		combattants[k].connect("clicked", _on_perso_clicked.bind(k))
		if GlobalData.is_multijoueur and (Client.is_host and combattants[k].equipe == 1 or not Client.is_host and combattants[k].equipe == 0):
			combattants[k].visible = false
	selection_id = 0
	combattants[selection_id].select()
	combattant_selection = combattants[selection_id]


func ajoute_equipe(equipe: Equipe, tile_couleur: Array, id_equipe: int):
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


func init_cartes():
	var nombre_sort_bonus = GlobalData.rng.randi_range(1, 3)
	var noms_sorts_bonus = GlobalData.sorts_lookup["Bonus"].duplicate(true)
	var sorts_bonus_select: Array[String] = []
	while len(sorts_bonus_select) < nombre_sort_bonus:
		var rnd_index = GlobalData.rng.randi_range(0, len(noms_sorts_bonus) - 1)
		if not noms_sorts_bonus[rnd_index] in sorts_bonus_select:
			sorts_bonus_select.append(noms_sorts_bonus[rnd_index])
	ajoute_sorts_bonus(sorts_bonus_select)
	init_cartes_combat()


func init_cartes_combat():
	noms_cartes_combat = ["cloue_au_lit"]
	for i in range(2):
		ajoute_carte_combat()


func genere_cartes_queue():
	var temp_cartes: Array = GlobalData.cartes_combat.keys().duplicate()
	cartes_queue = []
	while len(temp_cartes) > 0:
		var element: int = GlobalData.rng.randi_range(0, len(temp_cartes) - 1)
		cartes_queue.append(temp_cartes[element])
		temp_cartes.remove_at(element)


func ajoute_sorts_bonus(noms_sorts_bonus: Array[String]):
	for combattant in combattants:
		for nom_sort in noms_sorts_bonus:
			combattant.sorts.append(GlobalData.sorts[nom_sort].copy())


@rpc("any_peer", "call_local")
func passe_tour():
	combattant_selection.fin_tour()
	tilemap.clear_layer(2)
	combattants[selection_id].unselect()
	selection_id += 1
	if selection_id >= len(combattants):
		init_nouveau_tour()
	clean_particules()
	if GlobalData.is_multijoueur:
		timer.start(25)
	timeline.init(combattants, selection_id)
	combattants[selection_id].select()
	combattant_selection = combattants[selection_id]
	change_action(10)
	combattant_selection.debut_tour()


func clean_particules():
	for child in get_children():
		if "Node2D" in child.name:
			child.queue_free()


func init_nouveau_tour():
	selection_id = 0
	tour += 1
	if tour >= 15:
		tilemap.update_mort_subite(tour)
	
	if GlobalData.is_multijoueur:
		noms_cartes_combat.pop_front()
		ajoute_carte_combat()
		cartes_combat.update(noms_cartes_combat)
		applique_carte_combat()


func ajoute_carte_combat():
	if len(cartes_queue) == 0:
		genere_cartes_queue()
	noms_cartes_combat.append(cartes_queue.pop_back())
#	var nom_cartes = GlobalData.cartes_combat.keys()
#	var derniere_carte = len(noms_cartes_combat) - 1
#	var nouvelle_carte = noms_cartes_combat[derniere_carte]
#	while nouvelle_carte == noms_cartes_combat[derniere_carte]:
#		var id_carte = GlobalData.rng.randi_range(1, len(nom_cartes) - 1)
#		nouvelle_carte = nom_cartes[id_carte]
#	noms_cartes_combat.append(nouvelle_carte)


func applique_carte_combat():
	var effets_carte: Dictionary = GlobalData.cartes_combat[noms_cartes_combat[0]]
	var classes_target: Array[String] = []
	for combattant in combattants:
		combattant.stat_cartes_combat = Stats.new()
	for cible in effets_carte:
		if cible in GlobalData.classes:
			classes_target.append(cible)
		var affiche_log: bool = true
		var tag_cible: String = ""
		match cible:
			"tous":
				tag_cible = "Tout le monde"
			"autres":
				if len(classes_target) > 0:
					tag_cible = "Les non-" + GlobalData.classes_mapping[classes_target[0]]
				else:
					tag_cible = "Tout le monde"
			_:
				tag_cible = "Les " + GlobalData.classes_mapping[cible]
		for combattant in combattants:
			var new_effets: Array[Effet] = []
			for effet in combattant.effets:
				if not effet.is_carte:
					new_effets.append(effet)
			combattant.effets = new_effets
			
			if cible == "tous" or cible == combattant.classe or (cible == "autres" and not combattant.classe in classes_target):
				for effet in effets_carte[cible].keys():
					if effet == "SOIN":
						var effet_exec = Effet.new(
							combattant, combattant, effet, 
							{"base":{"valeur":effets_carte[cible][effet]}}, 
							false, combattant.grid_pos, false, null)
						var temp_soins = combattant.stats.soins
						combattant.stats.soins = 0
						effet_exec.execute()
						combattant.stats.soins = temp_soins
					elif effet in ["STABILISE", "NON_PORTABLE", "INTRANSPOSABLE"]:
						var sort_temp = Sort.new()
						sort_temp.nom = noms_cartes_combat[0]
						var effet_exec = Effet.new(
							combattant, combattant, effet, 
							{"base":{"duree":1}}, 
							false, combattant.grid_pos, false, sort_temp)
						effet_exec.debuffable = false
						effet_exec.is_carte = true
						effet_exec.tag_cible = tag_cible
						effet_exec.affiche_log = affiche_log
						effet_exec.execute()
						combattant.effets.append(effet_exec)
					else:
						combattant.stat_cartes_combat[effet] += effets_carte[cible][effet]
						if affiche_log:
							chat_log.stats(combattant, effets_carte[cible][effet], effet, 1, tag_cible)
			affiche_log = false


@rpc("any_peer")
func set_pret():
	adversaire_pret = true


@rpc("any_peer", "call_local")
func lance_game():
	attente_adversaire.visible = false
	for combattant in combattants:
		combattant.visible = true
	combattants[0].unselect()
	selection_id = 0
	combattants[selection_id].select()
	combattant_selection = combattants[selection_id]
	etat = 1
	tilemap.clear_layer(2)
	if GlobalData.is_multijoueur:
		cartes_combat.update(noms_cartes_combat)
		applique_carte_combat()
		timer.start(25)
	change_action(10)
	combattant_selection.debut_tour()


@rpc("any_peer", "call_local")
func change_action(new_action: int):
	if new_action >= len(combattant_selection.sorts):
		new_action = 10
	if new_action == action:
		action = 10
	else:
		action = new_action
	if 0 <= action and action < len(combattant_selection.sorts):
		combattant_selection.affiche_ldv(action)
		combattant_selection.affiche_zone(action, tilemap.local_to_map(get_viewport().get_mouse_position()) + offset)
	else:
		combattant_selection.affiche_path(tilemap.local_to_map(get_viewport().get_mouse_position()) + offset)
	if combattant_selection.equipe == int(Client.is_host) and GlobalData.is_multijoueur:
		tilemap.clear_layer(2)


@rpc("any_peer", "call_local")
func joue_action(action_id: int, grid_pos: Vector2i):
	combattant_selection.joue_action(action_id, grid_pos)


@rpc("any_peer", "call_local")
func change_orientation(orientation_id: int, combattant_id: int):
	combattants[combattant_id].change_orientation(orientation_id)


@rpc("any_peer", "call_local")
func place_perso(map_pos: Vector2i, combattant_id: int, swap: bool):
	combattants[combattant_id].place_perso(map_pos, swap)


@rpc("any_peer", "call_local")
func affiche_path(grid_pos: Vector2i):
	combattant_selection.affiche_path(grid_pos)


@rpc("any_peer", "call_local")
func affiche_zone(action_id: int, grid_pos: Vector2i):
	combattant_selection.affiche_zone(action_id, grid_pos)


func trigger_victoire(equipe: int):
	etat = 3
	texte_fin.text = "VICTOIRE\n" + ("BLEU" if equipe == 0 else "ROUGE")
	affichage_fin.visible = true


func check_perso(grid_pos: Vector2i) -> bool:
	for combattant in combattants:
		if combattant.grid_pos == grid_pos:
			return true
	return false


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
		if GlobalData.is_multijoueur:
			noms_cartes_combat.pop_front()
			ajoute_carte_combat()
			cartes_combat.update(noms_cartes_combat)
			applique_carte_combat()
	selection_id = new_selection_id
	combattants[selection_id].select()
	combattant_selection = combattants[selection_id]
	change_action(10)
	if old_id != combattant_selection.id:
		combattant_selection.debut_tour()
	timeline.init(combattants, selection_id)
	if compte_init != len(combattants):
		check_morts()


func _on_perso_clicked(id: int):
	if etat == 0 and (combattants[id].equipe != int(Client.is_host) or not GlobalData.is_multijoueur):
		combattants[selection_id].unselect()
		selection_id = id
		timeline.init(combattants, selection_id)
		combattants[selection_id].select()
		combattant_selection = combattants[selection_id]


func _input(event):
	if etat == 1:
		if Input.is_key_pressed(KEY_F1) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("passe_tour")
		if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
			affiche_quitter()
		if event is InputEventMouseMotion:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				if action == 10:
					for combattant in combattants:
						if combattant.is_hovered:
							return
					combattant_selection.affiche_path(tilemap.local_to_map(event.position) + offset)
				else:
					combattant_selection.affiche_zone(action, tilemap.local_to_map(event.position) + offset)
		if event is InputEventMouseButton and event.pressed:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				if spell_pressed:
					spell_pressed = false
					return
				sorts.carte_hovered = -1
				rpc("joue_action", action, tilemap.local_to_map(event.position) + offset)
		if Input.is_key_pressed(KEY_APOSTROPHE) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_action", 0)
		if Input.is_key_pressed(KEY_1) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_action", 1)
		if Input.is_key_pressed(KEY_2) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_action", 2)
		if Input.is_key_pressed(KEY_3) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_action", 3)
		if Input.is_key_pressed(KEY_4) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_action", 4)
		if Input.is_key_pressed(KEY_5) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_action", 5)
		if Input.is_key_pressed(KEY_6) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_action", 6)
		if Input.is_key_pressed(KEY_UP) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_orientation", 0, selection_id)
		if Input.is_key_pressed(KEY_RIGHT) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_orientation", 1, selection_id)
		if Input.is_key_pressed(KEY_DOWN) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_orientation", 2, selection_id)
		if Input.is_key_pressed(KEY_LEFT) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_orientation", 3, selection_id)
	if etat == 0:
		if Input.is_key_pressed(KEY_F1) and event is InputEventKey and not event.echo:
			attente_adversaire.visible = true
			if adversaire_pret:
				rpc("lance_game")
			rpc("set_pret")
		if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
			affiche_quitter()
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
					rpc("place_perso", tilemap.local_to_map(event.position), selection_id, false)
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
					rpc("place_perso", tilemap.local_to_map(event.position), selection_id, true)
		if Input.is_key_pressed(KEY_UP) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_orientation", 0, selection_id)
		if Input.is_key_pressed(KEY_RIGHT) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_orientation", 1, selection_id)
		if Input.is_key_pressed(KEY_DOWN) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_orientation", 2, selection_id)
		if Input.is_key_pressed(KEY_LEFT) and event is InputEventKey and not event.echo:
			if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
				rpc("change_orientation", 3, selection_id)


func _on_fleche_0_pressed():
	rpc("change_orientation", 0, selection_id)


func _on_fleche_1_pressed():
	rpc("change_orientation", 1, selection_id)


func _on_fleche_2_pressed():
	rpc("change_orientation", 2, selection_id)


func _on_fleche_3_pressed():
	rpc("change_orientation", 3, selection_id)


func _on_passe_tour_pressed():
	if etat == 1:
		if combattant_selection.equipe != int(Client.is_host) or not GlobalData.is_multijoueur:
			rpc("passe_tour")
	if etat == 0:
		attente_adversaire.visible = true
		if adversaire_pret:
			rpc("lance_game")
		rpc("set_pret")


func _on_choix_clicked(i, block, contenu, lanceur_id, cible_id, critique, nom_sort):
	rpc("choix_clicked", i, contenu, lanceur_id, cible_id, critique, nom_sort)
	block.queue_free()


@rpc("any_peer", "call_local")
func choix_clicked(i, contenu, lanceur_id, cible_id, critique, nom_sort):
	var lanceur
	var cible
	for combattant in combattants:
		if combattant.id == lanceur_id:
			lanceur = combattant
		if combattant.id == cible_id:
			cible = combattant
	var sort = GlobalData.sorts[nom_sort].copy()
	
	etat = 1
	var choix = contenu[contenu.keys()[i]]
	for effet in choix.keys():
		var new_categorie = effet
		var new_contenu = choix[effet]
		var new_effet = Effet.new(lanceur, cible, new_categorie, new_contenu, critique, cible.grid_pos, false, sort)
		new_effet.execute()
		if new_effet.duree > 0:
			cible.effets.append(new_effet)


func _on_bouton_retour_pressed():
	rpc("retour_pressed")


func affiche_quitter():
	get_node("MenuRetour").visible = true


@rpc("any_peer", "call_local")
func retour_pressed():
	get_tree().change_scene_to_file("res://UI/choix_map.tscn")


func _on_timer_timeout():
	if etat == 1 and combattant_selection.equipe != int(Client.is_host):
		rpc("passe_tour")
	if etat == 0 and Client.is_host:
		rpc("lance_game")


func _on_quitter_pressed():
	rpc("retour_pressed")
