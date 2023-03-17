extends Node2D
class_name Combattant


signal clicked
signal movement_finished


var classe: String
var nom: String
var personnage_ref: Personnage
var is_invocation: bool
var stats: Stats
var max_stats: Stats
var init_stats: Stats
var stat_buffs: Stats
var stat_ret: Stats
var stat_cartes_combat: Stats
var buffs_hp: Array
var initiative_random: float
var equipements: Dictionary
var sorts: Array[Sort]
var equipe: int
var effets: Array[Effet]
var combat: Combat

var grid_pos: Vector2i
var id: int
var orientation: int
var compte_sorts: int
var all_path: Array[Vector2i]
var path_actuel: Array[Vector2i]
var all_ldv: Array[Vector2i]
var zone: Array[Vector2i]
var positions_chemin: Array[Vector2]
var porte: Combattant
var porteur: Combattant

var is_selected: bool
var is_hovered: bool
var is_mort: bool
var is_visible: bool

var cercle_bleu = preload("res://Fight/Images/cercle_personnage_bleu.png")
var cercle_rouge = preload("res://Fight/Images/cercle_personnage_rouge.png")
var outline_shader = preload("res://Fight/Shaders/combattant_outline.gdshader")

@onready var cercle: Sprite2D = $Cercle
@onready var fleche: Sprite2D = $Fleche
@onready var classe_sprite: Sprite2D = $Personnage/Classe
@onready var personnage: Sprite2D = $Personnage
@onready var hp: Sprite2D = $HP
@onready var hp_label: Label = $HP/Label
@onready var nom_label: RichTextLabel = $HP/Nom
@onready var stats_perdu: Label = $StatsPerdu


func _ready():
	effets = []
	positions_chemin = []
	classe_sprite.material = ShaderMaterial.new()
	classe_sprite.material.shader = outline_shader
	classe_sprite.material.set_shader_parameter("width", 0.0)
	orientation = 1
	stat_buffs = Stats.new()
	stat_ret = Stats.new()
	stat_cartes_combat = Stats.new()
	is_selected = false
	is_hovered = false
	is_invocation = false
	is_visible = true
	hp_label.text = str(stats.hp) + "/" + str(max_stats.hp)
	combat = get_parent()


func _process(delta):
	if len(positions_chemin) > 0:
		combat.etat = 2
		if position.distance_to(positions_chemin[0]) < 10.0:
			position = positions_chemin[0]
			positions_chemin.pop_front()
			if len(positions_chemin) == 0:
				combat.etat = 1
				emit_signal("movement_finished")
		else:
			var direction: Vector2 = position.direction_to(positions_chemin[0])
			position += direction * delta * 300.0
		if porte != null:
			porte.position = position + Vector2(0, -90)


func update_visuel():
	if equipe == 0:
		cercle.texture = cercle_bleu
	else:
		cercle.texture = cercle_rouge
	classe_sprite.texture = load(
		"res://Classes/" + classe + "/" + classe.to_lower() + ".png"
	)
	if equipements["Capes"]:
		personnage.get_node("Cape").texture = load(
			"res://Equipements/Capes/Sprites/" + equipements["Capes"].to_lower() + ".png"
		)
	if equipements["Coiffes"]:
		personnage.get_node("Coiffe").texture = load(
			"res://Equipements/Coiffes/Sprites/" + equipements["Coiffes"].to_lower() + ".png"
		)


func select():
	classe_sprite.material.set_shader_parameter("width", 2.0)
	combat.stats_select.update(stats)
	is_selected = true
	if not is_invocation:
		combat.sorts.update(self)
		combat.sorts_bonus.update(self)


func unselect():
	classe_sprite.material.set_shader_parameter("width", 0.0)
	is_selected = false


