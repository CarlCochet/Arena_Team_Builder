extends Node2D
class_name Combattant


signal clicked


var classe: String
var is_invocation: bool
var stats: Stats
var max_stats: Stats
var init_stats: Stats
var stat_buffs: Stats
var stat_ret: Stats
var equipements: Dictionary
var sorts: Array
var equipe: int
var effets: Array
var combat: Combat

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

@onready var cercle: Sprite2D = $Cercle
@onready var fleche: Sprite2D = $Fleche
@onready var classe_sprite: Sprite2D = $Classe
@onready var hp: Sprite2D = $HP
@onready var hp_label: Label = $HP/Label
@onready var stats_perdu: Label = $StatsPerdu


func _ready():
	effets = []
	classe_sprite.material = ShaderMaterial.new()
	classe_sprite.material.shader = outline_shader
	classe_sprite.material.set_shader_parameter("width", 0.0)
	orientation = 1
	stat_buffs = Stats.new()
	stat_ret = Stats.new()
	is_selected = false
	is_hovered = false
	is_invocation = false
	hp_label.text = str(stats.hp) + "/" + str(max_stats.hp)
	combat = get_parent()


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
	combat.stats_select.update(stats)
	is_selected = true
	if not is_invocation:
		combat.sorts.update(self)


func unselect():
	classe_sprite.material.set_shader_parameter("width", 0.0)
	is_selected = false


func from_personnage(personnage: Personnage, equipe_id: int):
	classe = personnage.classe
	stats = personnage.stats.copy()
	max_stats = stats.copy()
	init_stats = stats.copy()
	equipements = personnage.equipements
	sorts = [Sort.new().from_arme(self, equipements["Armes"])]
	for sort in personnage.sorts:
		var new_sort = GlobalData.sorts[sort].copy()
		new_sort.nom = sort
		sorts.append(new_sort)
	equipe = equipe_id
	return self


func change_orientation(new_orientation: int):
	fleche.texture = load("res://Fight/Images/fleche_" + str(new_orientation) + ".png")
	orientation = new_orientation


func affiche_path(pos_event: Vector2i):
	all_ldv = []
	zone = []
	all_path = combat.tilemap.get_atteignables(grid_pos, stats.pm)
	var path = combat.tilemap.get_chemin(grid_pos, pos_event)
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
	var sort
	sort = sorts[action]
	if not sort.precheck_cast(self):
		combat.change_action(7)
		return
	var bonus_po = stats.po if sort.po_modifiable else (stats.po if stats.po < 0 else 0)
	var po_max = sort.po[1] + bonus_po if sort.po[1] + bonus_po >= sort.po[0] else sort.po[0]
	po_max = 1 if sort.po[1] > 0 and po_max <= 0 else po_max
	all_ldv = combat.tilemap.get_ldv(
		grid_pos, 
		sort.po[0],
		po_max,
		sort.type_ldv,
		sort.ldv
	)
	var valides = []
	for tile in all_ldv:
		if sort.check_cible(self, tile):
			valides.append(tile)
	all_ldv = valides
	combat.tilemap.clear_layer(2)
	for cell in all_ldv:
		combat.tilemap.set_cell(2, cell - combat.offset, 3, Vector2i(2, 0))


func affiche_zone(action: int, pos_event: Vector2i):
	all_path = []
	path_actuel = []
	var sort
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


