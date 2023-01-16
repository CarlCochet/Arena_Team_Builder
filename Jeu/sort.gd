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
var effets: Dictionary

var compte_lancers: int
var compte_lancers_tour: int
var compte_cible: Dictionary
var cooldown_actuel: int
var retour_lock: bool


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
	effets = {}
	
	cooldown_actuel = 0
	compte_lancers_tour = 0
	compte_lancers = 0
	compte_cible = {}
	retour_lock = false


func execute_effets(lanceur, cases_cibles, centre) -> bool:
	var sort_valide = false
	var aoe = false
	if len(cases_cibles) == 0:
		return false
	if len(cases_cibles) > 1:
		aoe = true
	print(lanceur.classe, "_", str(lanceur.id), " lance ", nom, ".")
	var combattants = lanceur.combat.combattants
	var trouve = false
	var critique = randi_range(1, 100) <= lanceur.stats.cc
	if critique:
		print("Coup critique!")
	var targets = []
	if effets.has("GLYPHE"):
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
		for combattant in combattants:
			if combattant.grid_pos in cases_cibles:
				trouve = true
				if aoe or not combattant.check_etats(["PORTE"]):
					targets.append(combattant)
	elif effets["cible"] == 4:
		for combattant in combattants:
			if combattant.equipe != lanceur.equipe:
				trouve = true
				if aoe or not combattant.check_etats(["PORTE"]):
					targets.append(combattant)
	elif effets["cible"] == 8:
		for combattant in combattants:
			trouve = true
			if aoe or not combattant.check_etats(["PORTE"]):
				targets.append(combattant)
	elif effets["cible"] == 9:
		for combattant in combattants:
			if combattant.grid_pos in cases_cibles:
				trouve = true
				if aoe or not combattant.check_etats(["PORTE"]):
					targets.append(combattant)
				for combattant_bis in combattants:
					if combattant_bis.classe == combattant.classe and combattant_bis.id != combattant.id:
						targets.append(combattant_bis)
	elif effets["cible"] == 10:
		for combattant in combattants:
			if not combattant.is_invocation: 
				trouve = true
				if aoe or not combattant.check_etats(["PORTE"]):
					targets.append(combattant)
	elif effets["cible"] == 11:
		for combattant in combattants:
			if combattant.equipe == lanceur.equipe and not combattant.is_invocation:
				trouve = true
				if aoe or not combattant.check_etats(["PORTE"]):
					targets.append(combattant)
	
	if trouve:
		for combattant in targets:
			sort_valide = parse_effets(lanceur, combattant, effets, critique, centre, aoe) or sort_valide
	if not trouve and cible == 2:
		sort_valide = parse_effets(lanceur, cases_cibles, effets, critique, centre, true) or sort_valide
	if effets.has("MAUDIT_CASE"):
		sort_valide = parse_effets(lanceur, cases_cibles, effets, critique, centre, true) or sort_valide
	if sort_valide:
		update_limite_lancers(lanceur)
	
	if not sort_valide:
		print("Sort invalide, annulation de l'action !")
	return sort_valide


func update_limite_lancers(lanceur):
	compte_lancers += 1
	compte_lancers_tour += 1
	cooldown_actuel = cooldown
	retour_lock = false
	
	if cooldown_global > 0:
		for combattant in lanceur.combat.combattants:
			for sort in combattant.sorts:
				if sort.nom == nom and sort.cooldown_actuel < cooldown_global and combattant.equipe == lanceur.equipe:
					sort.cooldown_actuel = cooldown_global


func parse_effets(lanceur, p_cible, p_effets, critique, centre, aoe):
	if p_cible is Array:
		for case in p_cible:
			for effet in p_effets:
				var new_effet = Effet.new(lanceur, p_cible, effet, p_effets[effet], critique, centre, aoe, self)
				new_effet.execute()
		return true
	
	if p_cible.check_etats(["PORTE"]) and not aoe:
		return false
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
	
	var effet_grid_pos = p_cible.grid_pos
	for effet in p_effets.keys():
		if p_cible.grid_pos != effet_grid_pos:
			for combattant in p_cible.combat.combattants:
				if combattant.grid_pos == effet_grid_pos:
					p_cible = combattant
		var combattant_effet = p_effets.duplicate(true)
		var new_effet = Effet.new(lanceur, p_cible, effet, combattant_effet[effet], critique, centre, aoe, self)
		if new_effet.instant and p_cible.stats.hp > 0:
			new_effet.execute()
		if new_effet.duree > 0:
			p_cible.effets.append(new_effet)
	return true


func precheck_cast(lanceur) -> bool:
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
		var invoc_count = 0
		for combattant in lanceur.combat.combattants:
			if combattant.is_invocation and combattant.invocateur.id == lanceur.id:
				invoc_count += 1
		if invoc_count >= lanceur.stats.invocations:
			return false
	return true


func check_cible(lanceur, case_cible) -> bool:
	var target
	for combattant in lanceur.get_parent().combattants:
		if combattant.grid_pos == case_cible:
			target = combattant
	
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
		if cible != GlobalData.Cible.LIBRE and cible != GlobalData.Cible.TOUT and cible != GlobalData.Cible.VIDE:
			return false
	return true


func from_arme(combattant, arme):
	var element_principal = "DOMMAGE_FIXE"
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
		var data = GlobalData.equipements[arme].to_json()
		pa = data["pa"]
		po = data["po"]
		type_zone = data["type_zone"] as GlobalData.TypeZone
		taille_zone = data["taille_zone"]
		po_modifiable = data["po_modifiable"]
		effets = data["effets"]
	else:
		pa = 3
		po = Vector2(1, 1)
		type_zone = GlobalData.TypeZone.CERCLE
		taille_zone = Vector2(0, 0)
		po_modifiable = 0
		effets = {element_principal:{"base":{"valeur":5},"critique":{"valeur":7}}}
	nom = "arme"
	ldv = 1
	return self


func copy():
	var new_sort = Sort.new()
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
	new_sort.effets = effets.duplicate(true)
	return new_sort


func from_json(data):
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
		"effets": effets
	}


class Glyphe:
	var id
	var lanceur
	var tiles
	var effets
	var critique
	var bloqueur
	var duree
	var centre
	var aoe
	var sort
	var deleted
	
	func _init(p_id, p_lanceur, p_tiles, p_effets, p_bloqueur, p_critique, p_centre, p_aoe, p_sort):
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
	
	func active_full():
		var triggered = false
		for combattant in lanceur.combat.combattants:
			if combattant.grid_pos in tiles:
				var delta_hp = combattant.max_stats.hp - combattant.stats.hp
				var delta_pa = combattant.max_stats.pa - combattant.stats.pa
				var delta_pm = combattant.max_stats.pm - combattant.stats.pm
				combattant.stats = combattant.init_stats.copy().add(combattant.stat_ret).add(combattant.stat_buffs)
				combattant.stats.hp -= delta_hp
				combattant.stats.pa -= delta_pa
				combattant.stats.pm -= delta_pm
				for effet in effets:
					var new_effet = Effet.new(lanceur, combattant, effet, effets[effet], critique, centre, aoe, sort)
					new_effet.instant = true
					new_effet.execute()
				triggered = true
		if triggered and effets.has("DOMMAGE_FIXE"):
			lanceur.combat.tilemap.delete_glyphes([id])
			deleted = true
	
	func active_mono(combattant):
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
