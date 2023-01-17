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
var sort: Sort
var type_cible: GlobalData.Cible
var boost_hp: int
var indirect: bool
var debuffable: bool

var scene_invocation = preload("res://Fight/invocation.tscn")


func _init(p_lanceur, p_cible, p_categorie, p_contenu, p_critique, p_centre, p_aoe, p_sort):
	lanceur = p_lanceur
	cible = p_cible
	centre = p_centre
	categorie = p_categorie
	contenu = p_contenu
	if contenu is Dictionary and contenu.has("cible"):
		type_cible = contenu["cible"] as GlobalData.Cible
		contenu.erase("cible")
	else:
		type_cible = GlobalData.Cible.LIBRE
	duree = 0
	boost_hp = 0
	instant = true
	indirect = false
	critique = p_critique
	aoe = p_aoe
	combat = p_lanceur.get_parent()
	sort = p_sort
	if contenu is Dictionary:
		duree = trouve_duree(contenu)
	debuffable = duree > 0


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
	if type_cible == GlobalData.Cible.INVOCATIONS_ALLIEES and (cible.equipe != lanceur.equipe or not cible.is_invocation): 
		return false
	if type_cible == GlobalData.Cible.INVOCATIONS_ENNEMIES and (cible.equipe == lanceur.equipe or not cible.is_invocation): 
		return false
	return true


func trouve_crit():
	var base_crit: String = ""
	if critique:
		if contenu.has("critique"):
			base_crit = "critique"
		else:
			for key in contenu.keys():
				if contenu[key] is Dictionary:
					if contenu[key].has("critique"):
						base_crit = "critique"
				else:
					continue
			if base_crit.is_empty():
				base_crit = "base"
	else:
		if contenu.has("base"):
			base_crit = "base"
		else:
			for key in contenu.keys():
				if contenu[key] is Dictionary:
					if contenu[key].has("base"):
						base_crit = "base"
				else:
					continue
	return base_crit


func execute():
	if not check_cible():
		return
	
	match categorie:
		"DOMMAGE_FIXE": 
			dommage_fixe()
		"DOMMAGE_POURCENT":
			dommage_pourcent()
		"DOMMAGE_PAR_PA":
			dommage_par_pa()
		"DOMMAGE_PAR_PM":
			dommage_par_pm()
		"DOMMAGE_PAR_PA_UTILISE":
			dommage_par_pa_utilise()
		"DOMMAGE_SI_BOUGE":
			dommage_si_bouge()
		"DOMMAGE_SI_UTILISE_PA":
			dommage_si_utilise_pa()
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
		"RECUL":
			recul()
		"AVANCE":
			avance()
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
		"SUICIDE":
			suicide()
		"CHOIX":
			choix()
		"SWAP":
			swap()
		"ACTIVE_AURA":
			active_aura()
		"MAUDIT_CLASSE":
			maudit_classe()
		"MAUDIT_CASE":
			maudit_case()
		"GLYPHE":
			glyphe()
	update_widgets()


func check_immu(dommages: int) -> bool:
	for effet in cible.effets:
		if "IMMUNISE" == effet.etat:
			return true
		if "RENVOIE_SORT" == effet.etat and lanceur.id != cible.id and sort.nom != "arme" and duree <= 0 and (not sort.effets.has("GLYPHE")) and (not indirect):
			for effet_lanceur in lanceur.effets:
				if "IMMUNISE" == effet_lanceur.etat or "RENVOIE_SORT" == effet_lanceur.etat:
					return true
			lanceur.stats.hp -= dommages
			lanceur.stats_perdu.ajoute(-dommages, "hp")
			return true
	return false


func get_orientation_bonus():
	if lanceur.grid_pos == centre:
		return 0
	if sort != null and sort.effets.has("cible"):
		return 0
	
	var ref_vectors = [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 1), Vector2(1, 0)]
	var bonus = [0.0, 0.2, 0.4, 0.2]
	var min_dist = 999999999.0
	var min_vecs = []
	for i in range(len(ref_vectors)):
		var new_dist = Vector2(lanceur.grid_pos).distance_to(Vector2(cible.grid_pos) + ref_vectors[i])
		if new_dist == min_dist:
			min_vecs.append(i)
		if new_dist < min_dist:
			min_dist = new_dist
			min_vecs = [i]
	
	for vec in min_vecs:
		var bonus_actuel = bonus[(vec + cible.orientation) % 4]
		if bonus_actuel < 0.1:
			return bonus_actuel
		if bonus_actuel > 0.3:
			return bonus_actuel
	return bonus[(min_vecs[0] + cible.orientation) % 4]