func check_case_bonus():
	var case_id = combat.tilemap.get_cell_atlas_coords(1, grid_pos - combat.offset).x
	var categorie = ""
	var contenu = ""
	var maudit = false
	if grid_pos in combat.tilemap.cases_maudites.values():
		maudit = true
	match case_id:
		2:
			categorie = "CHANGE_STATS"
			var valeur = 30 * -(int(maudit) * 2 - 1) * (int(combat.tour >= 15) + 1)
			contenu = {
				"dommages_air":{"base":{"valeur":valeur,"duree":1}},
				"dommages_terre":{"base":{"valeur":valeur,"duree":1}},
				"dommages_feu":{"base":{"valeur":valeur,"duree":1}},
				"dommages_eau":{"base":{"valeur":valeur,"duree":1}}
			}
		3:
			categorie = "CHANGE_STATS"
			var valeur = 30 * -(int(maudit) * 2 - 1) * (int(combat.tour >= 15) + 1)
			contenu = {
				"resistances_air":{"base":{"valeur":valeur,"duree":1}},
				"resistances_terre":{"base":{"valeur":valeur,"duree":1}},
				"resistances_feu":{"base":{"valeur":valeur,"duree":1}},
				"resistances_eau":{"base":{"valeur":valeur,"duree":1}}
			}
		4:
			categorie = "SOIN" if not maudit else "DOMMAGE_FIXE"
			var valeur =  7 * (int(combat.tour >= 15) + 1)
			contenu = {"base":{"valeur":valeur}}
		5:
			categorie = "CHANGE_STATS"
			var valeur = 2 * -(int(maudit) * 2 - 1) * (int(combat.tour >= 15) + 1)
			contenu = {"pa":{"base":{"valeur":valeur,"duree":1}}}
		6:
			categorie = "CHANGE_STATS"
			var valeur = 2 * -(int(maudit) * 2 - 1) * (int(combat.tour >= 15) + 1)
			contenu = {"po":{"base":{"valeur":valeur,"duree":1}}}
		7:
			categorie = "CHANGE_STATS"
			var valeur = 25 * -(int(maudit) * 2 - 1) * (int(combat.tour >= 15) + 1)
			contenu = {"soins":{"base":{"valeur":valeur,"duree":1}}}
		8:
			categorie = "DOMMAGE_POURCENT"
			contenu = {"base":{"valeur":80.0 if combat.tour < 15 and not maudit else (99.84 if combat.tour >= 15 and maudit else 96.0)}}
		9:
			categorie = "DOMMAGE_FIXE"
			var valeur = 15 * (int(maudit) + 1) * (int(combat.tour >= 15) + 1)
			contenu = {"base":{"valeur":valeur}}
	var effet = Effet.new(self, self, categorie, contenu, false, grid_pos, false, null)
	effet.execute()


func desactive_cadran():
	for combattant in combat.combattants:
		if combattant.is_invocation and combattant.invocateur.id == id:
			combat.tilemap.grid[combattant.grid_pos[0]][combattant.grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, combattant.grid_pos - combat.offset).x


func active_cadran():
	for combattant in combat.combattants:
		if combattant.is_invocation and combattant.invocateur.id == id:
			combat.tilemap.grid[combattant.grid_pos[0]][combattant.grid_pos[1]] = -2


func debut_tour():
	retrait_durees()
	execute_effets()
	check_case_bonus()
	desactive_cadran()
	var delta_hp = max_stats.hp - stats.hp
	stats = init_stats.copy().add(stat_ret).add(stat_buffs)
	stats.hp -= delta_hp
	all_path = combat.tilemap.get_atteignables(grid_pos, stats.pm)
	if check_etats(["PETRIFIE"]):
		combat.passe_tour()
	if not check_etats(["INVISIBLE"]):
		combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = -2
	combat.check_morts()


func fin_tour():
	active_cadran()
	retrait_cooldown()
	stat_ret = Stats.new()
	var temp_hp = stats.hp
	stats = init_stats.copy().add(stat_buffs)
	stats.hp = temp_hp
	combat.check_morts()