func from_personnage(p_personnage: Personnage, equipe_id: int):
	classe = p_personnage.classe
	nom = p_personnage.nom
	personnage_ref = p_personnage
	stats = p_personnage.stats.copy()
	initiative_random = float(stats.initiative) + GlobalData.rng.randf()
	max_stats = stats.copy()
	init_stats = stats.copy()
	equipements = p_personnage.equipements
	sorts = [Sort.new().from_arme(self, equipements["Armes"])]
	for sort in p_personnage.sorts:
		var new_sort: Sort = GlobalData.sorts[sort].copy()
		new_sort.nom = sort
		sorts.append(new_sort)
	compte_sorts = len(sorts)
	equipe = equipe_id
	return self


func change_orientation(new_orientation: int):
	fleche.texture = load("res://Fight/Images/fleche_" + str(new_orientation) + "_filled.png")
	orientation = new_orientation


func affiche_path(pos_event: Vector2i):
	all_ldv = []
	zone = []
	for combattant in combat.combattants:
		if GlobalData.is_multijoueur and (Client.is_host and combattant.equipe == 1 or not Client.is_host and combattant.equipe == 0):
			if not combattant.is_visible:
				combat.tilemap.a_star_grid.set_point_solid(combattant.grid_pos, false)
	all_path = combat.tilemap.get_atteignables(grid_pos, stats.pm)
	var path: Array[Vector2i] = combat.tilemap.get_chemin(grid_pos, pos_event)
	for combattant in combat.combattants:
		combat.tilemap.a_star_grid.set_point_solid(combattant.grid_pos)
	if check_etats(["IMMOBILISE"]):
		all_path = []
		path = []
	if len(path) > 0 and len(path) <= stats.pm + 1:
		path.pop_front()
		path_actuel = path
		combat.tilemap.clear_layer(2)
		for cell in path:
			combat.tilemap.set_cell(2, cell - combat.offset, 3, Vector2i(1, 0))
	else:
		path_actuel = []
		combat.tilemap.clear_layer(2)
		for cell in all_path:
			combat.tilemap.set_cell(2, cell - combat.offset, 3, Vector2i(1, 0))


func affiche_ldv(action: int):
	all_path = []
	path_actuel = []
	calcul_all_ldv(action)
	combat.tilemap.clear_layer(2)
	for cell in all_ldv:
		combat.tilemap.set_cell(2, cell - combat.offset, 3, Vector2i(2, 0))


func affiche_zone(action: int, pos_event: Vector2i):
	all_path = []
	path_actuel = []
	var sort: Sort
	if action < len(sorts):
		sort = sorts[action]
	combat.tilemap.clear_layer(2)
	for cell in all_ldv:
		combat.tilemap.set_cell(2, cell - combat.offset, 3, Vector2i(2, 0))
	if pos_event in all_ldv:
		zone = combat.tilemap.get_zone(
			grid_pos,
			pos_event,
			sort.type_zone,
			sort.taille_zone[0],
			sort.taille_zone[1]
		)
		for cell in zone:
			combat.tilemap.set_cell(2, cell - combat.offset, 3, Vector2i(0, 0))


func calcul_path_actuel(pos_event: Vector2i):
	var path: Array[Vector2i] = combat.tilemap.get_chemin(grid_pos, pos_event)
	if check_etats(["IMMOBILISE"]):
		all_path = []
		path = []
	if len(path) > 0 and len(path) <= stats.pm + 1:
		path.pop_front()
		path_actuel = path
	else:
		path_actuel = []


func calcul_all_ldv(action: int):
	var sort: Sort
	sort = sorts[action]
	if not sort.precheck_cast(self):
		combat.change_action(10)
		return
	var bonus_po: int = stats.po if sort.po_modifiable else (stats.po if stats.po < 0 else 0)
	var po_max: int = sort.po[1] + bonus_po if sort.po[1] + bonus_po >= sort.po[0] else sort.po[0]
	po_max = 1 if sort.po[1] > 0 and po_max <= 0 else po_max
	all_ldv = combat.tilemap.get_ldv(
		grid_pos, 
		sort.po[0],
		po_max,
		sort.type_ldv,
		sort.ldv
	)
	var valides: Array[Vector2i] = []
	for tile in all_ldv:
		if sort.check_cible(self, tile):
			valides.append(tile)
	all_ldv = valides


