extends Combattant
class_name Invocation


var invocateur

@onready var hitbox: Area2D = $Area2D


func _ready():
	effets = []
	classe_sprite.material = ShaderMaterial.new()
	classe_sprite.material.shader = outline_shader
	classe_sprite.material.set_shader_parameter("width", 0.0)
	orientation = 1
	stat_buffs = Stats.new()
	stat_ret = Stats.new()
	stat_cartes_combat = Stats.new()
	is_selected = false
	is_hovered = false
	is_invocation = true
	is_mort = false
	hp_label.text = str(stats.hp) + "/" + str(max_stats.hp)
	combat = get_parent()
	update_hitbox()


func init(classe_int: int):
	match classe_int as GlobalData.Invocations:
		GlobalData.Invocations.BOUFTOU:
			classe = "Bouftou"
		GlobalData.Invocations.CRAQUELEUR:
			classe = "Craqueleur"
		GlobalData.Invocations.PRESPIC:
			classe = "Prespic"
		GlobalData.Invocations.TOFU:
			classe = "Tofu"
		GlobalData.Invocations.ARBRE:
			classe = "Arbre"
		GlobalData.Invocations.BLOQUEUSE:
			classe = "La_Bloqueuse"
		GlobalData.Invocations.FOLLE:
			classe = "La_Folle"
		GlobalData.Invocations.SACRIFIEE:
			classe = "La_Sacrifiee"
		GlobalData.Invocations.DOUBLE:
			classe = "Double"
		GlobalData.Invocations.CADRAN_DE_XELOR:
			classe = "Cadran_De_Xelor"
		GlobalData.Invocations.BOMBE_A_EAU:
			classe = "Bombe_A_Eau"
		GlobalData.Invocations.BOMBE_INCENDIAIRE:
			classe = "Bombe_Incendiaire"
		_:
			print("Incorrect summon.")
	stats = GlobalData.stats_classes[classe].copy()
	max_stats = GlobalData.stats_classes[classe].copy()
	init_stats = GlobalData.stats_classes[classe].copy()
	sorts = []
	if GlobalData.sorts_lookup.has(classe):
		var nom_sorts = GlobalData.sorts_lookup[classe]
		for sort in nom_sorts:
			sorts.append(GlobalData.sorts[sort])


func update_hitbox():
	if equipe == 0:
		cercle.texture = cercle_bleu
	else:
		cercle.texture = cercle_rouge
	match classe:
		"Tofu":
			classe_sprite.position = Vector2(0, -10)
			hitbox.position = Vector2(0, -10)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -60)
		"Bouftou":
			classe_sprite.position = Vector2(0, -13)
			hitbox.position = Vector2(0, -13)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"Craqueleur":
			classe_sprite.position = Vector2(0, -40)
			hitbox.position = Vector2(0, -40)
			hitbox.scale = Vector2(3, 5)
			hp.position = Vector2(0, -120)
		"Prespic":
			classe_sprite.position = Vector2(0, -17)
			hitbox.position = Vector2(0, -15)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"La_Bloqueuse":
			classe_sprite.position = Vector2(0, -25)
			hitbox.position = Vector2(0, -20)
			hitbox.scale = Vector2(2, 2.5)
			hp.position = Vector2(0, -80)
		"La_Folle":
			classe_sprite.position = Vector2(0, -17)
			hitbox.position = Vector2(0, -20)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"La_Sacrifiee":
			classe_sprite.position = Vector2(0, -20)
			hitbox.position = Vector2(0, -12)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"Arbre":
			classe_sprite.position = Vector2(0, -60)
			classe_sprite.scale = Vector2(1, 1)
			hitbox.position = Vector2(0, -50)
			hitbox.scale = Vector2(2, 5)
			hp.position = Vector2(0, -120)
			fleche.visible = false
		"Double":
			classe_sprite.position = Vector2(0, -48)
			hitbox.position = Vector2(0, -38)
			hitbox.scale = Vector2(2, 4)
			hp.position = Vector2(0, -110)
		"Cadran_De_Xelor":
			classe_sprite.position = Vector2(0, -35)
			hitbox.position = Vector2(0, -30)
			hitbox.scale = Vector2(2, 3)
			hp.position = Vector2(0, -80)
			fleche.visible = false
		"Bombe_A_Eau":
			classe_sprite.position = Vector2(0, -20)
			hitbox.position = Vector2(0, -12)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -80)
			fleche.visible = false
		"Bombe_Incendiaire":
			classe_sprite.position = Vector2(0, -20)
			hitbox.position = Vector2(0, -12)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -80)
			fleche.visible = false
	classe_sprite.texture = load(
		"res://Classes/Invocations/" + classe.to_lower() + ".png"
	)


func debut_tour():
	visible = true
	var delta_hp = max_stats.hp - stats.hp
	var start_hp = stats.hp
	retrait_durees()
	execute_effets(false)
	check_case_bonus()
	var effets_hp = start_hp - stats.hp
	stats = init_stats.copy().add(stat_ret).add(stat_buffs)
	stats.hp -= delta_hp + effets_hp
	execute_buffs_hp(false)
	
	if classe in ["Bombe_Incendiaire", "Bombe_A_Eau"]:
		stats.hp -= 2
		stats_perdu.ajoute(-2, "hp")

	all_path = combat.tilemap.get_atteignables(grid_pos, stats.pm)
	if check_etats(["PETRIFIE"]):
		combat.passe_tour()
	if not check_etats(["INVISIBLE"]):
		combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = -2
	if check_etats(["IMMOBILISE"]):
		stats.pm = 0
	joue_ia()
	if not is_mort:
		combat.passe_tour()