func joue_action(action: int, tile_pos: Vector2i):
	if action == 7 and len(path_actuel) > 0:
		deplace_perso(path_actuel)
	elif action < len(sorts):
		if not tile_pos in all_ldv:
			combat.change_action(7)
			return
		var sort: Sort = sorts[action]
		var valide = false
		if check_etats(["RATE_SORT"]):
			valide = true
			retire_etats(["RATE_SORT"])
		else:
			valide = sort.execute_effets(self, zone, tile_pos)
		if valide:
			stats.pa -= sort.pa
			stats_perdu.ajoute(-sort.pa, "pa")
			for effet in effets:
				if effet.etat == "DOMMAGE_SI_UTILISE_PA":
					for i in range(sort.pa):
						effet.execute()
			if not is_invocation:
				combat.sorts.update(self)
			if tile_pos != grid_pos or not sort.effets.has("DEVIENT_INVISIBLE"):
				combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = -2
				retire_etats(["INVISIBLE"])
			if grid_pos != tile_pos:
				oriente_vers(tile_pos)
		combat.change_action(7)
	combat.stats_select.update(stats)
	combat.check_morts()


func affiche_stats_change(valeur, stat):
	stats_perdu.ajoute(valeur, stat)


func check_tacle_unit(case: Vector2i) -> bool:
	var voisins = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	var blocage_total = 0
	for combattant in combat.combattants:
		if combattant.equipe == equipe or combattant.check_etats(["PORTE", "PETRIFIE"]):
			continue
		if (combattant.grid_pos - case) in voisins:
			blocage_total += combattant.stats.blocage
	var min_esquive = max(stats.esquive - 99, 1)
	var max_esquive = max(stats.esquive, 2)
	if randi_range(min_esquive, max_esquive) < blocage_total:
		return true
	return false


func deplace_perso(chemin: Array):
	var tacled = check_tacle_unit(grid_pos)
	var pm_utilise = 0
	for effet in effets:
		if effet.etat == "DOMMAGE_SI_BOUGE":
			effet.execute()
	if not tacled:
		for case in chemin:
			pm_utilise += 1
			var precedent = grid_pos
			var tile_pos = case - combat.offset
			var old_grid_pos = grid_pos
			var old_map_pos = grid_pos - combat.offset
			combat.tilemap.a_star_grid.set_point_solid(old_grid_pos, false)
			combat.tilemap.grid[old_grid_pos[0]][old_grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, old_map_pos).x
			position = combat.tilemap.map_to_local(tile_pos)
			grid_pos = case
			combat.tilemap.a_star_grid.set_point_solid(case)
			if not check_etats(["INVISIBLE"]):
				combat.tilemap.grid[case[0]][case[1]] = -2
			oriente_vers(grid_pos + (grid_pos - precedent))
			for combattant in combat.combattants:
				for effet in combattant.effets:
					if effet.etat == "PORTE" and effet.lanceur.id == id:
						combattant.position = position + Vector2(0, -90)
						combattant.grid_pos = grid_pos
			if check_etats(["PORTE"]):
				var porteur = null
				for combattant in combat.combattants:
					for effet in combattant.effets:
						if (effet.etat == "PORTE_ALLIE" or effet.etat == "PORTE_ENNEMI") and effet.cible.id == id:
							porteur = combattant
				retire_etats(["PORTE"])
				porteur.retire_etats(["PORTE_ALLIE", "PORTE_ENNEMI"])
				z_index = 0
				combat.tilemap.a_star_grid.set_point_solid(old_grid_pos)
				combat.tilemap.grid[old_grid_pos[0]][old_grid_pos[1]] = -2
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


func place_perso(tile_pos: Vector2i):
	var tile_data = combat.tilemap.get_cell_atlas_coords(2, tile_pos)
	if (tile_data.x == 0 and equipe == 1) or (tile_data.x == 2 and equipe == 0):
		var new_grid_pos = tile_pos + combat.offset
		var place_libre = true
		for combattant in combat.combattants:
			if combattant.grid_pos == new_grid_pos:
				place_libre = false
		if place_libre:
			var old_grid_pos = grid_pos
			var old_map_pos = grid_pos - combat.offset
			combat.tilemap.a_star_grid.set_point_solid(old_grid_pos, false)
			combat.tilemap.grid[old_grid_pos[0]][old_grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, old_map_pos).x
			position = combat.tilemap.map_to_local(tile_pos)
			grid_pos = new_grid_pos
			combat.tilemap.a_star_grid.set_point_solid(grid_pos)
			combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = -2