func calcul_zone(action: int, pos_event: Vector2i):
	var sort: Sort
	if action < len(sorts):
		sort = sorts[action]
	if pos_event in all_ldv:
		zone = combat.tilemap.get_zone(
			grid_pos,
			pos_event,
			sort.type_zone,
			sort.taille_zone[0],
			sort.taille_zone[1]
		)


func check_case_bonus():
	if check_etats(["PORTE"]):
		return
	var case_id: int = combat.tilemap.get_cell_atlas_coords(1, grid_pos - combat.offset).x
	var categorie: String = ""
	var contenu = ""
	var maudit: bool = false
	if grid_pos in combat.tilemap.cases_maudites.values():
		maudit = true
	var sort_temp: Sort = Sort.new()
	match case_id:
		2:
			categorie = "CHANGE_STATS"
			var valeur: int = 30 * -(int(maudit) * 2 - 1) * (int(combat.tour >= 15 and GlobalData.mort_subite_active) + 1)
			contenu = {
				"dommages_air":{"base":{"valeur":valeur,"duree":1}},
				"dommages_terre":{"base":{"valeur":valeur,"duree":1}},
				"dommages_feu":{"base":{"valeur":valeur,"duree":1}},
				"dommages_eau":{"base":{"valeur":valeur,"duree":1}}
			}
			sort_temp.nom = "case_ardeur"
		3:
			categorie = "CHANGE_STATS"
			var valeur: int = 30 * -(int(maudit) * 2 - 1) * (int(combat.tour >= 15 and GlobalData.mort_subite_active) + 1)
			contenu = {
				"resistances_air":{"base":{"valeur":valeur,"duree":1}},
				"resistances_terre":{"base":{"valeur":valeur,"duree":1}},
				"resistances_feu":{"base":{"valeur":valeur,"duree":1}},
				"resistances_eau":{"base":{"valeur":valeur,"duree":1}}
			}
			sort_temp.nom = "case_bouclier"
		4:
			categorie = "SOIN" if not maudit else "DOMMAGE_FIXE"
			var valeur: int =  7 * (int(combat.tour >= 15 and GlobalData.mort_subite_active) + 1)
			contenu = {"base":{"valeur":valeur}}
			sort_temp.nom = "case_coeur_soignant"
		5:
			categorie = "CHANGE_STATS"
			var valeur: int = 2 * -(int(maudit) * 2 - 1) * (int(combat.tour >= 15 and GlobalData.mort_subite_active) + 1)
			contenu = {"pa":{"base":{"valeur":valeur,"duree":1}}}
			sort_temp.nom = "case_motivation"
		6:
			categorie = "CHANGE_STATS"
			var valeur: int = 2 * -(int(maudit) * 2 - 1) * (int(combat.tour >= 15 and GlobalData.mort_subite_active) + 1)
			contenu = {"po":{"base":{"valeur":valeur,"duree":1}}}
			sort_temp.nom = "case_oeil_de_lynx"
		7:
			categorie = "CHANGE_STATS"
			var valeur: int = 25 * -(int(maudit) * 2 - 1) * (int(combat.tour >= 15 and GlobalData.mort_subite_active) + 1)
			contenu = {"soins":{"base":{"valeur":valeur,"duree":1}}}
			sort_temp.nom = "case_panacee"
		8:
			categorie = "DOMMAGE_POURCENT"
			contenu = {"base":{"valeur":80.0 if combat.tour < 15 and not maudit else (99.84 if combat.tour >= 15 and GlobalData.mort_subite_active and maudit else 96.0)}}
			sort_temp.nom = "case_tueuse"
		9:
			categorie = "DOMMAGE_FIXE"
			var valeur: int = 15 * (int(maudit) + 1) * (int(combat.tour >= 15 and GlobalData.mort_subite_active) + 1)
			contenu = {"base":{"valeur":valeur}}
			sort_temp.nom = "case_piegee"
	
	var effet: Effet = Effet.new(self, self, categorie, contenu, false, grid_pos, false, sort_temp)
	effet.debuffable = false
	var temp_soins: int = stats.soins
	stats.soins = 0
	effet.execute()
	stats.soins = temp_soins
	if effet.duree > 0:
		effets.append(effet)