func update_widgets():
	for combattant in combat.combattants:
		if combattant.is_hovered:
			combat.stats_hover.update(combattant.stats, combattant.max_stats)
			combattant.hp_label.text = str(combattant.stats.hp) + "/" + str(combattant.max_stats.hp)


func calcul_dommage(base, stat, resistance, orientation_bonus):
	if base is String:
		var values = base.replace("+", "d").split("d")
		base = int(values[2])
		for i in range(int(values[0])):
			base += randi_range(1, int(values[1]) + 1)
	
	var resistance_zone = cible.stats.resistance_zone / 100.0 if aoe else 0.0
	var bonus = get_orientation_bonus() if orientation_bonus else 0.0
	if cible.classe in ["Arbre", "Cadran_De_Xelor", "Bombe_A_Eau", "Bombe_Incendiaire"]:
		bonus = 0.0
	var result = float(base * (1.0 + (stat / 100.0) - (resistance / 100.0) + bonus - resistance_zone))
	var proba_roundup = result - int(result)
	result = int(result) + 1 if randf() < proba_roundup else int(result)
	return result


func update_sacrifice(p_cible, type):
	for effet in p_cible.effets:
		if effet.etat == "SACRIFICE" and effet.lanceur.id == p_cible.id:
			if (not effet.lanceur.check_etats(["INTRANSPOSABLE"])) and (not p_cible.check_etats(["INTRANSPOSABLE"])):
				p_cible.echange_positions(effet.lanceur)
			return p_cible
		elif effet.etat == "SACRIFICE":
			if (not effet.lanceur.check_etats(["INTRANSPOSABLE"])) and (not p_cible.check_etats(["INTRANSPOSABLE"])):
				p_cible.echange_positions(effet.lanceur)
			return update_sacrifice(effet.lanceur, type)
	return p_cible


func applique_dommage(base, stat_element: String, resistance_element: String, orientation_bonus, type):
	if cible.check_etats(["SACRIFICE"]) and not type in ["soin", "retour", "pourcent_retour"]:
		cible = update_sacrifice(cible, type)
	
	var stat = 0.0
	if not stat_element.is_empty():
		stat = lanceur.stats[stat_element]
	var resistance = 0.0
	if not resistance_element.is_empty():
		resistance = cible.stats[resistance_element]
	
	if type in ["pourcent", "pourcent_retour"]:
		base = cible.stats.hp * (base / 100.0)
	
	var dommages = calcul_dommage(base, stat, resistance, orientation_bonus)
	if type == "soin":
		dommages = max(-dommages, cible.stats.hp - cible.max_stats.hp)
	
	if type in ["retour", "pourcent_retour"]:
		if sort.retour_lock:
			return
		if lanceur.check_etats(["IMMUNISE"]) and base > 0:
			return
		var cible_retour = lanceur
		if cible_retour.check_etats(["SACRIFICE"]) and type != "soin":
			cible_retour = update_sacrifice(cible_retour, type)
		cible_retour.stats.hp -= dommages
		cible_retour.stats_perdu.ajoute(-dommages, "hp")
		sort.retour_lock = true
		print(cible_retour.classe, "_", str(cible_retour.id), " perd " if dommages >= 0 else " gagne ", dommages, " PdV.")
		return
	
	if check_immu(dommages) and dommages >= 0:
		return
	
	cible.stats.hp -= dommages
	cible.stats_perdu.ajoute(-dommages, "hp")
	print(cible.classe, "_", str(cible.id), " perd " if dommages >= 0 else " gagne ", dommages, " PdV.")
	
	if cible.stats.renvoi_dommage > 0 and lanceur.id != cible.id and duree <= 0 and (not sort.effets.has("GLYPHE")) and (not indirect) and type != "soin":
		var cible_renvoi = lanceur
		if cible_renvoi.check_etats(["SACRIFICE"]):
			cible_renvoi = update_sacrifice(cible_renvoi, "renvoi")
		var renvoi = dommages * (cible.stats.renvoi_dommage / 100.0)
		cible_renvoi.stats.hp -= renvoi
		cible_renvoi.stats_perdu.ajoute(-renvoi, "hp")
		print(cible_renvoi.classe, "_", str(cible_renvoi.id), " perd ", renvoi, " PdV.")
	
	if type == "vol":
		var soin_vol = min(dommages, lanceur.max_stats.hp - lanceur.stats.hp)
		lanceur.stats.hp += soin_vol
		lanceur.stats_perdu.ajoute(soin_vol, "hp")
		print(lanceur.classe, "_", str(lanceur.id), " gagne ", soin_vol, " PdV.")


