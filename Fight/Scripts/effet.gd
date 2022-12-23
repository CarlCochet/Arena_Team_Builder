extends Node
class_name Effet


var lanceur
var cible
var centre: Vector2i
var nom_sort: String
var categorie: String
var contenu
var etat: String
var duree: int
var instant: bool
var critique: bool
var aoe: bool
var combat: Combat


func _init(p_lanceur, p_cible, p_categorie, p_contenu, p_critique, p_centre, p_aoe):
	lanceur = p_lanceur
	cible = p_cible
	centre = p_centre
	categorie = p_categorie
	contenu = p_contenu
	duree = 0
	instant = true
	critique = p_critique
	aoe = p_aoe
	combat = p_lanceur.get_parent()
	if contenu is Dictionary:
		duree = trouve_duree(contenu)


func trouve_duree(data):
	for key in data.keys():
		if data[key] is Dictionary:
			if data[key].has("duree"):
				if data.has("instant"):
					instant = false
				return data[key]["duree"]
			else:
				return trouve_duree(data[key])
	return 0


func check_cible():
	if contenu["cible"] == 6 and (cible.equipe != lanceur.equipe or not cible.is_invocation): 
		return false
	if contenu["cible"] == 7 and (cible.equipe == lanceur.equipe or not cible.is_invocation): 
		return false
	return true


func trouve_crit():
	var base_crit: String = ""
	if critique:
		if contenu.has("critique"):
			base_crit = "critique"
		else:
			for key in contenu.keys():
				if contenu[key].has("critique"):
					base_crit = "critique"
			if base_crit.is_empty():
				base_crit = "base"
	else:
		if contenu.has("base"):
			base_crit = "base"
		else:
			for key in contenu.keys():
				if contenu[key].has("base"):
					base_crit = "base"
	return base_crit


func execute():
	if contenu is Dictionary and contenu.has("cible"):
		if not check_cible():
			return
	
	match categorie:
		"DOMMAGE_FIXE": 
			dommage_fixe()
		"DOMMAGE_POURCENT":
			dommage_pourcent()
		"DOMMAGE_AIR":
			dommage_air()
		"DOMMAGE_TERRE":
			dommage_terre()
		"DOMMAGE_FEU":
			dommage_feu()
		"DOMMAGE_EAU":
			dommage_eau()
		"VOLE_AIR":
			vole_air()
		"VOLE_TERRE":
			vole_terre()
		"VOLE_FEU":
			vole_feu()
		"VOLE_EAU":
			vole_eau()
		"SOIN":
			soin()
		"CHANGE_STATS":
			change_stats()
		"VOLE_STATS":
			vole_stats()
		"POUSSE":
			pousse()
		"ATTIRE":
			attire()
		"IMMOBILISE":
			immobilise()
		"TELEPORTE":
			teleporte()
		"TRANSPOSE":
			transpose()
		"PETRIFIE":
			petrifie()
		"RATE_SORT":
			rate_sort()
		"REVELE_INVISIBLE":
			revele_invisible()
		"DEVIENT_INVISIBLE":
			devient_invisible()
		"DESENVOUTE":
			desenvoute()
		"NON_PORTABLE":
			non_portable()
		"INTRANSPOSABLE":
			intransposable()
		"IMMUNISE":
			immunise()
		"STABILISE":
			stabilise()
		"RENVOIE_SORT":
			renvoie_sort()
		"INVOCATION":
			invocation()
		"PORTE":
			porte()
		"LANCE":
			lance()
		"PICOLE":
			picole()
		"SACRIFICE":
			sacrifice()
		"TOURNE":
			tourne()
		"IMMUNISE_RETRAIT_PA":
			immunise_retrait_pa()
		"IMMUNISE_RETRAIT_PM":
			immunise_retrait_pm()
		"GLYPHE":
			glyphe()
		_:
			print("No effect matching ", categorie)


func check_immu(dommages: int) -> bool:
	for effet in cible.effets:
		if "IMMUNISE" == effet.etat:
			return true
		if "RENVOIE_SORT" == effet.etat and nom_sort != "arme":
			for effet_lanceur in lanceur.effets:
				if "IMMUNISE" == effet_lanceur.etat or "RENVOIE_SORT" == effet_lanceur.etat:
					return true
			lanceur.stats.hp -= dommages
			lanceur.affiche_stats_change(-dommages, "hp")
			update_widgets()
			return true
	return false


func get_orientation_bonus():
	if lanceur.grid_pos == cible.grid_pos:
		return 0
	
	var ref_vectors = [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 1), Vector2(1, 0)]
	var bonus = [0.0, 0.2, 0.4, 0.2]
	var delta = Vector2(lanceur.grid_pos - cible.grid_pos)
	var min_dist = 999999999.0
	var min_vec = 0
	for i in range(len(ref_vectors)):
		var new_dist = Vector2(lanceur.grid_pos).distance_to(Vector2(cible.grid_pos) + ref_vectors[i])
		if new_dist < min_dist:
			min_dist = new_dist
			min_vec = i
	return bonus[(min_vec + cible.orientation) % 4]


