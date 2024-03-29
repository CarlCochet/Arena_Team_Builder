extends Node2D
class_name Sort


var nom: String
var kamas: int = 0
var pa: int
var po: Vector2
var po_modifiable: int
var type_zone: GlobalData.TypeZone
var taille_zone: Vector2
var cible: GlobalData.Cible
var ldv: int
var type_ldv: GlobalData.TypeLDV
var cooldown: int
var cooldown_global: int
var lancer_par_tour: int
var lancer_par_cible: int
var desenvoute_delais: int
var nombre_lancers: int
var cumul_max: int
var etat_requis: String
var etats_cible_interdits: Array
var etats_lanceur_interdits: Array
var particules_cible: String
var particules_retour: String
var particules_cible_scene: PackedScene
var particules_retour_scene: PackedScene
var effets: Dictionary

var compte_lancers: int
var compte_lancers_tour: int
var compte_cible: Dictionary
var cooldown_actuel: int
var retour_lock: bool
var proc: bool


func _init():
	nom = ""
	kamas = 0
	pa = 0
	po = Vector2(0, 0)
	po_modifiable = 1
	type_zone = GlobalData.TypeZone.CERCLE
	taille_zone = Vector2(0, 0)
	cible = GlobalData.Cible.LIBRE
	ldv = 0
	type_ldv = GlobalData.TypeLDV.CERCLE
	cooldown = 0
	cooldown_global = 0
	lancer_par_tour = -1
	lancer_par_cible = -1
	desenvoute_delais = -1
	nombre_lancers = -1
	cumul_max = -1
	etat_requis = ""
	etats_cible_interdits = []
	etats_lanceur_interdits = []
	particules_cible = ""
	particules_retour = ""
	effets = {}
	
	cooldown_actuel = 0
	compte_lancers_tour = 0
	compte_lancers = 0
	compte_cible = {}
	proc = false
	retour_lock = false