func dommage_fixe():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "", "", false, "normal")
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], "", "", false, "normal")
	elif contenu[base_crit].has("maudit") and centre in combat.tilemap.cases_maudites.values():
		applique_dommage(contenu[base_crit]["maudit"], "", "", false, "normal")
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "", "", false, "normal")
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], "", "", false, "retour")


func dommage_pourcent():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "", "", false, "pourcent")
	elif contenu[base_crit].has("invocations") and cible.is_invocation:
		applique_dommage(contenu[base_crit]["invocations"], "", "", false, "pourcent") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "", "", false, "pourcent") 
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], "", "", false, "pourcent_retour") 
	if cible.stats.hp <= 0:
		cible.stats.hp = 1


func dommage_par_pa():
	if cible is Array or cible is Vector2i:
		return
	var pa_restants = lanceur.stats.pa - sort.pa
	var effet = Effet.new(lanceur, cible, contenu.keys()[0], contenu[contenu.keys()[0]], critique, lanceur.grid_pos, aoe, sort)
	for i in range(pa_restants):
		effet.execute()
	lanceur.stats.pa -= pa_restants
	lanceur.stats_perdu.ajoute(-pa_restants, "pa")


func dommage_par_pm():
	if cible is Array or cible is Vector2i:
		return
	var pm_restants = lanceur.stats.pm
	var effet = Effet.new(lanceur, cible, contenu.keys()[0], contenu[contenu.keys()[0]], critique, lanceur.grid_pos, aoe, sort)
	for i in range(pm_restants):
		effet.execute()
	lanceur.stats.pm -= pm_restants
	lanceur.stats_perdu.ajoute(-pm_restants, "pm")


func dommage_par_pa_utilise():
	pass


func dommage_si_bouge():
	if cible is Array or cible is Vector2i:
		return
	etat = "DOMMAGE_SI_BOUGE"
	if not instant:
		var new_effet = Effet.new(lanceur, cible, contenu.keys()[0], contenu[contenu.keys()[0]], critique, centre, false, sort)
		new_effet.indirect = true
		new_effet.execute()
		cible.retire_etats(["DOMMAGE_SI_BOUGE"])
	if instant:
		duree = 1
		instant = false


func dommage_si_utilise_pa():
	if cible is Array or cible is Vector2i:
		return
	etat = "DOMMAGE_SI_UTILISE_PA"
	if not instant:
		var new_effet = Effet.new(lanceur, cible, contenu.keys()[0], contenu[contenu.keys()[0]], critique, centre, false, sort)
		new_effet.indirect = true
		new_effet.execute()
	if instant:
		duree = 1
		instant = false


func dommage_air():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "dommages_air", "resistances_air", not aoe, "normal") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], "dommages_air", "resistances_air", not aoe, "normal") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "dommages_air", "resistances_air", not aoe, "normal") 
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], "dommages_air", "resistances_air", false, "retour") 


func dommage_terre():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "dommages_terre", "resistances_terre", not aoe, "normal") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], "dommages_terre", "resistances_terre", not aoe, "normal") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "dommages_terre", "resistances_terre", not aoe, "normal") 
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], "dommages_terre", "resistances_terre", false, "retour") 


