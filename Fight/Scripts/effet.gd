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

var scene_invocation = preload("res://Fight/invocation.tscn")


func _init(p_lanceur, p_cible, p_categorie, p_contenu, p_critique, p_centre, p_aoe, p_sort):
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
	sort = p_sort
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
		"DOMMAGE_PAR_PA":
			dommage_par_pa()
		"DOMMAGE_PAR_PM":
			dommage_par_pm()
		"DOMMAGE_SI_BOUGE":
			dommage_si_bouge()
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
		_:
			print("No effect matching ", categorie)


func check_immu(dommages: int) -> bool:
	for effet in cible.effets:
		print(effet.etat)
		if "IMMUNISE" == effet.etat:
			return true
		if "RENVOIE_SORT" == effet.etat and nom_sort != "arme":
			for effet_lanceur in lanceur.effets:
				if "IMMUNISE" == effet_lanceur.etat or "RENVOIE_SORT" == effet_lanceur.etat:
					return true
			lanceur.stats.hp -= dommages
			lanceur.stats_perdu.ajoute(-dommages, "hp")
			update_widgets()
			return true
	return false


func get_orientation_bonus():
	if lanceur.grid_pos == cible.grid_pos:
		return 0
	
	var ref_vectors = [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 1), Vector2(1, 0)]
	var bonus = [0.0, 0.2, 0.4, 0.2]
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
	if base is String:
		var values = base.replace("+", "d").split("d")
		base = int(values[2])
		for i in range(int(values[0])):
			base += randi_range(1, int(values[1]) + 1)
	
	var resistance_zone = cible.stats.resistance_zone / 100.0 if aoe else 0.0
	var bonus = get_orientation_bonus() if orientation_bonus else 0.0
	return roundi(base * (1.0 + (stat / 100.0) - (resistance / 100.0) + bonus - resistance_zone))


func update_sacrifice(p_cible):
	for effet in p_cible.effets:
		if effet.etat == "SACRIFICE" and effet.lanceur.id == cible.id:
			if (not effet.lanceur.check_etat("INTRANSPOSABLE")) and (not p_cible.check_etat("INTRANSPOSABLE")):
				var grid_pos = effet.lanceur.grid_pos
				effet.lanceur.bouge_perso(p_cible.grid_pos)
				p_cible.bouge_perso(grid_pos)
			return p_cible
		elif effet.etat == "SACRIFICE":
			if (not effet.lanceur.check_etat("INTRANSPOSABLE")) and (not p_cible.check_etat("INTRANSPOSABLE")):
				var grid_pos = effet.lanceur.grid_pos
				effet.lanceur.bouge_perso(p_cible.grid_pos)
				p_cible.bouge_perso(grid_pos)
			return update_sacrifice(effet.lanceur)
	return p_cible


func applique_dommage(base, stat, resistance, orientation_bonus, type):
	var dommages = max(calcul_dommage(base, stat, resistance, orientation_bonus), cible.stats.hp - cible.max_stats.hp)
	
	if cible.check_etat("SACRIFICE"):
		cible = update_sacrifice(cible)
	
	if type == "retour":
		if lanceur.check_etat("IMMUNISE") and base > 0:
			return
		lanceur.stats.hp -= dommages
		lanceur.stats_perdu.ajoute(-dommages, "hp")
		return
	
	if check_immu(dommages):
		return
	
	cible.stats.hp -= dommages
	cible.stats_perdu.ajoute(-dommages, "hp")
	
	lanceur.stats.hp -= dommages * (cible.stats.renvoi_dommage / 100)
	if cible.stats.renvoi_dommage > 0:
		lanceur.stats_perdu.ajoute(-dommages * (cible.stats.renvoi_dommage / 100), "hp")
	
	if type == "vol":
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		lanceur.stats_perdu.ajoute(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
	
	update_widgets()


func dommage_fixe():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], 0.0, 0.0, not aoe, "normal")
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], 0.0, 0.0, not aoe, "normal")
		var dommages = calcul_dommage(contenu[base_crit]["invocations"], 0.0, 0.0, not aoe)
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], 0.0, 0.0, not aoe, "normal")
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], 0.0, 0.0, false, "retour")


func dommage_pourcent():
	var base_crit = trouve_crit()
	var bonus_orientation = 1 if aoe else 1 + get_orientation_bonus()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(cible.stats.hp * (contenu[base_crit]["allies"] / 100), 0.0, 0.0, not aoe, "normal")
	elif contenu[base_crit].has("invocations") and cible.is_invocation:
		applique_dommage(cible.stats.hp * (contenu[base_crit]["invocations"] / 100), 0.0, 0.0, not aoe, "normal") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(cible.stats.hp * (contenu[base_crit]["valeur"] / 100), 0.0, 0.0, not aoe, "normal") 
	if contenu[base_crit].has("retour"):
		applique_dommage(cible.stats.hp * (contenu[base_crit]["retour"] / 100), 0.0, 0.0, not aoe, "retour") 