func execute_effets(lanceur: Combattant, cases_cibles: Array, centre: Vector2i) -> bool:
	var sort_valide: bool = false
	var aoe: bool = false
	if len(cases_cibles) == 0:
		return false
	if len(cases_cibles) > 1 or taille_zone.y > 0:
		aoe = true
	lanceur.combat.chat_log.sort(lanceur, nom)
	var combattants: Array = lanceur.combat.combattants
	var trouve: bool = false
	var critique: bool = GlobalData.rng.randi_range(1, 100) <= lanceur.stats.cc
	if critique:
		lanceur.combat.chat_log.critique()
	var targets: Array = []
	if effets.has("GLYPHE"):
		lance_particules(lanceur, cases_cibles)
		var new_glyphe = Glyphe.new(
			lanceur.combat.tilemap.glyphes_indexeur, 
			lanceur, 
			cases_cibles, 
			effets, 
			effets.has("DOMMAGE_FIXE"), 
			critique, 
			centre, 
			false,
			self)
		lanceur.combat.tilemap.glyphes_indexeur += 1
		lanceur.combat.tilemap.glyphes.append(new_glyphe)
		lanceur.combat.tilemap.update_glyphes()
		update_limite_lancers(lanceur)
		return true
	
	if not effets.has("cible"):
		if len(effets.keys()) > 0 and effets.keys()[0] in ["LANCE", "TELEPORTE"]:
			if not lanceur.combat.tilemap.check_glyphe_effet(centre, "DEVIENT_INVISIBLE"):
				lance_particules(lanceur, cases_cibles)
		else:
			lance_particules(lanceur, cases_cibles)
		for combattant in combattants:
			if combattant.grid_pos in cases_cibles:
				trouve = true
				if aoe or not combattant.check_etats(["PORTE"]):
					targets.append(combattant)
	elif effets["cible"] as GlobalData.Cible == GlobalData.Cible.ALLIES:
		for effet in effets.keys():
			if effet != "cible":
				var cases_particules: Array[Vector2i] = []
				var affiche_log: bool = true
				for combattant in combattants:
					if combattant.equipe == lanceur.equipe:
						cases_particules.append(combattant.grid_pos)
						var tag_cible: String = "Toute l'equipe " + ("bleu " if lanceur.equipe == 0 else "rouge ")
						parse_effet(lanceur, combattant, effet, effets[effet], critique, centre, aoe, tag_cible, affiche_log)
						affiche_log = false
				lance_particules(lanceur, cases_particules)
		update_limite_lancers(lanceur)
		return true
	elif effets["cible"] as GlobalData.Cible == GlobalData.Cible.ENNEMIS:
		for effet in effets.keys():
			if effet != "cible":
				var cases_particules: Array[Vector2i] = []
				var affiche_log: bool = true
				for combattant in combattants:
					if combattant.equipe != lanceur.equipe:
						cases_particules.append(combattant.grid_pos)
						var tag_cible: String = "Toute l'equipe " + ("bleu " if lanceur.equipe == 1 else "rouge ")
						parse_effet(lanceur, combattant, effet, effets[effet], critique, centre, aoe, tag_cible, affiche_log)
						affiche_log = false
				lance_particules(lanceur, cases_particules)
		update_limite_lancers(lanceur)
		return true
	elif effets["cible"] as GlobalData.Cible == GlobalData.Cible.TOUT:
		for effet in effets.keys():
			if effet != "cible":
				var cases_particules: Array[Vector2i] = []
				var affiche_log: bool = true
				for combattant in combattants:
					cases_particules.append(combattant.grid_pos)
					var tag_cible: String = "Tout le monde "
					parse_effet(lanceur, combattant, effet, effets[effet], critique, centre, aoe, tag_cible, affiche_log)
					affiche_log = false
				lance_particules(lanceur, cases_particules)
		update_limite_lancers(lanceur)
		return true
	elif effets["cible"] as GlobalData.Cible == GlobalData.Cible.CLASSE:
		var cases_particules: Array[Vector2i] = []
		for combattant in combattants:
			if combattant.grid_pos in cases_cibles:
				trouve = true
				if aoe or not combattant.check_etats(["PORTE"]):
					cases_particules.append(combattant.grid_pos)
					targets.append(combattant)
					for combattant_bis in combattants:
						if combattant_bis.classe == combattant.classe and combattant_bis.id != combattant.id and combattant.equipe == combattant_bis.equipe:
							cases_particules.append(combattant_bis.grid_pos)
							targets.append(combattant_bis)
		lance_particules(lanceur, cases_particules)
	elif effets["cible"] as GlobalData.Cible == GlobalData.Cible.PERSONNAGES:
		for effet in effets.keys():
			if effet != "cible":
				var cases_particules: Array[Vector2i] = []
				var affiche_log: bool = true
				for combattant in combattants:
					if not combattant.is_invocation:
						cases_particules.append(combattant.grid_pos)
						var tag_cible: String = "Tous les personnages "
						parse_effet(lanceur, combattant, effet, effets[effet], critique, centre, aoe, tag_cible, affiche_log)
						affiche_log = false
				lance_particules(lanceur, cases_particules)
		update_limite_lancers(lanceur)
		return true
	elif effets["cible"] as GlobalData.Cible == GlobalData.Cible.PERSONNAGES_ALLIES:
		for effet in effets.keys():
			if effet != "cible":
				var cases_particules: Array[Vector2i] = []
				var affiche_log: bool = true
				for combattant in combattants:
					if combattant.equipe == lanceur.equipe and not combattant.is_invocation:
						cases_particules.append(combattant.grid_pos)
						var tag_cible: String = "Tous les personnages de l'equipe " + ("bleu " if lanceur.equipe == 0 else "rouge ")
						parse_effet(lanceur, combattant, effet, effets[effet], critique, centre, aoe, tag_cible, affiche_log)
						affiche_log = false
				lance_particules(lanceur, cases_particules)
		update_limite_lancers(lanceur)
		return true
	
	if trouve:
		for combattant in targets:
			sort_valide = parse_effets(lanceur, combattant, effets, critique, centre, aoe) or sort_valide
	if not trouve and cible == GlobalData.Cible.VIDE:
		sort_valide = parse_effets(lanceur, cases_cibles, effets, critique, centre, true) or sort_valide
	if effets.has("MAUDIT_CASE"):
		sort_valide = parse_effets(lanceur, cases_cibles, effets, critique, centre, true) or sort_valide
	update_limite_lancers(lanceur)
	proc = false
	return sort_valide