func desactive_cadran():
	for combattant in combat.combattants:
		if combattant.is_invocation and combattant.invocateur.id == id and combattant.classe == "Cadran_De_Xelor":
			combat.tilemap.grid[combattant.grid_pos[0]][combattant.grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, combattant.grid_pos - combat.offset).x


func active_cadran():
	for combattant in combat.combattants:
		if combattant.is_invocation and combattant.invocateur.id == id:
			combat.tilemap.grid[combattant.grid_pos[0]][combattant.grid_pos[1]] = -2


func joue_action(action: int, tile_pos: Vector2i):
	if action == 10:
		calcul_path_actuel(tile_pos)
		if len(path_actuel) > 0:
			deplace_perso(path_actuel)
			combat.stats_select.update(stats)
			combat.check_morts()
	elif action < len(sorts):
		calcul_all_ldv(action)
		calcul_zone(action, tile_pos)
		if not tile_pos in all_ldv:
			combat.change_action(10)
			return
		var sort: Sort = sorts[action]
		stats.pa -= sort.pa
		stats_perdu.ajoute(-sort.pa, "pa")
		for effet in effets:
			if effet.etat == "DOMMAGE_SI_UTILISE_PA" and (effet.sort.nom != sort.nom or effet.lanceur.id != id):
				for i in range(sort.pa):
					effet.execute()
		var _valide: bool = false
		if check_etats(["RATE_SORT"]) and action < compte_sorts:
			_valide = true
			retire_etats(["RATE_SORT"])
		else:
			_valide = sort.execute_effets(self, zone, tile_pos)
		if not is_invocation:
			combat.sorts.update(self)
		if tile_pos != grid_pos or not sort.effets.has("DEVIENT_INVISIBLE"):
			combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = -2
			retire_etats(["INVISIBLE"])
			visible = true
			personnage.modulate = Color(1, 1, 1, 1)
			classe_sprite.material.set_shader_parameter("alpha", 1.0)
			is_visible = true
		if grid_pos != tile_pos:
			oriente_vers(tile_pos)
		combat.change_action(10)
		combat.stats_select.update(stats)
		combat.check_morts()
#	combat.tilemap.affiche_ldv_obstacles()


func affiche_stats_change(valeur: int, stat: String):
	stats_perdu.ajoute(valeur, stat)


func check_tacle_unit(case: Vector2i) -> bool:
	if check_etats(["PORTE"]) or not is_visible:
		return false
	var voisins: Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	var blocage_total: int = 0
	for combattant in combat.combattants:
		if combattant.equipe == equipe or combattant.check_etats(["PORTE", "PETRIFIE"]) or not combattant.is_visible:
			continue
		if (combattant.grid_pos - case) in voisins:
			blocage_total += combattant.stats.blocage
	var min_esquive: int = max(stats.esquive - 99, 1)
	var max_esquive: int = max(stats.esquive, 2)
	if GlobalData.rng.randi_range(min_esquive, max_esquive) < blocage_total:
		return true
	return false