func dommage_feu():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "dommages_feu", "resistances_feu", not aoe, "normal") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation:  
		applique_dommage(contenu[base_crit]["invocations"], "dommages_feu", "resistances_feu", not aoe, "normal") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "dommages_feu", "resistances_feu", not aoe, "normal") 
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], "dommages_feu", "resistances_feu", false, "retour") 


func dommage_eau():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "dommages_eau", "resistances_eau", not aoe, "normal") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation:  
		applique_dommage(contenu[base_crit]["invocations"], "dommages_eau", "resistances_eau", not aoe, "normal") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "dommages_eau", "resistances_eau", not aoe, "normal") 
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], "dommages_eau", "resistances_eau", false, "retour") 


func vole_air():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "dommages_air", "resistances_air", not aoe, "vol") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], "dommages_air", "resistances_air", not aoe, "vol") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "dommages_air", "resistances_air", not aoe, "vol") 
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func vole_terre():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "dommages_terre", "resistances_terre", not aoe, "vol") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], "dommages_terre", "resistances_terre", not aoe, "vol") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "dommages_terre", "resistances_terre", not aoe, "vol") 
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func vole_feu():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "dommages_feu", "resistances_feu", not aoe, "vol") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], "dommages_feu", "resistances_feu", not aoe, "vol") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "dommages_feu", "resistances_feu", not aoe, "vol") 
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func vole_eau():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "dommages_eau", "resistances_eau", not aoe, "vol") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], "dommages_eau", "resistances_eau", not aoe, "vol") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "dommages_eau", "resistances_eau", not aoe, "vol") 
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func soin():
	if cible is Array or cible is Vector2i:
		return
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], "soins", "", false, "soin") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], "soins", "", false, "soin") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], "soins", "", false, "soin") 
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func check_retrait_immunite(combattant, stat, valeur):
	if combattant.check_etats(["IMMUNISE_RETRAIT_PA"]) and stat == "pa" and valeur < 0:
		return true
	if combattant.check_etats(["IMMUNISE_RETRAIT_PM"]) and stat == "pm" and valeur < 0:
		return true
	return false


func change_stats():
	var base_crit = trouve_crit()
	for stat in contenu.keys():
		if contenu[stat][base_crit].has("perso") and cible.id == lanceur.id:
			if check_retrait_immunite(lanceur, stat, contenu[stat][base_crit]["perso"]):
				contenu[stat][base_crit]["perso"] = 0
				continue
			if instant:
				cible.stats[stat] += contenu[stat][base_crit]["perso"]
				if stat == "hp":
					boost_hp = contenu[stat][base_crit]["perso"]
				print(cible.classe, "_", str(cible.id), " perd " if contenu[stat][base_crit]["perso"] < 0 else " gagne ", contenu[stat][base_crit]["perso"], " ", stat, " (", duree, " tours).")
			if duree > 0:
				cible.stat_buffs[stat] += contenu[stat][base_crit]["perso"]
			else:
				cible.stat_ret[stat] += contenu[stat][base_crit]["perso"]
			if contenu[stat][base_crit]["perso"] > 0:
				cible.max_stats[stat] += contenu[stat][base_crit]["perso"]
			if stat in ["pa", "pm", "hp"]:
				cible.stats_perdu.ajoute(contenu[stat][base_crit]["perso"], stat)
		if contenu[stat][base_crit].has("valeur"):
			if check_retrait_immunite(cible, stat, contenu[stat][base_crit]["valeur"]):
				contenu[stat][base_crit]["valeur"] = 0
				continue
			if instant:
				cible.stats[stat] += contenu[stat][base_crit]["valeur"]
				if stat == "hp":
					boost_hp = contenu[stat][base_crit]["valeur"]
				print(cible.classe, "_", str(cible.id), " perd " if contenu[stat][base_crit]["valeur"] < 0 else " gagne ", contenu[stat][base_crit]["valeur"], " ", stat, " (", duree, " tours).")
			if duree > 0:
				cible.stat_buffs[stat] += contenu[stat][base_crit]["valeur"]
			else:
				if sort != null and not sort.effets.has("GLYPHE"):
					cible.stat_ret[stat] += contenu[stat][base_crit]["valeur"]
			if contenu[stat][base_crit]["valeur"] > 0:
				cible.max_stats[stat] += contenu[stat][base_crit]["valeur"]
			if stat in ["pa", "pm", "hp"] and instant:
				cible.stats_perdu.ajoute(contenu[stat][base_crit]["valeur"], stat)
			if stat == "hp":
				instant = false
		if contenu[stat][base_crit].has("retour"):
			if check_retrait_immunite(lanceur, stat, contenu[stat][base_crit]["retour"]):
				contenu[stat][base_crit]["retour"] = 0
				continue
			if instant:
				lanceur.stats[stat] += contenu[stat][base_crit]["retour"]
				if stat == "hp":
					boost_hp = contenu[stat][base_crit]["retour"]
				print(cible.classe, "_", str(cible.id), " perd " if contenu[stat][base_crit]["retour"] < 0 else " gagne ", contenu[stat][base_crit]["retour"], " ", stat, " (", duree, " tours).")
			if duree > 0:
				lanceur.stat_buffs[stat] += contenu[stat][base_crit]["retour"]
			else:
				lanceur.stat_ret[stat] += contenu[stat][base_crit]["retour"]
			if contenu[stat][base_crit]["retour"] > 0:
				lanceur.max_stats[stat] += contenu[stat][base_crit]["retour"]
			if stat in ["pa", "pm", "hp"]:
				lanceur.stats_perdu.ajoute(contenu[stat][base_crit]["retour"], stat)


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