func update_limite_lancers(lanceur: Combattant):
	compte_lancers += 1
	compte_lancers_tour += 1
	retour_lock = false
	
	if cooldown_global > 0:
		for combattant in lanceur.combat.combattants:
			for sort in combattant.sorts:
				if sort.nom == nom and sort.cooldown_actuel < cooldown_global and combattant.equipe == lanceur.equipe:
					sort.cooldown_actuel = cooldown_global
	cooldown_actuel = cooldown


func retrait_cumul_max(p_cible: Combattant):
	if cumul_max > 0:
		var new_effets: Array[Effet] = []
		var compte_sort: int = 0
		var delta_pa: int = p_cible.init_stats.pa + p_cible.stat_ret.pa + p_cible.stat_buffs.pa + p_cible.stat_cartes_combat.pa - p_cible.stats.pa
		var delta_pm: int = p_cible.init_stats.pm + p_cible.stat_ret.pm + p_cible.stat_buffs.pm + p_cible.stat_cartes_combat.pm - p_cible.stats.pm
		for i in range(len(p_cible.effets)-1, -1, -1):
			var effet: Effet = p_cible.effets[i]
			if effet.sort.nom == nom:
				compte_sort += 1
				if compte_sort <= cumul_max:
					new_effets.append(effet)
			else:
				new_effets.append(effet)
		p_cible.effets = new_effets
		p_cible.stat_buffs = Stats.new()
		var delta_hp: int = p_cible.max_stats.hp - p_cible.stats.hp
		p_cible.max_stats = p_cible.init_stats.copy()
		p_cible.execute_effets()
		p_cible.stats = p_cible.init_stats.copy().add(p_cible.stat_ret).add(p_cible.stat_buffs).add(p_cible.stat_cartes_combat)
		p_cible.stats.hp -= delta_hp
		p_cible.stats.pa -= delta_pa
		p_cible.stats.pm -= delta_pm
		p_cible.execute_buffs_hp()


func parse_effets(lanceur: Combattant, p_cible, p_effets: Dictionary, critique: bool, centre: Vector2i, aoe: bool) -> bool:
	if p_cible is Array:
		for case in p_cible:
			for effet in p_effets:
				var new_effet: Effet = Effet.new(lanceur, p_cible, effet, p_effets[effet], critique, centre, aoe, self)
				new_effet.execute()
		return true
	
	if p_cible.check_etats(etats_cible_interdits):
		return false
	if lancer_par_cible > 0 and (not p_cible is Vector2i) and (not p_cible is Array):
		if compte_cible.has(p_cible.id):
			if compte_cible[p_cible.id] >= lancer_par_cible:
				return false
			else:
				compte_cible[p_cible.id] += 1
		else:
			compte_cible[p_cible.id] = 1
	
	var effet_grid_pos: Vector2i = p_cible.grid_pos
	for effet in p_effets.keys():
		if p_cible.grid_pos != effet_grid_pos:
			for combattant in p_cible.combat.combattants:
				if combattant.grid_pos == effet_grid_pos:
					p_cible = combattant
		var combattant_effet: Dictionary = p_effets.duplicate(true)
		var new_effet: Effet = Effet.new(lanceur, p_cible, effet, combattant_effet[effet], critique, centre, aoe, self)
		if new_effet.instant:
			new_effet.execute()
		if new_effet.duree > 0:
			p_cible.effets.append(new_effet)
	
	retrait_cumul_max(p_cible)
	return true


func parse_effet(lanceur: Combattant, p_cible, p_categorie: String, p_effet: Dictionary, critique: bool, centre: Vector2i, aoe: bool, tag_cible: String, affiche_log: bool) -> bool:
	if p_cible is Array:
		for case in p_cible:
			var new_effet: Effet = Effet.new(lanceur, p_cible, p_categorie, p_effet, critique, centre, aoe, self)
			new_effet.execute()
		return true
	
	if p_cible.check_etats(etats_cible_interdits):
		return false
	if lancer_par_cible > 0 and (not p_cible is Vector2i) and (not p_cible is Array):
		if compte_cible.has(p_cible.id):
			if compte_cible[p_cible.id] >= lancer_par_cible:
				return false
			else:
				compte_cible[p_cible.id] += 1
		else:
			compte_cible[p_cible.id] = 1
	
	var effet_grid_pos: Vector2i = p_cible.grid_pos
	if p_cible.grid_pos != effet_grid_pos:
		for combattant in p_cible.combat.combattants:
			if combattant.grid_pos == effet_grid_pos:
				p_cible = combattant
	var combattant_effet: Dictionary = p_effet
	if p_effet is Dictionary:
		combattant_effet = p_effet.duplicate(true)
	var new_effet: Effet = Effet.new(lanceur, p_cible, p_categorie, combattant_effet, critique, centre, aoe, self)
	new_effet.tag_cible = tag_cible
	new_effet.affiche_log = affiche_log
	if new_effet.instant and p_cible.stats.hp > 0:
		new_effet.execute()
	if new_effet.duree > 0:
		p_cible.effets.append(new_effet)
	return true