func deplace_perso(chemin: Array):
	if stats.pm <= 0:
		return
	var tacled: bool = check_tacle_unit(grid_pos)
	var pm_utilise: int = 0
	for effet in effets:
		if effet.etat == "DOMMAGE_SI_BOUGE":
			effet.execute()
	positions_chemin = []
	if not tacled:
		for case in chemin:
			pm_utilise += 1
			var precedent: Vector2i = grid_pos
			var tile_pos: Vector2i = case - combat.offset
			var old_grid_pos: Vector2i = grid_pos
			var old_map_pos: Vector2i = grid_pos - combat.offset
			combat.tilemap.a_star_grid.set_point_solid(old_grid_pos, false)
			combat.tilemap.grid[old_grid_pos[0]][old_grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, old_map_pos).x
			positions_chemin.append(combat.tilemap.map_to_local(tile_pos))
			grid_pos = case
			combat.tilemap.a_star_grid.set_point_solid(case)
			if not check_etats(["INVISIBLE"]):
				combat.tilemap.grid[case[0]][case[1]] = -2
			oriente_vers(grid_pos + (grid_pos - precedent))
			if porte != null:
				porte.grid_pos = grid_pos
			if porteur != null:
				retire_etats(["PORTE"])
				porteur.retire_etats(["PORTE_ALLIE", "PORTE_ENNEMI"])
				z_index = 1
				combat.tilemap.a_star_grid.set_point_solid(old_grid_pos)
				combat.tilemap.grid[old_grid_pos[0]][old_grid_pos[1]] = -2
				porteur.porte = null
				porteur = null
			if not check_etats(["INVISIBLE"]):
				visible = true
				personnage.modulate = Color(1, 1, 1, 1)
				classe_sprite.material.set_shader_parameter("alpha", 1.0)
				is_visible = true
			combat.tilemap.update_glyphes()
			if stats.hp <= 0:
				break
			if check_tacle_unit(grid_pos):
				break
	stats.pm -= pm_utilise
	stats_perdu.ajoute(-pm_utilise, "pm")
	combat.tilemap.clear_layer(2)
	if grid_pos != chemin[-1]:
		combat.passe_tour()


func place_perso(tile_pos: Vector2i, swap: bool):
	var tile_data = combat.tilemap.get_cell_atlas_coords(2, tile_pos)
	if (tile_data.x == 0 and equipe == 1) or (tile_data.x == 2 and equipe == 0):
		var new_grid_pos: Vector2i = tile_pos + combat.offset
		var place_libre: bool = true
		var target
		for combattant in combat.combattants:
			if combattant.grid_pos == new_grid_pos:
				place_libre = false
				target = combattant
		if place_libre:
			var old_grid_pos: Vector2i = grid_pos
			var old_map_pos: Vector2i = grid_pos - combat.offset
			combat.tilemap.a_star_grid.set_point_solid(old_grid_pos, false)
			combat.tilemap.grid[old_grid_pos[0]][old_grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, old_map_pos).x
			position = combat.tilemap.map_to_local(tile_pos)
			grid_pos = new_grid_pos
			combat.tilemap.a_star_grid.set_point_solid(grid_pos)
			combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = -2
		elif swap:
			var old_grid_pos: Vector2i = grid_pos
			var old_position: Vector2i = position
			grid_pos = target.grid_pos
			position = target.position
			target.grid_pos = old_grid_pos
			target.position = old_position


func bouge_perso(new_pos: Vector2i):
	var old_grid_pos: Vector2i = grid_pos
	var old_map_pos: Vector2i = grid_pos - combat.offset
	combat.tilemap.a_star_grid.set_point_solid(old_grid_pos, false)
	combat.tilemap.grid[old_grid_pos[0]][old_grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, old_map_pos).x
	position = combat.tilemap.map_to_local(new_pos - combat.offset)
	grid_pos = new_pos
	combat.tilemap.a_star_grid.set_point_solid(grid_pos)
	combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = -2
	combat.tilemap.update_glyphes()


func echange_positions(combattant):
	var old_grid_pos: Vector2i = grid_pos
	var old_position: Vector2 = position
	grid_pos = combattant.grid_pos
	position = combattant.position
	combattant.grid_pos = old_grid_pos
	combattant.position = old_position


func oriente_vers(pos: Vector2i):
	var ref_vectors: Array[Vector2] = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	var min_dist: float = 999999999.0
	var min_vec: int = 0
	for i in range(len(ref_vectors)):
		var new_dist: float = Vector2(pos).distance_to(Vector2(grid_pos) + ref_vectors[i])
		if new_dist < min_dist:
			min_dist = new_dist
			min_vec = i
	change_orientation(min_vec)