func bouge_perso(new_pos):
	var old_grid_pos = grid_pos
	var old_map_pos = grid_pos - combat.offset
	combat.tilemap.a_star_grid.set_point_solid(old_grid_pos, false)
	combat.tilemap.grid[old_grid_pos[0]][old_grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, old_map_pos).x
	position = combat.tilemap.map_to_local(new_pos - combat.offset)
	grid_pos = new_pos
	combat.tilemap.a_star_grid.set_point_solid(grid_pos)
	combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = -2
	combat.tilemap.update_glyphes()


func echange_positions(combattant):
	var old_grid_pos = grid_pos
	var old_position = position
	grid_pos = combattant.grid_pos
	position = combattant.position
	combattant.grid_pos = old_grid_pos
	combattant.position = old_position


func oriente_vers(pos: Vector2i):
	var ref_vectors = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	var min_dist = 999999999.0
	var min_vec = 0
	for i in range(len(ref_vectors)):
		var new_dist = Vector2(pos).distance_to(Vector2(grid_pos) + ref_vectors[i])
		if new_dist < min_dist:
			min_dist = new_dist
			min_vec = i
	change_orientation(min_vec)


func meurt():
	if check_etats(["PORTE_ALLIE", "PORTE_ENNEMI"]):
		var effet_lance = Effet.new(self, grid_pos, "LANCE", 1, false, grid_pos, false, null)
		effet_lance.execute()
	
	for combattant in combat.combattants:
		var new_effets = []
		for effet in combattant.effets:
			if effet.lanceur.id != id:
				new_effets.append(effet)
			else:
				if effet.categorie == "CHANGE_STATS" and effet.contenu.has("hp"):
					combattant.stats.hp -= effet.boost_hp
					combattant.max_stats.hp -= effet.boost_hp
		combattant.effets = new_effets
	
	var map_pos = combat.tilemap.local_to_map(position)
	combat.tilemap.a_star_grid.set_point_solid(grid_pos, false)
	combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, map_pos).x
	print(classe, "_", str(id), " est mort.")
	queue_free()


func execute_effets():
	stat_buffs = Stats.new()
	var triggers = ["DOMMAGE_SI_BOUGE", "DOMMAGE_SI_UTILISE_PA"]
	for effet in effets:
		if not effet.etat in triggers:
			effet.execute()


func check_etats(etats: Array) -> bool:
	if "VIE_FAIBLE" in etats and stats.hp < int(max_stats.hp / 4):
		return true
	for effet in effets:
		if effet.etat in etats:
			return true
	return false


func retire_etats(etats: Array):
	var new_effets = []
	for effet in effets:
		if effet.etat not in etats:
			new_effets.append(effet)
	effets = new_effets


func retrait_durees():
	stat_buffs = Stats.new()
	max_stats = init_stats.copy()
	for combattant in combat.combattants:
		var new_effets = []
		for effet in combattant.effets:
			if effet.lanceur.id == id:
				effet.duree -= 1
			if effet.duree > 0:
				new_effets.append(effet)
		combattant.effets = new_effets
	
	var new_map_glyphes = []
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


func retrait_cooldown():
	for sort in sorts:
		if sort.cooldown_actuel > 0:
			sort.cooldown_actuel -= 1
		sort.compte_lancers_tour = 0
		sort.compte_cible = {}


func _input(event):
	if event is InputEventMouseButton:
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
	hp.visible = true
	if combat.action == 7:
		affiche_path(Vector2i(99, 99))


func _on_area_2d_mouse_exited():
	if is_hovered:
		classe_sprite.material.set_shader_parameter("width", 0.0)
		is_hovered = false
		if is_selected:
			classe_sprite.material.set_shader_parameter("width", 2.0)
		combat.stats_hover.visible = false
		hp.visible = false
		if combat.action == 7:
			combat.change_action(7)
