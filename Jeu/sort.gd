extends Node2D
class_name Sort


var nom: String
var kamas: int = 0
var pa: int
var po: Vector2
var po_modifiable: int
var type_zone: GlobalData.TypeZone
var taille_zone: int
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
var cooldown_actuel: int


func _init():
	nom = ""
	kamas = 0
	pa = 0
	po = Vector2(0, 0)
	po_modifiable = 1
	type_zone = GlobalData.TypeZone.CERCLE
	taille_zone = 0
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
	
	compte_lancers = 0
	cooldown_actuel = 0
	compte_lancers_tour = 0


func execute_effets(lanceur, cases_cibles, centre) -> bool:
	var sort_valide = true
	var aoe = false
	if len(cases_cibles) == 0:
		return false
	if len(cases_cibles) > 1:
		aoe = true
	var combattants = lanceur.get_parent().combattants
	var trouve = false
	var critique = randi_range(1, 100) <= lanceur.stats.cc
	
	if not effets.has("cible"):
		for combattant in combattants:
			if combattant.grid_pos in cases_cibles:
				trouve = true
				parse_effets(lanceur, combattant, effets, critique, centre, aoe)
	elif effets["cible"] == 4:
		for combattant in combattants:
			if combattant.equipe != lanceur.equipe:
				trouve = true
				parse_effets(lanceur, combattant, effets, critique, centre, aoe)
	elif effets["cible"] == 8:
		for combattant in combattants:
			trouve = true
			parse_effets(lanceur, combattant, effets, critique, centre, aoe)
	elif effets["cible"] == 9:
		for combattant in combattants:
			if combattant.grid_pos in cases_cibles:
				trouve = true
				parse_effets(lanceur, combattant, effets, critique, centre, aoe)
				for combattant_bis in combattants:
					if combattant_bis.classe == combattant.classe:
						parse_effets(lanceur, combattant, effets, critique, centre, aoe)
	elif effets["cible"] == 10:
		for combattant in combattants:
			if not combattant.is_invocation: 
				trouve = true
				parse_effets(lanceur, combattant, effets, critique, centre, aoe)
	elif effets["cible"] == 11:
		for combattant in combattants:
			if combattant.equipe == lanceur.equipe and not combattant.is_invocation:
				trouve = true
				parse_effets(lanceur, combattant, effets, critique, centre, aoe)
	
	if not trouve:
		if "GLYPHE" in effets.keys():
			var new_glyphe = Glyphe.new(
				len(lanceur.combat.tilemap.glyphes) - 1, 
				lanceur, 
				cases_cibles, 
				effets, 
				effets.has("DOMMAGE_FIXE"), 
				critique, 
				centre, 
				aoe)
			
			for effet in effets.keys():
				var new_effet = Effet.new(lanceur, cases_cibles, effet, effets[effet], critique, centre, aoe)
				for case in cases_cibles:
					if lanceur.get_parent().tilemap.effets.has(case):
						lanceur.get_parent().tilemap.effets[case].append(new_effet)
					else:
						lanceur.get_parent().tilemap.effets[case] = [new_effet]
	
	compte_lancers += 1
	compte_lancers_tour += 1
	cooldown_actuel = cooldown
	
	if cooldown_global > 0:
		for combattant in combattants:
			for sort in combattant.sorts:
				if sort.nom == nom and sort.cooldown_actuel < cooldown_global:
					sort.cooldown_actuel = cooldown_global
	
	lanceur.combat.sorts.update(lanceur)
	return sort_valide


func parse_effets(lanceur, p_cible, p_effets, critique, centre, aoe):
	for etat in etats_cible_interdits:
		if p_cible.check_etat(etat):
			return false
	for effet in p_effets.keys():
		var new_effet = Effet.new(lanceur, p_cible, effet, p_effets[effet], critique, centre, aoe)
		if new_effet.instant:
			new_effet.execute()
		if new_effet.duree > 0:
			p_cible.effets.append(new_effet)
	return true


func precheck_cast(lanceur) -> bool:
	if pa > lanceur.stats.pa:
		print("Not enough AP")
		return false
	if cooldown_actuel > 0:
		print("Spell in CD")
		return false
	if compte_lancers >= nombre_lancers and nombre_lancers > 0:
		print("Max cast reached")
		return false
	if compte_lancers_tour >= lancer_par_tour and lancer_par_tour > 0:
		print("Max cast per turn reached")
		return false
	if lanceur.check_etat("PORTE"):
		print("Caster is carried")
		return false
	for etat in etats_lanceur_interdits:
		if lanceur.check_etat(etat):
			print("Caster is in forbidden state ", etat)
			return false
	if not etat_requis.is_empty() and not lanceur.check_etat(etat_requis):
		print("Caster is not in required state ", etat_requis)
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
		print(not target is Combattant)
		if cible == GlobalData.Cible.MOI and target.id != lanceur.id:
			return false
		if cible == GlobalData.Cible.ALLIES and lanceur.equipe != target.equipe:
			return false
		if cible == GlobalData.Cible.ENNEMIS and lanceur.equipe == target.equipe:
			return false
		if cible == GlobalData.Cible.INVOCATIONS and not target.is_invocation: 
			return false
		if cible == GlobalData.Cible.INVOCATIONS_ALLIEES and lanceur.equipe != target.equipe and not target.is_invocation: 
			return false
		if cible == GlobalData.Cible.INVOCATIONS_ENNEMIES and lanceur.equipe == target.equipe and not target.is_invocation: 
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


func from_arme(_combattant, arme):
	if not arme.is_empty():
		var data = GlobalData.equipements[arme].to_json()
		pa = data["pa"]
		po = data["po"]
		type_zone = data["type_zone"] as GlobalData.TypeZone
		taille_zone = data["taille_zone"]
		effets = data["effets"]
	else:
		pa = 3
		po = Vector2(1, 1)
		type_zone = GlobalData.TypeZone.CERCLE
		taille_zone = 0
		effets = { "DOMMAGE_FIXE": { "base": { "valeur": 5 }, "critique": { "valeur": 7 } } }
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
	new_sort.effets = effets
	return new_sort


func from_json(data):
	kamas = data["kamas"]
	pa = data["pa"]
	po = Vector2(data["po"][0], data["po"][1])
	po_modifiable = data["po_modifiable"]
	type_zone = data["type_zone"] as GlobalData.TypeZone
	taille_zone = data["taille_zone"]
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
	
	func _init(p_id, p_lanceur, p_tiles, p_effets, p_bloqueur, p_critique, p_centre, p_aoe):
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
	
	func active_full():
		for tile in tiles:
			for combattant in lanceur.combat.combattants:
				if combattant.grid_pos == tile:
					for effet in effets:
						var new_effet = Effet.new(lanceur, combattant, effet, effets[effet], critique, centre, aoe)
	
	func active_mono(combattant):
		for tile in tiles:
			if combattant.grid_pos == tile:
				for effet in effets:
					var new_effet = Effet.new(lanceur, combattant, effet, effets[effet], critique, centre, aoe)
	
	func affiche():
		for tile in tiles:
			if effets.has("DOMMAGE_FIXE"):
				lanceur.combat.tilemap.set_cell(3, tile, 1, Vector2i(0, 0))
			if effets.has("INVISIBLE"):
				lanceur.combat.tilemap.set_cell(4, tile, 1, Vector2i(1, 0))