func dommage_par_pa():
	pass


func dommage_par_pm():
	pass


func dommage_si_bouge():
	pass


func dommage_air():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe, "normal") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe, "normal") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe, "normal") 
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], lanceur.stats.dommages_air, lanceur.stats.resistances_air, not aoe, "retour") 


func dommage_terre():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe, "normal") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe, "normal") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe, "normal") 
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], lanceur.stats.dommages_terre, lanceur.stats.resistances_terre, not aoe, "retour") 


func dommage_feu():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe, "normal") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation:  
		applique_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe, "normal") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe, "normal") 
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], lanceur.stats.dommages_feu, lanceur.stats.resistances_feu, not aoe, "retour") 


func dommage_eau():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe, "normal") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation:  
		applique_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe, "normal") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe, "normal") 
	if contenu[base_crit].has("retour"):
		applique_dommage(contenu[base_crit]["retour"], lanceur.stats.dommages_eau, lanceur.stats.resistances_eau, not aoe, "retour") 


func vole_air():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe, "vol") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe, "vol") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_air, cible.stats.resistances_air, not aoe, "vol") 
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func vole_terre():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe, "vol") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe, "vol") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_terre, cible.stats.resistances_terre, not aoe, "vol") 
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func vole_feu():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe, "vol") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe, "vol") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_feu, cible.stats.resistances_feu, not aoe, "vol") 
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func vole_eau():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(contenu[base_crit]["allies"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe, "vol") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(contenu[base_crit]["invocations"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe, "vol") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(contenu[base_crit]["valeur"], lanceur.stats.dommages_eau, cible.stats.resistances_eau, not aoe, "vol") 
	if lanceur.stats.hp > lanceur.max_stats.hp:
		lanceur.stats.hp = lanceur.max_stats.hp


func soin():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		applique_dommage(-contenu[base_crit]["allies"], lanceur.stats.soins, 0, false, "normal") 
	elif contenu[base_crit].has("invocations") and cible.is_invocation: 
		applique_dommage(-contenu[base_crit]["invocations"], lanceur.stats.soins, 0, false, "normal") 
	elif contenu[base_crit].has("valeur"):
		applique_dommage(-contenu[base_crit]["valeur"], lanceur.stats.soins, 0, false, "normal") 
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
				cible.stats_perdu.ajoute(contenu[stat][base_crit]["perso"], stat)
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
				cible.stats_perdu.ajoute(contenu[stat][base_crit]["valeur"], stat)
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
				lanceur.stats_perdu.ajoute(contenu[stat][base_crit]["retour"], stat)
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
			if duree > 0:
				cible.stat_buffs[stat] += contenu[stat][base_crit]["valeur"]
			if stat in ["pa", "pm", "hp"]:
				cible.stats_perdu.ajoute(contenu[stat][base_crit]["valeur"], stat)
	update_widgets()


func pousse():
	var direction: Vector2i = (cible.grid_pos - lanceur.grid_pos).sign()
	var grid = combat.tilemap.grid
	var stopped = false
	var old_grid_pos = cible.grid_pos
	for i in range(contenu):
		var grid_pos = cible.grid_pos + (i + 1) * direction
		if grid_pos.x >= 0 and grid_pos.x < len(grid) and grid_pos.y >= 0 and grid_pos.y < len(grid[0]):
			if grid[grid_pos.x][grid_pos.y] == 0 or grid[grid_pos.x][grid_pos.y] == -1:
				if not stopped:
					if not cible.check_etat("IMMUNISE"):
						cible.stats.hp -= (contenu - i) * 3
						cible.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
				break
			elif grid[grid_pos.x][grid_pos.y] == -2:
				if not stopped:
					if not cible.check_etat("IMMUNISE"):
						cible.stats.hp -= (contenu - i) * 3
						cible.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
					for combattant in combat.combattants:
						if combattant.grid_pos == grid_pos and not cible.check_etat("IMMUNISE"):
							combattant.stats.hp -= (contenu - i) * 3
							combattant.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
		else:
			break
	if not stopped:
		cible.bouge_perso(Vector2i(cible.grid_pos) + Vector2i(contenu * direction))
	if cible.check_etat("PORTE_ALLIE") or cible.check_etat("PORTE_ENNEMI"):
		var effet_lance = Effet.new(cible, old_grid_pos, "LANCE", 1, false, old_grid_pos, false, sort)
		effet_lance.execute()
	update_widgets()
	combat.tilemap.update_glyphes()


func attire():
	var direction = -(cible.grid_pos - lanceur.grid_pos).sign()
	var grid = combat.tilemap.grid
	var stopped = false
	var old_grid_pos = cible.grid_pos
	for i in range(contenu):
		var grid_pos = cible.grid_pos + (i + 1) * direction
		if grid_pos.x >= 0 and grid_pos.x < len(grid) and grid_pos.y >= 0 and grid_pos.y < len(grid[0]):
			if grid[grid_pos.x][grid_pos.y] == 0 or grid[grid_pos.x][grid_pos.y] == -1:
				if not stopped:
					if not cible.check_etat("IMMUNISE"):
						cible.stats.hp -= (contenu - i) * 3
						cible.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
				break
			elif grid[grid_pos.x][grid_pos.y] == -2:
				if not stopped:
					if grid_pos != lanceur.grid_pos:
						if not cible.check_etat("IMMUNISE"):
							cible.stats.hp -= (contenu - i) * 3
							cible.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
						for combattant in combat.combattants:
							if combattant.grid_pos == grid_pos and not combattant.check_etat("IMMUNISE"):
								combattant.stats.hp -= (contenu - i) * 3
								combattant.stats_perdu.ajoute(-(contenu - i) * 3, "hp")
					stopped = true
					cible.bouge_perso(grid_pos - direction)
		else:
			break
	if not stopped:
		cible.bouge_perso(Vector2i(cible.grid_pos) + Vector2i(contenu * direction))
	if cible.check_etat("PORTE_ALLIE") or cible.check_etat("PORTE_ENNEMI"):
		var effet_lance = Effet.new(cible, old_grid_pos, "LANCE", 1, false, old_grid_pos, false, sort)
		effet_lance.execute()
	update_widgets()
	combat.tilemap.update_glyphes()


func recul():
	pass


func avance():
	pass


func immobilise():
	etat = "IMMOBILISE"


func teleporte():
	lanceur.bouge_perso(centre)


func transpose():
	if lanceur.check_etat("INTRANSPOSABLE") or cible.check_etat("INTRANSPOSABLE") or cible.check_etat("PORTE"):
		return
	var grid_pos = lanceur.grid_pos
	lanceur.bouge_perso(cible.grid_pos)
	cible.bouge_perso(grid_pos)


func petrifie():
	etat = "PETRIFIE"


func rate_sort():
	etat = "RATE_SORT"


func revele_invisible():
	cible.retire_etats(["INVISIBLE"])


func devient_invisible():
	etat = "INVISIBLE"


func desenvoute():
	for effet in cible.effets:
		if effet.sort.desenvoute_delais >= 0:
			effet.sort.cooldown = effet.sort.desenvoute_delais
			effet.sort.compte_lancers = 0
			effet.sort.compte_cible = {}
	cible.effets = []
	cible.stat_buffs = Stats.new()
	var hp = cible.stats.hp
	cible.stats = cible.init_stats.copy().add(cible.stat_ret).add(cible.stat_buffs)
	cible.stats.hp = hp


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
	var invoc = scene_invocation.instantiate()
	invoc.init(int(contenu))
	invoc.position = combat.tilemap.map_to_local(centre - combat.offset)
	invoc.grid_pos = centre
	combat.tilemap.a_star_grid.set_point_solid(invoc.grid_pos)
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


func porte():
	var etat_lanceur = "PORTE_ALLIE" if lanceur.equipe == cible.equipe else "PORTE_ENNEMI"
	var effet_lanceur = Effet.new(lanceur, cible, etat_lanceur, contenu, false, lanceur.grid_pos, false, sort)
	effet_lanceur.etat = etat_lanceur
	lanceur.effets.append(effet_lanceur)
	etat = "PORTE"
	var map_pos = cible.combat.tilemap.local_to_map(cible.position)
	cible.combat.tilemap.a_star_grid.set_point_solid(cible.grid_pos, false)
	cible.combat.tilemap.grid[cible.grid_pos[0]][cible.grid_pos[1]] = cible.combat.tilemap.get_cell_atlas_coords(1, map_pos).x
	cible.position = lanceur.position + Vector2(0, -90)
	cible.z_index = 1


func lance():
	var combattant_lance
	for combattant in combat.combattants:
		for effet in combattant.effets:
			if effet.etat == "PORTE" and lanceur.id == effet.lanceur.id:
				combattant.position = combat.tilemap.map_to_local(centre - combat.offset)
				combattant.grid_pos = centre
				combat.tilemap.a_star_grid.set_point_solid(combattant.grid_pos)
				combat.tilemap.grid[combattant.grid_pos[0]][combattant.grid_pos[1]] = -2
				combattant.z_index = 0
				combattant.retire_etats(["PORTE"])
				lanceur.retire_etats(["PORTE_ALLIE", "PORTE_ENNEMI"])
				return


func picole():
	etat = "PICOLE"


func sacrifice():
	cible.retire_etats(["SACRIFICE"])
	etat = "SACRIFICE"


func tourne():
	cible.oriente_vers(centre)


func immunise_retrait_pa():
	etat = "IMMUNISE_RETRAIT_PA"


func immunise_retrait_pm():
	etat = "IMMUNISE_RETRAIT_PM"


func suicide():
	lanceur.stats.hp = 0
	combat.check_morts()


func choix():
	pass


func swap():
	pass


func active_aura():
	pass


func maudit_classe():
	pass


func maudit_case():
	pass


func glyphe():
	pass