func vole_stats():
	var base_crit = trouve_crit()
	for stat in contenu.keys():
		if contenu[stat][base_crit].has("valeur"):
			cible.stats[stat] -= contenu[stat][base_crit]["valeur"]
			lanceur.stats[stat] += contenu[stat][base_crit]["valeur"]
			lanceur.max_stats[stat] += contenu[stat][base_crit]["valeur"]
			print(lanceur.classe, "_", str(lanceur.id), " vole ", contenu[stat][base_crit]["valeur"], " ", stat, " à ", cible.classe, "_", str(cible.id), " (", duree, " tours).")
			if duree > 0:
				cible.stat_buffs[stat] -= contenu[stat][base_crit]["valeur"]
			if stat in ["pa", "pm", "hp"]:
				cible.stats_perdu.ajoute(-contenu[stat][base_crit]["valeur"], stat)


func pousse():
	if cible.check_etats(["STABILISE"]):
		return
	var direction: Vector2i = (cible.grid_pos - lanceur.grid_pos).sign()
	var grid = combat.tilemap.grid
	var stopped = false
	var old_grid_pos = cible.grid_pos
	for i in range(contenu):
		var grid_pos = cible.grid_pos + (i + 1) * direction
		if grid_pos.x >= 0 and grid_pos.x < len(grid) and grid_pos.y >= 0 and grid_pos.y < len(grid[0]):
			if grid[grid_pos.x][grid_pos.y] == 0 or grid[grid_pos.x][grid_pos.y] == -1:
				if not stopped:
					if not cible.check_etats(["IMMUNISE"]):
						cible.stats.hp -= (contenu - i) * 3
						cible.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
						print(cible.classe, "_", str(cible.id), " perd ", (contenu - i) * 3, " PdV.")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
				break
			elif grid[grid_pos.x][grid_pos.y] == -2:
				if not stopped:
					if not cible.check_etats(["IMMUNISE"]):
						cible.stats.hp -= (contenu - i) * 3
						cible.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
						print(cible.classe, "_", str(cible.id), " perd ", (contenu - i) * 3, " PdV.")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
					for combattant in combat.combattants:
						if combattant.grid_pos == grid_pos and not cible.check_etats(["IMMUNISE"]):
							combattant.stats.hp -= (contenu - i) * 3
							combattant.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
							print(combattant.classe, "_", str(combattant.id), " perd ", (contenu - i) * 3, " PdV.")
		else:
			break
	if not stopped:
		cible.bouge_perso(Vector2i(cible.grid_pos) + Vector2i(contenu * direction))
	if cible.check_etats(["PORTE_ALLIE", "PORTE_ENNEMI"]) and cible.grid_pos != old_grid_pos:
		var effet_lance = Effet.new(cible, old_grid_pos, "LANCE", 1, false, old_grid_pos, false, sort)
		effet_lance.execute()
	combat.tilemap.update_glyphes()