func update_widgets():
	for combattant in combat.combattants:
		if combattant.is_hovered:
			combat.stats_hover.update(combattant.stats, combattant.max_stats)
			combattant.hp_label.text = str(combattant.stats.hp) + "/" + str(combattant.max_stats.hp)


func calcul_dommage(base, stat, resistance, orientation_bonus):
	var bonus = get_orientation_bonus() if orientation_bonus else 0
	print(str(base), " ", str(stat), " ", str(resistance), " ", str(bonus))
	return roundi(base * (1.0 + stat / 100.0 - resistance / 100.0 + bonus))


func dommage_fixe():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = calcul_dommage(contenu[base_crit]["allies"], 0.0, 0.0, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp -= dommages * (cible.stats.renvoi_dommage)
		cible.affiche_stats_change(-dommages, "hp")
		if cible.stats.renvoi_dommage > 0:
			lanceur.affiche_stats_change(-dommages * (cible.stats.renvoi_dommage), "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		var dommages = calcul_dommage(contenu[base_crit]["invocations"], 0.0, 0.0, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp -= dommages * (cible.stats.renvoi_dommage)
		cible.affiche_stats_change(-dommages, "hp")
		if cible.stats.renvoi_dommage > 0:
			lanceur.affiche_stats_change(-dommages * (cible.stats.renvoi_dommage), "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = calcul_dommage(contenu[base_crit]["valeur"], 0.0, 0.0, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp -= dommages * (cible.stats.renvoi_dommage)
		cible.affiche_stats_change(-dommages, "hp")
		if cible.stats.renvoi_dommage > 0:
			lanceur.affiche_stats_change(-dommages * (cible.stats.renvoi_dommage), "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		if lanceur.check_etat("IMMUNISE"):
			return
		lanceur.stats.hp -= contenu[base_crit]["retour"]
		lanceur.affiche_stats_change(-contenu[base_crit]["retour"], "hp")
		update_widgets()


func dommage_pourcent():
	var base_crit = trouve_crit()
	var bonus_orientation = 1 if aoe else get_orientation_bonus()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = cible.stats.hp * (contenu[base_crit]["allies"] / 100) * bonus_orientation
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		var dommages = cible.stats.hp * (contenu[base_crit]["invocations"] / 100) * bonus_orientation
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = cible.stats.hp * (contenu[base_crit]["valeur"] / 100) * bonus_orientation
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		if lanceur.check_etat("IMMUNISE"):
			return
		var dommages = lanceur.stats.hp * (contenu[base_crit]["retour"] / 100)
		lanceur.stats.hp -= dommages
		lanceur.affiche_stats_change(-dommages, "hp")
		update_widgets()


func dommage_air():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = calcul_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		var dommages = calcul_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = calcul_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		if lanceur.check_etat("IMMUNISE"):
			return
		var dommages = calcul_dommage(contenu[base_crit]["retour"], lanceur.stats.dommages_air, cible.stats.resistances_air, false)
		lanceur.stats.hp -= dommages
		lanceur.affiche_stats_change(-dommages, "hp")
		update_widgets()


func dommage_terre():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = calcul_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		var dommages = calcul_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = calcul_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		if lanceur.check_etat("IMMUNISE"):
			return
		var dommages = calcul_dommage(contenu[base_crit]["retour"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, false)
		lanceur.stats.hp -= dommages
		lanceur.affiche_stats_change(-dommages, "hp")
		update_widgets()


func dommage_feu():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = calcul_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation:  
		var dommages = calcul_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = calcul_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		if lanceur.check_etat("IMMUNISE"):
			return
		var dommages = calcul_dommage(contenu[base_crit]["retour"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, false)
		lanceur.stats.hp -= dommages
		lanceur.affiche_stats_change(-dommages, "hp")
		update_widgets()


func dommage_eau():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = calcul_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation:  
		var dommages = calcul_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = calcul_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		if lanceur.check_etat("IMMUNISE"):
			return
		var dommages = calcul_dommage(contenu[base_crit]["retour"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, false)
		lanceur.stats.hp -= dommages
		lanceur.affiche_stats_change(-dommages, "hp")
		update_widgets()


func vole_air():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = calcul_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation:  
		var dommages = calcul_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = calcul_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func vole_terre():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = calcul_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		var dommages = calcul_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = calcul_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func vole_feu():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = calcul_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		var dommages = calcul_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = calcul_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func vole_eau():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = calcul_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		var dommages = calcul_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = calcul_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func soin():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var soins = int(contenu[base_crit]["allies"] * (1 + lanceur.stats.soins / 100.0))
		cible.stats.hp += min(soins, cible.max_stats.hp - cible.stats.hp)
		cible.affiche_stats_change(soins, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		var soins = int(contenu[base_crit]["invocations"] * (1 + lanceur.stats.soins / 100.0))
		cible.stats.hp += min(soins, cible.max_stats.hp - cible.stats.hp)
		cible.affiche_stats_change(soins, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var soins = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.soins / 100.0))
		cible.stats.hp += min(soins, cible.max_stats.hp - cible.stats.hp)
		cible.affiche_stats_change(soins, "hp")
		update_widgets()
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func check_retrait_immunite(cible, stat, valeur):
	if cible.check_etat("IMMUNISE_RETRAIT_PA") and stat == "pa" and valeur < 0:
		return true
	if cible.check_etat("IMMUNISE_RETRAIT_PM") and stat == "pm" and valeur < 0:
		return true
	return false


func change_stats():
	var base_crit = trouve_crit()
	for stat in contenu.keys():
		if contenu[stat][base_crit].has("perso") and cible.id == lanceur.id:
			if check_retrait_immunite(cible, stat, contenu[stat][base_crit]["perso"]):
				continue
			if instant:
				cible.stats[stat] += contenu[stat][base_crit]["perso"]
			if duree > 0:
				cible.stat_buffs[stat] += contenu[stat][base_crit]["perso"]
			else:
				cible.stat_ret[stat] += contenu[stat][base_crit]["perso"]
			if contenu[stat][base_crit]["perso"] > 0:
				cible.max_stats[stat] += contenu[stat][base_crit]["perso"]
			if stat in ["pa", "pm", "hp"]:
				cible.affiche_stats_change(contenu[stat][base_crit]["perso"], stat)
		if contenu[stat][base_crit].has("valeur"):
			if check_retrait_immunite(cible, stat, contenu[stat][base_crit]["valeur"]):
				continue
			if instant:
				cible.stats[stat] += contenu[stat][base_crit]["valeur"]
			if duree > 0:
				cible.stat_buffs[stat] += contenu[stat][base_crit]["valeur"]
			else:
				cible.stat_ret[stat] += contenu[stat][base_crit]["valeur"]
			if contenu[stat][base_crit]["valeur"] > 0:
				cible.max_stats[stat] += contenu[stat][base_crit]["valeur"]
			if stat in ["pa", "pm", "hp"]:
				cible.affiche_stats_change(contenu[stat][base_crit]["valeur"], stat)
		if contenu[stat][base_crit].has("retour"):
			if check_retrait_immunite(cible, stat, contenu[stat][base_crit]["retour"]):
				continue
			if instant:
				lanceur.stats[stat] += contenu[stat][base_crit]["retour"]
			if duree > 0:
				cible.stat_buffs[stat] += contenu[stat][base_crit]["retour"]
			else:
				cible.stat_ret[stat] += contenu[stat][base_crit]["retour"]
			if contenu[stat][base_crit]["retour"] > 0:
				lanceur.max_stats[stat] += contenu[stat][base_crit]["retour"]
			if stat in ["pa", "pm", "hp"]:
				lanceur.affiche_stats_change(contenu[stat][base_crit]["retour"], stat)
	update_widgets()


func reverse_change_stats():
	var base_crit = trouve_crit()
	for stat in contenu.keys():
		if contenu[stat][base_crit].has("perso") and cible.id == lanceur.id:
			cible.stats[stat] -= contenu[stat][base_crit]["perso"]
			if contenu[stat][base_crit]["perso"] > 0:
				cible.max_stats[stat] += contenu[stat][base_crit]["perso"]
		if contenu[stat][base_crit].has("valeur"):
			cible.stats[stat] -= contenu[stat][base_crit]["valeur"]
			if contenu[stat][base_crit]["valeur"] > 0:
				cible.max_stats[stat] += contenu[stat][base_crit]["valeur"]
		if contenu[stat][base_crit].has("retour"):
			lanceur.stats[stat] -= contenu[stat][base_crit]["retour"]
			if contenu[stat][base_crit]["retour"] > 0:
				lanceur.max_stats[stat] += contenu[stat][base_crit]["retour"]
	update_widgets()


func vole_stats():
	var base_crit = trouve_crit()
	for stat in contenu.keys():
		if contenu[stat][base_crit].has("valeur"):
			cible.stats[stat] -= contenu[stat][base_crit]["valeur"]
			lanceur.stats[stat] += contenu[stat][base_crit]["valeur"]
			lanceur.max_stats[stat] += contenu[stat][base_crit]["valeur"]
			if stat in ["pa", "pm", "hp"]:
				cible.affiche_stats_change(contenu[stat][base_crit]["valeur"], stat)
	update_widgets()


func pousse():
	var direction: Vector2i = (cible.grid_pos - lanceur.grid_pos).sign()
	var grid = combat.tilemap.grid
	var stopped = false
	for i in range(contenu):
		var grid_pos = cible.grid_pos + (i + 1) * direction
		if grid_pos.x >= 0 and grid_pos.x < len(grid) and grid_pos.y >= 0 and grid_pos.y < len(grid[0]):
			if grid[grid_pos.x][grid_pos.y] == 0 or grid[grid_pos.x][grid_pos.y] == -1:
				if not stopped:
					cible.stats.hp -= (contenu - i) * 3
					cible.affiche_stats_change(-(contenu - i) * 3, "hp")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
				break
			elif grid[grid_pos.x][grid_pos.y] == -2:
				if not stopped:
					cible.stats.hp -= (contenu - i) * 3
					cible.affiche_stats_change(-(contenu - i) * 3, "hp")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
					for combattant in combat.combattants:
						if combattant.grid_pos == grid_pos:
							combattant.stats.hp -= (contenu - i) * 3
							combattant.affiche_stats_change(-(contenu - i) * 3, "hp")
		else:
			break
	if not stopped:
		cible.bouge_perso(Vector2i(cible.grid_pos) + Vector2i(contenu * direction))
	update_widgets()


func attire():
	var direction = -(cible.grid_pos - lanceur.grid_pos).sign()
	var grid = combat.tilemap.grid
	var stopped = false
	for i in range(contenu):
		var grid_pos = cible.grid_pos + (i + 1) * direction
		if grid_pos.x >= 0 and grid_pos.x < len(grid) and grid_pos.y >= 0 and grid_pos.y < len(grid[0]):
			if grid[grid_pos.x][grid_pos.y] == 0 or grid[grid_pos.x][grid_pos.y] == -1:
				if not stopped:
					cible.stats.hp -= (contenu - i) * 3
					cible.affiche_stats_change(-(contenu - i) * 3, "hp")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
				break
			elif grid[grid_pos.x][grid_pos.y] == -2:
				if not stopped:
					if grid_pos != lanceur.grid_pos:
						cible.stats.hp -= (contenu - i) * 3
						cible.affiche_stats_change(-(contenu - i) * 3, "hp")
						for combattant in combat.combattants:
							if combattant.grid_pos == grid_pos:
								combattant.stats.hp -= (contenu - i) * 3
								combattant.affiche_stats_change(-(contenu - i) * 3, "hp")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
		else:
			break
	if not stopped:
		cible.bouge_perso(Vector2i(cible.grid_pos) + Vector2i(contenu * direction))
	update_widgets()


func immobilise():
	etat = "IMMOBILISE"


func teleporte():
	if lanceur.check_etat("IMMOBILISE"):
		return
	lanceur.bouge_perso(centre)


func transpose():
	if lanceur.check_etat("INTRANSPOSABLE") or cible.check_etat("INTRANSPOSABLE"):
		return
	var grid_pos = lanceur.grid_pos
	lanceur.bouge_perso(cible.grid_pos)
	cible.bouge_perso(grid_pos)


func petrifie():
	etat = "PETRIFIE"


func rate_sort():
	etat = "RATE_SORT"


func revele_invisible():
	pass


func devient_invisible():
	etat = "INVISIBLE"


func desenvoute():
	for effet in cible.effets:
		if effet.nom == "CHANGE_STATS":
			pass
	cible.effets = []
	


func non_portable():
	etat = "NON_PORTABLE"


func intransposable():
	etat = "INTRANSPOSABLE"


func immunise():
	etat = "IMMUNISE"


func stabilise():
	etat = "STABILISE"


func renvoie_sort():
	etat = "RENVOIE_SORT"


func invocation():
	pass


func porte():
	if cible.check_etat("NON_PORTABLE"):
		return
	var effet_cible = Effet.new(lanceur, cible, "PORTE", {}, false, lanceur.grid_pos, false)
	cible.effets.append(effet_cible)
	etat = "PORTE_ALLIE" if lanceur.equipe == cible.equipe else "PORTE_ENNEMI"


func lance():
	var combattant_lance
	for combattant in combat.combattants:
		for effet in combattant.effets:
			if effet.etat == "PORTE" and lanceur.id == effet.lanceur.id:
				combattant.bouge_perso(cible)
				return


func picole():
	etat = "PICOLE"


func sacrifice():
	pass


func tourne():
	var direction = (cible.grid_pos - lanceur.grid_pos).sign()


func immunise_retrait_pa():
	etat = "IMMUNISE_RETRAIT_PA"


func immunise_retrait_pm():
	etat = "IMMUNISE_RETRAIT_PM"


func glyphe():
	pass