func precheck_cast(lanceur: Combattant) -> bool:
	if pa > lanceur.stats.pa:
		return false
	if cooldown_actuel > 0:
		return false
	if compte_lancers >= nombre_lancers and nombre_lancers > 0:
		return false
	if compte_lancers_tour >= lancer_par_tour and lancer_par_tour > 0:
		return false
	if lanceur.check_etats(["PORTE"]):
		return false
	if lanceur.check_etats(etats_lanceur_interdits):
		return false
	if not etat_requis.is_empty() and not lanceur.check_etats([etat_requis]):
		return false
	if effets.has("INVOCATION"):
		var invoc_count: int = 0
		for combattant in lanceur.combat.combattants:
			if combattant.is_invocation and combattant.invocateur.id == lanceur.id:
				invoc_count += 1
		if invoc_count >= lanceur.stats.invocations:
			return false
	return true


func check_cible(lanceur: Combattant, case_cible: Vector2i) -> bool:
	var target
	for combattant in lanceur.get_parent().combattants:
		if combattant.grid_pos == case_cible:
			target = combattant
	if effets.has("LANCE") and lanceur.combat.check_perso(case_cible):
		return false
	if cible == GlobalData.Cible.VIDE and target != null:
		return false
	
	if target != null:
		if cible == GlobalData.Cible.MOI and target.id != lanceur.id:
			return false
		if cible == GlobalData.Cible.ALLIES and lanceur.equipe != target.equipe:
			return false
		if cible == GlobalData.Cible.ENNEMIS and lanceur.equipe == target.equipe:
			return false
		if cible == GlobalData.Cible.INVOCATIONS and not target.is_invocation: 
			return false
		if cible == GlobalData.Cible.INVOCATIONS_ALLIEES and (lanceur.equipe != target.equipe or not target.is_invocation): 
			return false
		if cible == GlobalData.Cible.INVOCATIONS_ENNEMIES and (lanceur.equipe == target.equipe or not target.is_invocation): 
			return false
		if cible == GlobalData.Cible.PERSONNAGES and target.is_invocation: 
			return false
		if cible == GlobalData.Cible.PERSONNAGES_ALLIES and (target.is_invocation or lanceur.equipe != target.equipe): 
			return false
		if cible == GlobalData.Cible.PERSONNAGES_ENNEMIS and (target.is_invocation or lanceur.equipe == target.equipe): 
			return false
	else:
		if cible != GlobalData.Cible.LIBRE and cible != GlobalData.Cible.TOUT and cible != GlobalData.Cible.VIDE and cible != GlobalData.Cible.ENNEMIS:
			return false
	return true


func lance_particules(lanceur: Combattant, cases: Array):
	if not particules_retour.is_empty():
		var particule = particules_retour_scene.instantiate()
		particule.position = lanceur.combat.tilemap.map_to_local(lanceur.grid_pos - lanceur.combat.offset)
		particule.z_index = 3
		lanceur.combat.add_child(particule)
		for child in particule.get_children():
			child.emitting = true
	for case in cases:
		var particule = particules_cible_scene.instantiate()
		particule.position = lanceur.combat.tilemap.map_to_local(case - lanceur.combat.offset) + particule.position
		particule.z_index = 3
		lanceur.combat.add_child(particule)
		for child in particule.get_children():
			child.emitting = true