func attire():
	if cible.check_etats(["STABILISE"]):
		return
	var direction = -(cible.grid_pos - lanceur.grid_pos).sign()
	var grid = combat.tilemap.grid
	var stopped = false
	var old_grid_pos = cible.grid_pos
	for i in range(contenu):
		var grid_pos = cible.grid_pos + (i + 1) * direction
		if grid_pos.x >= 0 and grid_pos.x < len(grid) and grid_pos.y >= 0 and grid_pos.y < len(grid[0]):
			if grid[grid_pos.x][grid_pos.y] == 0 or grid[grid_pos.x][grid_pos.y] == -1:
				if not stopped:
					if not cible.check_etats(["IMMUNISE"]):
						cible.stats.hp -= (contenu - i) * 3
						cible.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
						print(cible.classe, "_", str(cible.id), " perd ", (contenu - i) * 3, " PdV.")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
				break
			elif grid[grid_pos.x][grid_pos.y] == -2:
				if not stopped:
					if grid_pos != lanceur.grid_pos:
						if not cible.check_etats(["IMMUNISE"]):
							cible.stats.hp -= (contenu - i) * 3
							cible.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
							print(cible.classe, "_", str(cible.id), " perd ", (contenu - i) * 3, " PdV.")
						for combattant in combat.combattants:
							if combattant.grid_pos == grid_pos and not combattant.check_etats(["IMMUNISE"]):
								combattant.stats.hp -= (contenu - i) * 3
								combattant.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
								print(combattant.classe, "_", str(combattant.id), " perd ", (contenu - i) * 3, " PdV.")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
		else:
			break
	if not stopped:
		cible.bouge_perso(Vector2i(cible.grid_pos) + Vector2i(contenu * direction))
	if cible.check_etats(["PORTE_ALLIE", "PORTE_ENNEMI"]) and cible.grid_pos != old_grid_pos:
		var effet_lance = Effet.new(cible, old_grid_pos, "LANCE", 1, false, old_grid_pos, false, sort)
		effet_lance.execute()
	combat.tilemap.update_glyphes()


func recul():
	if lanceur.check_etats(["STABILISE"]):
		return
	var direction: Vector2i = (lanceur.grid_pos - cible.grid_pos).sign()
	var grid = combat.tilemap.grid
	var stopped = false
	for i in range(contenu):
		var grid_pos = lanceur.grid_pos + (i + 1) * direction
		if grid_pos.x >= 0 and grid_pos.x < len(grid) and grid_pos.y >= 0 and grid_pos.y < len(grid[0]):
			if grid[grid_pos.x][grid_pos.y] == 0 or grid[grid_pos.x][grid_pos.y] == -1:
				if not stopped:
					if not lanceur.check_etats(["IMMUNISE"]):
						lanceur.stats.hp -= (contenu - i) * 3
						lanceur.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
						print(lanceur.classe, "_", str(lanceur.id), " perd ", (contenu - i) * 3, " PdV.")
					stopped = true
					lanceur.bouge_perso(grid_pos - direction)
				break
			elif grid[grid_pos.x][grid_pos.y] == -2:
				if not stopped:
					if not lanceur.check_etats(["IMMUNISE"]):
						lanceur.stats.hp -= (contenu - i) * 3
						lanceur.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
						print(lanceur.classe, "_", str(lanceur.id), " perd ", (contenu - i) * 3, " PdV.")
					stopped = true
					lanceur.bouge_perso(grid_pos - direction)
					for combattant in combat.combattants:
						if combattant.grid_pos == grid_pos and not lanceur.check_etats(["IMMUNISE"]):
							combattant.stats.hp -= (contenu - i) * 3
							combattant.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
							print(combattant.classe, "_", str(combattant.id), " perd ", (contenu - i) * 3, " PdV.")
		else:
			break
	if not stopped:
		lanceur.bouge_perso(Vector2i(lanceur.grid_pos) + Vector2i(contenu * direction))
	combat.tilemap.update_glyphes()


