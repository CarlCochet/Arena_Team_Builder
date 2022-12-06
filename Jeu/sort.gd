extends Node2D
class_name Sort


var nom: String
var kamas: int = 0
var pa: int
var po: Vector2
var type_zone: GlobalData.TypeZone
var taille_zone: int
var cible: GlobalData.Cible
var ldv: int
var type_ldv: GlobalData.TypeLDV
var cooldown: int
var cooldown_global: int
var lancer_par_tour: int
var lancer_par_cible: int
var effets: Dictionary


func _init():
	nom = ""
	kamas = 0
	pa = 0
	po = Vector2(0, 0)
	type_zone = GlobalData.TypeZone.CERCLE
	taille_zone = 0
	cible = GlobalData.Cible.LIBRE
	ldv = 0
	type_ldv = GlobalData.TypeLDV.CERCLE
	cooldown = 0
	cooldown_global = 0
	lancer_par_tour = -1
	lancer_par_cible = -1
	effets = {}


func execute_effets(lanceur, cases_cibles) -> bool:
	var sort_valide = true
	if len(cases_cibles) == 0:
		return false
	if pa > lanceur.stats.pa:
		return false
	
	var combattants = lanceur.get_parent().combattants
	var trouve = false
	for combattant in combattants:
		if combattant.grid_pos in cases_cibles:
			trouve = true
			for effet in effets.keys():
				var new_effet = Effet.new(lanceur, combattant, effet, effets[effet])
				if new_effet.duree == 0:
					new_effet.execute()
				else:
					combattant.effets.append(new_effet)
	
	if not trouve:
		for effet in effets.keys():
			var new_effet = Effet.new(lanceur, cases_cibles, effet, effets[effet])
			if new_effet.duree == 0:
				new_effet.execute()
			else:
				lanceur.get_parent().tilemap.effets.append(new_effet)
	return sort_valide


func from_arme(_combattant, arme):
	if not arme.is_empty():
		var data = GlobalData.equipements[arme].to_json()
		pa = data["pa"]
		po = data["po"]
		type_zone = data["type_zone"]
		taille_zone = data["taille_zone"]
		effets = data["effets"]
	else:
		pa = 3
		po = Vector2(1, 1)
		type_zone = 0
		taille_zone = 0
		effets = { "DOMMAGE_FIXE": { "base": { "valeur": 5 }, "critique": { "valeur": 7 } } }
	type_ldv = 0
	ldv = 1
	cooldown = 0
	cooldown_global = 0
	lancer_par_tour = -1
	lancer_par_cible = -1


func from_json(data):
	kamas = data["kamas"]
	pa = data["pa"]
	po = Vector2(data["po"][0], data["po"][1])
	type_zone = data["type_zone"] as GlobalData.TypeZone
	taille_zone = data["taille_zone"]
	cible = data["cible"] as GlobalData.Cible
	ldv = data["ldv"]
	type_ldv = data["type_ldv"] as GlobalData.TypeLDV
	cooldown = data["cooldown"]
	cooldown_global = data["cooldown_global"]
	lancer_par_tour = data["lancer_par_tour"]
	lancer_par_cible = data["lancer_par_cible"]
	effets = data["effets"]
	return self


func to_json():
	return {
		"kamas": kamas,
		"pa": pa,
		"po": [po[0], po[1]],
		"type_zone": type_zone,
		"taille_zone": taille_zone,
		"cible": cible,
		"ldv": ldv,
		"type_ldv": type_ldv,
		"cooldown": cooldown,
		"cooldown_global": cooldown_global,
		"lancer_par_tour": lancer_par_tour,
		"lancer_par_cible": lancer_par_cible,
		"effets": effets
	}