func from_arme(combattant: Combattant, arme: String):
	var element_principal: String = "DOMMAGE_FIXE"
	match combattant.classe:
		"Cra":
			element_principal = "DOMMAGE_AIR"
		"Eca":
			element_principal = "DOMMAGE_AIR"
		"Eni":
			element_principal = "DOMMAGE_FEU"
		"Enu":
			element_principal = "DOMMAGE_EAU"
		"Feca":
			element_principal = "DOMMAGE_EAU"
		"Iop":
			element_principal = "DOMMAGE_TERRE"
		"Osa":
			element_principal = "DOMMAGE_FEU"
		"Panda":
			element_principal = "DOMMAGE_FEU"
		"Roublard":
			element_principal = "DOMMAGE_EAU"
		"Sacrieur":
			element_principal = "DOMMAGE_TERRE"
		"Sadida":
			element_principal = "DOMMAGE_TERRE"
		"Sram":
			element_principal = "DOMMAGE_AIR"
		"Xelor":
			element_principal = "DOMMAGE_FEU"
		"Zobal":
			element_principal = "DOMMAGE_EAU"
	if not arme.is_empty():
		var data: Dictionary = GlobalData.equipements[arme].to_json()
		pa = data["pa"]
		po = data["po"]
		type_zone = data["type_zone"] as GlobalData.TypeZone
		taille_zone = data["taille_zone"]
		po_modifiable = data["po_modifiable"]
		particules_cible = data["particules_cible"]
		particules_retour = data["particules_retour"]
		particules_cible_scene = load("res://Fight/Particules/" + particules_cible + ".tscn")
		if not particules_retour.is_empty():
			particules_retour_scene = load("res://Fight/Particules/" + particules_retour + ".tscn")
		effets = data["effets"]
	else:
		pa = 5
		po = Vector2(1, 1)
		type_zone = GlobalData.TypeZone.CERCLE
		taille_zone = Vector2(0, 0)
		po_modifiable = 0
		particules_cible = "generic_" + element_principal.split("_")[1].to_lower()
		particules_cible_scene = load("res://Fight/Particules/" + particules_cible + ".tscn")
		effets = {element_principal:{"base":{"valeur":5},"critique":{"valeur":7}}}
	nom = "arme"
	ldv = 1
	return self


func copy():
	var new_sort: Sort = Sort.new()
	new_sort.nom = nom
	new_sort.kamas = kamas
	new_sort.pa = pa
	new_sort.po = po
	new_sort.po_modifiable = po_modifiable
	new_sort.type_zone = type_zone
	new_sort.taille_zone = taille_zone
	new_sort.cible = cible
	new_sort.ldv = ldv
	new_sort.type_ldv = type_ldv
	new_sort.cooldown = cooldown
	new_sort.cooldown_global = cooldown_global
	new_sort.lancer_par_tour = lancer_par_tour
	new_sort.lancer_par_cible = lancer_par_cible
	new_sort.desenvoute_delais = desenvoute_delais
	new_sort.nombre_lancers = nombre_lancers
	new_sort.cumul_max = cumul_max
	new_sort.etat_requis = etat_requis
	new_sort.etats_cible_interdits = etats_cible_interdits
	new_sort.etats_lanceur_interdits = etats_lanceur_interdits
	new_sort.particules_cible = particules_cible
	new_sort.particules_retour = particules_retour
	new_sort.particules_cible_scene = load("res://Fight/Particules/" + new_sort.particules_cible + ".tscn")
	if not new_sort.particules_retour.is_empty():
		new_sort.particules_retour_scene = load("res://Fight/Particules/" + new_sort.particules_retour + ".tscn")
	new_sort.effets = effets.duplicate(true)
	return new_sort


func from_json(data: Dictionary):
	kamas = data["kamas"]
	pa = data["pa"]
	po = Vector2(data["po"][0], data["po"][1])
	po_modifiable = data["po_modifiable"]
	type_zone = data["type_zone"] as GlobalData.TypeZone
	taille_zone = Vector2(data["taille_zone"][0], data["taille_zone"][1])
	cible = data["cible"] as GlobalData.Cible
	ldv = data["ldv"]
	type_ldv = data["type_ldv"] as GlobalData.TypeLDV
	cooldown = data["cooldown"]
	cooldown_global = data["cooldown_global"]
	lancer_par_tour = data["lancer_par_tour"]
	lancer_par_cible = data["lancer_par_cible"]
	desenvoute_delais = data["desenvoute_delais"]
	nombre_lancers = data["nombre_lancers"]
	cumul_max = data["cumul_max"]
	etat_requis = data["etat_requis"]
	etats_cible_interdits = data["etats_cible_interdits"]
	etats_lanceur_interdits = data["etats_lanceur_interdits"]
	particules_cible = data["particules_cible"]
	particules_retour = data["particules_retour"]
	particules_cible_scene = load("res://Fight/Particules/" + particules_cible + ".tscn")
	if not particules_retour.is_empty():
		particules_retour_scene = load("res://Fight/Particules/" + particules_retour + ".tscn")
	effets = data["effets"]
	return self