func avance():
	pass


func immobilise():
	etat = "IMMOBILISE"
	print(cible.classe, "_", str(cible.id), " est immobilisé (", duree, " tours).")


func teleporte():
	lanceur.bouge_perso(centre)


func transpose():
	if lanceur.check_etats(["INTRANSPOSABLE"]) or cible.check_etats(["INTRANSPOSABLE", "PORTE", "PORTE_ALLIE", "PORTE_ENNEMI"]):
		return
	cible.echange_positions(lanceur)


func petrifie():
	etat = "PETRIFIE"
	print(cible.classe, "_", str(cible.id), " est pétrifié (", duree, " tours).")


func rate_sort():
	etat = "RATE_SORT"
	print(cible.classe, "_", str(cible.id), " ratera son prochain sort.")


func revele_invisible():
	for combattant in combat.combattants:
		if combattant.id != lanceur.id:
			combat.tilemap.grid[combattant.grid_pos[0]][combattant.grid_pos[1]] = -2
			combattant.retire_etats(["INVISIBLE"])
	print(cible.classe, "_", str(cible.id), " révèle les invisibles.")


func devient_invisible():
	etat = "INVISIBLE"
	combat.tilemap.grid[cible.grid_pos[0]][cible.grid_pos[1]] = combat.tilemap.get_cell_atlas_coords(1, cible.grid_pos - combat.offset).x
	print(cible.classe, "_", str(cible.id), " devient invisible (", duree, " tours).")


func desenvoute():
	var new_effets = []
	for effet in cible.effets:
		if effet.sort != null and effet.sort.desenvoute_delais >= 0:
			effet.sort.cooldown_actuel = effet.sort.desenvoute_delais
			effet.sort.compte_lancers = 0
			effet.sort.compte_cible = {}
		if not effet.debuffable:
			new_effets.append(effet)
	
	cible.effets = new_effets
	cible.stat_buffs = Stats.new()
	cible.execute_effets()
	var delta_hp = cible.max_stats.hp - cible.stats.hp
	cible.stats = cible.init_stats.copy().add(cible.stat_ret).add(cible.stat_buffs)
	cible.stats.hp -= delta_hp
	cible.max_stats = cible.init_stats.copy()
	print(cible.classe, "_", str(cible.id), " est désenvouté.")


func non_portable():
	etat = "NON_PORTABLE"
	print(cible.classe, "_", str(cible.id), " est non-portable (", duree, " tours).")


func intransposable():
	etat = "INTRANSPOSABLE"
	print(cible.classe, "_", str(cible.id), " est intransposable (", duree, " tours).")


func immunise():
	etat = "IMMUNISE"
	print(cible.classe, "_", str(cible.id), " est immunisé (", duree, " tours).")


func stabilise():
	etat = "STABILISE"
	print(cible.classe, "_", str(cible.id), " est stabilisé (", duree, " tours).")


func renvoie_sort():
	etat = "RENVOIE_SORT"
	print(cible.classe, "_", str(cible.id), " renvoie les sorts (", duree, " tours).")


func invocation():
	var invoc = scene_invocation.instantiate()
	invoc.init(int(contenu))
	invoc.position = combat.tilemap.map_to_local(centre - combat.offset)
	invoc.grid_pos = centre
	combat.tilemap.a_star_grid.set_point_solid(invoc.grid_pos)
	if int(contenu) != 9:
		combat.tilemap.grid[invoc.grid_pos[0]][invoc.grid_pos[1]] = -2
	invoc.equipe = lanceur.equipe
	combat.indexeur_global += 1
	invoc.id = combat.indexeur_global
	invoc.invocateur = lanceur
	combat.add_child(invoc)
	for i in range(len(combat.combattants)):
		if combat.combattants[i].id == lanceur.id:
			if i < len(combat.combattants) - 1:
				combat.combattants.insert(i + 1, invoc)
				break
			else:
				combat.combattants.append(invoc)
				break
	print(lanceur.classe, "_", str(lanceur.id), " invoque un ", sort.nom ,".")