func chemin_vers_proche() -> Array:
	var voisins = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0)]
	var min_dist = 99999999
	var min_hp = 9999999
	var min_chemin = []
	for combattant in combat.combattants:
		if combattant.equipe != equipe and not combattant.check_etats(["PORTE"]):
			if not combattant.is_visible:
				continue
			for voisin in voisins:
				if check_etats(["PORTE"]) and combattant.grid_pos + voisin == grid_pos:
					continue
				if combattant.grid_pos + voisin == grid_pos:
					return []
				var chemin = combat.tilemap.get_chemin(grid_pos, combattant.grid_pos + voisin)
				if len(chemin) < min_dist and len(chemin) > 0:
					min_dist = len(chemin)
					min_chemin = chemin
					min_hp = combattant.stats.hp
				elif len(chemin) == min_dist and len(chemin) > 0 and combattant.stats.hp < min_hp:
					min_dist = len(chemin)
					min_chemin = chemin
					min_hp = combattant.stats.hp
	return min_chemin


func choix_cible(p_all_ldv: Array):
	var min_dist = 9999999
	var min_hp = 9999999
	var cible = null
	if len(p_all_ldv) == 1 and p_all_ldv[0] == grid_pos:
		return grid_pos
	for combattant in combat.combattants:
		if not combattant.is_visible:
			continue
		if combattant.grid_pos in p_all_ldv and combattant.equipe != equipe and not combattant.check_etats(["PORTE"]):
			var delta = combattant.grid_pos - grid_pos
			var dist = abs(delta.x) + abs(delta.y)
			if dist < min_dist:
				min_dist = dist
				cible = combattant.grid_pos
				min_hp = combattant.stats.hp
			elif dist == min_dist and combattant.stats.hp < min_hp:
				min_dist = dist
				cible = combattant.grid_pos
				min_hp = combattant.stats.hp
	return cible


func joue_ia():
	combat.check_morts()
	var grid_pos_start = grid_pos
	var grid_state = combat.tilemap.a_star_grid.is_point_solid(grid_pos_start)
	if is_mort:
		return
	if stats.pm > 0 and init_stats.pm > 0:
		var chemin = chemin_vers_proche()
		if len(chemin) > stats.pm + 1:
			chemin = chemin.slice(0, stats.pm + 1)
		grid_state = combat.tilemap.a_star_grid.is_point_solid(grid_pos_start)
		if len(chemin) > 0:
			chemin.pop_front()
			deplace_perso(chemin)
	grid_state = combat.tilemap.a_star_grid.is_point_solid(grid_pos_start)
	for sort in sorts:
		if not sort.precheck_cast(self):
			continue
		all_ldv = combat.tilemap.get_ldv(
			grid_pos, 
			sort.po[0],
			sort.po[1] + (stats.po if sort.po_modifiable else 0),
			sort.type_ldv,
			sort.ldv
		)
		var cible = choix_cible(all_ldv)
		if cible == null:
			continue
		if sort.pa <= stats.pa:
			var valide = false
			if check_etats(["RATE_SORT"]):
				valide = true
				retire_etats(["RATE_SORT"])
			else:
				valide = sort.execute_effets(self, [cible], cible)
			if valide:
				stats.pa -= sort.pa
				stats_perdu.ajoute(-sort.pa, "pa")
				combat.stats_select.update(stats)
			joue_ia()


func meurt():
	if check_etats(["PORTE_ALLIE", "PORTE_ENNEMI"]):
		var effet_lance = Effet.new(self, grid_pos, "LANCE", 1, false, grid_pos, false, null)
		effet_lance.execute()
	
	for combattant in combat.combattants:
		var new_effets = []
		for effet in combattant.effets:
			if effet.lanceur.id != id:
				new_effets.append(effet)
		var new_buffs_hp = []
		for buff_hp in combattant.buffs_hp:
			if buff_hp["lanceur"] == id:
				combattant.stats.hp -= buff_hp["valeur"]
				combattant.max_stats.hp -= buff_hp["valeur"]
			else:
				new_buffs_hp.append(buff_hp)
		combattant.effets = new_effets
		combattant.buffs_hp = new_buffs_hp
	
	if classe in ["Bombe_Incendiaire", "Bombe_A_Eau"] and stats.hp <= 0:
		var sort = sorts[0]
		zone = combat.tilemap.get_zone(
			grid_pos,
			grid_pos,
			sort.type_zone,
			sort.taille_zone[0],
			sort.taille_zone[1]
		)
		sort.execute_effets(self, zone, grid_pos)
	
	var map_pos = combat.tilemap.local_to_map(position)
	combat.tilemap.a_star_grid.set_point_solid(grid_pos, false)
	combat.tilemap.grid[grid_pos[0]][grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, map_pos).x
	is_mort = true
	print(classe, "_", str(id), " est mort.")
	queue_free()


func fin_tour():
	combat.check_morts()
	retrait_cooldown()
	stat_ret = Stats.new()
	var delta_hp = max_stats.hp - stats.hp
	stats = init_stats.copy().add(stat_buffs)
	stats.hp -= delta_hp
	execute_buffs_hp(false)