func to_json():
	return {
		"kamas": kamas,
		"pa": pa,
		"po": [po[0], po[1]],
		"po_modifiable": po_modifiable,
		"type_zone": type_zone,
		"taille_zone": taille_zone,
		"cible": cible,
		"ldv": ldv,
		"type_ldv": type_ldv,
		"cooldown": cooldown,
		"cooldown_global": cooldown_global,
		"lancer_par_tour": lancer_par_tour,
		"lancer_par_cible": lancer_par_cible,
		"desenvoute_delais": desenvoute_delais,
		"nombre_lancers": nombre_lancers,
		"cumul_max": cumul_max,
		"etat_requis": etat_requis,
		"etats_cible_interdits": etats_cible_interdits,
		"etats_lanceur_interdits": etats_lanceur_interdits,
		"particules_cible": particules_cible,
		"particules_retour": particules_retour,
		"effets": effets
	}


class Glyphe:
	var id: int
	var lanceur: Combattant
	var tiles: Array[Vector2i]
	var effets: Dictionary
	var critique: bool
	var bloqueur: bool
	var duree: int
	var centre: Vector2i
	var aoe: bool
	var sort: Sort
	var deleted: bool
	var combattants_id: Array[int]
	
	func _init(p_id: int, p_lanceur: Combattant, p_tiles: Array[Vector2i], p_effets: Dictionary, p_bloqueur: bool, p_critique: bool, p_centre: Vector2i, p_aoe: bool, p_sort: Sort):
		id = p_id
		lanceur = p_lanceur
		tiles = p_tiles
		effets = p_effets
		bloqueur = p_bloqueur
		critique = p_critique
		if critique and effets["GLYPHE"].has("critique"):
			duree = effets["GLYPHE"]["critique"]["duree"]
		else:
			duree = effets["GLYPHE"]["base"]["duree"]
		centre = p_centre
		aoe = p_aoe
		sort = p_sort
		deleted = false
		combattants_id = []
	
	func active_full():
		var triggered: bool = false
		for combattant in lanceur.combat.combattants:
			var affiche_log: bool = true
			if combattant.grid_pos in tiles:
				if combattant.id in combattants_id:
					affiche_log = false
				combattants_id.append(combattant.id)
				var temp_hp: int = combattant.stats.hp
				var temp_pa: int = combattant.stats.pa
				var temp_pm: int = combattant.stats.pm
				combattant.stats = combattant.init_stats.copy().add(combattant.stat_ret).add(combattant.stat_buffs).add(combattant.stat_cartes_combat)
				combattant.stats.hp = temp_hp
				combattant.stats.pa = temp_pa
				combattant.stats.pm = temp_pm
				for effet in effets:
					if effet == "DEVIENT_INVISIBLE" or not combattant.check_etats(["PORTE"]):
						var new_effet: Effet = Effet.new(lanceur, combattant, effet, effets[effet], critique, centre, aoe, sort)
						new_effet.instant = true
						new_effet.affiche_log = affiche_log
						new_effet.execute()
				triggered = true
			else:
				combattants_id.erase(combattant.id)
		if triggered and effets.has("DOMMAGE_FIXE"):
			lanceur.combat.tilemap.delete_glyphes([id])
			deleted = true
	
	func active_mono(combattant: Combattant):
		for tile in tiles:
			if combattant.grid_pos == tile:
				for effet in effets:
					var new_effet = Effet.new(lanceur, combattant, effet, effets[effet], critique, centre, true, sort)
					new_effet.execute()
	
	func affiche():
		for tile in tiles:
			if effets.has("DOMMAGE_FIXE"):
				lanceur.combat.tilemap.set_cell(3, tile - lanceur.combat.offset, 1, Vector2i(0, 0))
			if effets.has("DEVIENT_INVISIBLE"):
				lanceur.combat.tilemap.set_cell(4, tile - lanceur.combat.offset, 1, Vector2i(1, 0))