func debut_tour():
	visible = true
	personnage.modulate = Color(1, 1, 1, 1)
	classe_sprite.material.set_shader_parameter("alpha", 1.0)
	is_visible = true
	var old_pa: int = stats.pa
	var old_pm: int = stats.pm
	var delta_hp: int = max_stats.hp - stats.hp
	var start_hp: int = stats.hp
	retrait_durees()
	execute_effets(false)
	check_case_bonus()
	var effets_hp: int = start_hp - stats.hp
	desactive_cadran()
	var temp_stats: Stats = init_stats.copy().add(stat_buffs).add(stat_cartes_combat)
	stats = init_stats.copy().add(stat_ret).add(stat_buffs).add(stat_cartes_combat)
	stats.pa = temp_stats.pa if old_pa >= temp_stats.pa else stats.pa
	stats.pm = temp_stats.pm if old_pm >= temp_stats.pm else stats.pm
	stats.hp -= delta_hp + effets_hp
	execute_buffs_hp(false)
	all_path = combat.tilemap.get_atteignables(grid_pos, stats.pm)
	if check_etats(["PETRIFIE"]):
		combat.passe_tour()
	if not check_etats(["INVISIBLE"]):
		combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = -2
	if check_etats(["IMMOBILISE"]):
		stats.pm = 0
	combat.check_morts()
	stats.pa = 0 if stats.pa < 0 else stats.pa
	stats.pm = 0 if stats.pm < 0 else stats.pm
#	combat.tilemap.affiche_ldv_obstacles()


func fin_tour():
	active_cadran()
	retrait_cooldown()
	stat_ret = Stats.new()
	var delta_hp: int = max_stats.hp - stats.hp
	stats = init_stats.copy().add(stat_buffs).add(stat_cartes_combat)
	stats.hp -= delta_hp
	execute_buffs_hp(false)
	combat.check_morts()


func meurt():
	var is_porteur: bool = false
	var is_porte: bool = false
	if check_etats(["PORTE_ALLIE", "PORTE_ENNEMI"]):
		var effet_lance = Effet.new(self, grid_pos, "LANCE", 1, false, grid_pos, false, null)
		effet_lance.execute()
		is_porteur = true
	for effet in effets:
		if effet.etat == "PORTE":
			is_porte = true
			for combattant in combat.combattants:
				if combattant.id == effet.lanceur.id:
					combattant.retire_etats(["PORTE_ALLIE", "PORTE_ENNEMI"])
	
	for combattant in combat.combattants:
		var new_effets: Array[Effet] = []
		for effet in combattant.effets:
			if effet.lanceur.id != id:
				new_effets.append(effet)
		var new_buffs_hp: Array = []
		for buff_hp in combattant.buffs_hp:
			if buff_hp["lanceur"] == id:
				combattant.stats.hp -= buff_hp["valeur"]
				combattant.max_stats.hp -= buff_hp["valeur"]
			else:
				new_buffs_hp.append(buff_hp)
		combattant.effets = new_effets
		combattant.buffs_hp = new_buffs_hp
	
	if (not is_porteur) and (not is_porte):
		var map_pos: Vector2i = combat.tilemap.local_to_map(position)
		combat.tilemap.a_star_grid.set_point_solid(grid_pos, false)
		combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, map_pos).x
	else:
		combat.tilemap.a_star_grid.set_point_solid(grid_pos, true)
		combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = -2
	is_mort = true
	combat.chat_log.generic(self, "est mort")
	queue_free()


func execute_buffs_hp(update_max=true):
	for buff_hp in buffs_hp:
		stats.hp += buff_hp["valeur"]
		if update_max:
			max_stats.hp += buff_hp["valeur"]


func execute_effets(desactive_degats=true):
	stat_buffs = Stats.new()
	var triggers: Array[String] = ["DOMMAGE_SI_BOUGE", "DOMMAGE_SI_UTILISE_PA"]
	for effet in effets:
		if effet.categorie in ["DOMMAGE_FIXE", "SOIN"] and (id != combat.combattant_selection.id or desactive_degats):
			continue
		if not effet.etat in triggers:
			effet.execute()