func porte():
	if etat != "PORTE":
		var etat_lanceur = "PORTE_ALLIE" if lanceur.equipe == cible.equipe else "PORTE_ENNEMI"
		var effet_lanceur = Effet.new(lanceur, cible, etat_lanceur, contenu, false, lanceur.grid_pos, false, sort)
		effet_lanceur.etat = etat_lanceur
		effet_lanceur.debuffable = false
		lanceur.effets.append(effet_lanceur)
		etat = "PORTE"
		debuffable = false
		var map_pos = cible.grid_pos - combat.offset
		cible.combat.tilemap.a_star_grid.set_point_solid(cible.grid_pos, false)
		cible.combat.tilemap.grid[cible.grid_pos[0]][cible.grid_pos[1]] = cible.combat.tilemap.get_cell_atlas_coords(1, map_pos).x
		cible.position = lanceur.position + Vector2(0, -90)
		cible.grid_pos = lanceur.grid_pos
		cible.z_index = 1


func lance():
	for combattant in combat.combattants:
		for effet in combattant.effets:
			if effet.etat == "PORTE" and lanceur.id == effet.lanceur.id:
				combattant.oriente_vers(centre)
				combattant.position = combat.tilemap.map_to_local(centre - combat.offset)
				combattant.grid_pos = centre
				combat.tilemap.a_star_grid.set_point_solid(combattant.grid_pos)
				combat.tilemap.grid[combattant.grid_pos[0]][combattant.grid_pos[1]] = -2
				combattant.z_index = 0
				var new_sort = null
				if sort != null:
					new_sort = sort.copy()
					new_sort.pa = 0
					new_sort.cible = GlobalData.Cible.LIBRE
					new_sort.effets.erase("LANCE")
				combattant.retire_etats(["PORTE"])
				lanceur.retire_etats(["PORTE_ALLIE", "PORTE_ENNEMI"])
				if new_sort != null:
					new_sort.execute_effets(lanceur, [centre], centre)
				combat.tilemap.update_glyphes()
				return


func picole():
	etat = "PICOLE"
	print(lanceur.classe, "_", str(lanceur.id), " entre dans l'état picole.")


func sacrifice():
	for effet in cible.effets:
		if effet.etat == "SACRIFICE" and effet.lanceur.id != lanceur.id:
			cible.retire_etats(["SACRIFICE"])
			break
	etat = "SACRIFICE"
	print(lanceur.classe, "_", str(lanceur.id), " sacrifie ", cible.classe, "_", str(cible.id), " (", duree, " tours).")


func tourne():
	cible.oriente_vers(centre)


func immunise_retrait_pa():
	etat = "IMMUNISE_RETRAIT_PA"
	print(cible.classe, "_", str(cible.id), " est immunisé au retrait PA (", duree, " tours).")


func immunise_retrait_pm():
	etat = "IMMUNISE_RETRAIT_PM"
	print(cible.classe, "_", str(cible.id), " est immunisé au retrait PM (", duree, " tours).")


func suicide():
	lanceur.stats.hp = 0
	combat.check_morts()


func choix():
	combat.etat = 2
	var block = Control.new()
	block.position = combat.tilemap.map_to_local(centre - combat.offset)
	combat.add_child(block)
	for i in range(len(contenu.keys())):
		var bouton = Button.new()
		bouton.text = contenu.keys()[i]
		bouton.position = Vector2(i * 300 - 220, -25)
		bouton.connect("pressed", _on_choix_clicked.bind(i, block))
		bouton.z_index = 1
		block.add_child(bouton)


func _on_choix_clicked(i, block):
	combat.etat = 1
	var new_categorie = contenu[contenu.keys()[i]].keys()[0]
	var new_contenu = contenu[contenu.keys()[i]][contenu[contenu.keys()[i]].keys()[0]]
	var new_effet = Effet.new(lanceur, cible, new_categorie, new_contenu, critique, cible.grid_pos, false, sort)
	new_effet.execute()
	block.queue_free()


func swap():
	pass


func active_aura():
	pass


func maudit_classe():
	pass


func maudit_case():
	combat.tilemap.cases_maudites[lanceur.id] = centre


func glyphe():
	pass