func check_etats(etats: Array) -> bool:
	if "VIE_FAIBLE" in etats and stats.hp < int(max_stats.hp / 4.0):
		return true
	for effet in effets:
		if effet.etat in etats:
			return true
	return false


func retire_etats(etats: Array):
	var new_effets: Array[Effet] = []
	for effet in effets:
		if effet.etat not in etats:
			new_effets.append(effet)
	effets = new_effets


func retrait_durees():
	for combattant in combat.combattants:
		var new_effets: Array[Effet] = []
		for effet in combattant.effets:
			if effet.lanceur.id == id and not effet.is_carte:
				effet.duree -= 1
			if effet.duree > 0:
				new_effets.append(effet)
		var new_buffs_hp: Array = []
		for buff_hp in combattant.buffs_hp:
			if buff_hp["lanceur"] == id:
				buff_hp["duree"] -= 1
			if buff_hp["duree"] > 0:
				new_buffs_hp.append(buff_hp)
		var old_pa: int = combattant.stats.pa
		var old_pm: int = combattant.stats.pm
		combattant.buffs_hp = new_buffs_hp
		combattant.effets = new_effets
		combattant.stat_buffs = Stats.new()
		var delta_hp: int = combattant.max_stats.hp - combattant.stats.hp
		combattant.max_stats = combattant.init_stats.copy()
		combattant.execute_effets()
		var temp_stats: Stats = combattant.init_stats.copy().add(combattant.stat_buffs).add(combattant.stat_cartes_combat)
		combattant.stats = combattant.init_stats.copy().add(combattant.stat_ret).add(combattant.stat_buffs).add(combattant.stat_cartes_combat)
		combattant.stats.pa = temp_stats.pa if old_pa >= temp_stats.pa else combattant.stats.pa
		combattant.stats.pm = temp_stats.pm if old_pm >= temp_stats.pm else combattant.stats.pm
		combattant.stats.hp -= delta_hp
		combattant.execute_buffs_hp()
	
	var new_map_glyphes: Array = []
	for glyphe in combat.tilemap.glyphes:
		if glyphe.lanceur.id == id:
			glyphe.duree -= 1
		if glyphe.duree > 0:
			if len(new_map_glyphes) < 1:
				new_map_glyphes = [glyphe]
			else:
				new_map_glyphes.append(glyphe)
	combat.tilemap.glyphes = new_map_glyphes
	for combattant in combat.combattants:
		if not combattant.check_etats(["INVISIBLE"]):
			combat.tilemap.grid[combattant.grid_pos[0]][combattant.grid_pos[1]] = -2
	combat.tilemap.update_glyphes()
	
	if combat.tilemap.cases_maudites.has(id):
		combat.tilemap.cases_maudites.erase(id)
	combat.tilemap.update_effets_map()


func retrait_cooldown():
	for sort in sorts:
		if sort.cooldown_actuel > 0:
			sort.cooldown_actuel -= 1
		sort.compte_lancers_tour = 0
		sort.compte_cible = {}


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if is_hovered:
			emit_signal("clicked")


func _on_area_2d_mouse_entered():
	for combattant in combat.combattants:
		if combattant.is_hovered:
			combattant._on_area_2d_mouse_exited()
	classe_sprite.material.set_shader_parameter("width", 3.0)
	is_hovered = true
	combat.stats_hover.update(stats, max_stats)
	combat.stats_hover.visible = true
	hp_label.text = str(stats.hp) + "/" + str(max_stats.hp)
	nom_label.text = "[center]" + nom
	hp.visible = true
	if combat.action == 10:
		affiche_path(Vector2i(99, 99))


func _on_area_2d_mouse_exited():
	if is_hovered:
		classe_sprite.material.set_shader_parameter("width", 0.0)
		is_hovered = false
		if is_selected:
			classe_sprite.material.set_shader_parameter("width", 2.0)
		combat.stats_hover.visible = false
		hp.visible = false
