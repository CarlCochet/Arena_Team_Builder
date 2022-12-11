extends Node
class_name Effet


var lanceur
var cible
var nom_sort: String
var categorie: String
var contenu
var etat: String
var duree: int
var instant: bool
var critique: bool


func _init(p_lanceur, p_cible, p_categorie, p_contenu, p_critique):
	lanceur = p_lanceur
	cible = p_cible
	categorie = p_categorie
	contenu = p_contenu
	duree = 0
	instant = true
	critique = p_critique
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
	if contenu["cible"] == 6 and (cible.equipe != lanceur.equipe or not cible is Invocation):
		return false
	if contenu["cible"] == 7 and (cible.equipe == lanceur.equipe or not cible is Invocation):
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


func update_widgets():
	for combattant in lanceur.get_parent().combattants:
		if combattant.is_hovered:
			combattant.get_parent().stats_hover.update(combattant.stats, combattant.max_stats)
			combattant.hp_label.text = str(combattant.stats.hp) + "/" + str(combattant.max_stats.hp)


func dommage_fixe():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = contenu[base_crit]["allies"]
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible is Invocation:
		var dommages = contenu[base_crit]["invocations"]
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = contenu[base_crit]["valeur"]
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		for effet in lanceur.effets:
			if "IMMUNISE" == effet.etat:
				return
		lanceur.stats.hp -= contenu[base_crit]["retour"]
		lanceur.affiche_stats_change(-contenu[base_crit]["retour"], "hp")
		update_widgets()


func dommage_pourcent():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = cible.stats.hp * (contenu[base_crit]["allies"] / 100)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible is Invocation:
		var dommages = cible.stats.hp * (contenu[base_crit]["invocations"] / 100)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = cible.stats.hp * (contenu[base_crit]["valeur"] / 100)
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		for effet in lanceur.effets:
			if "IMMUNISE" == effet.etat:
				return
		var dommages = lanceur.stats.hp * (contenu[base_crit]["retour"] / 100)
		lanceur.stats.hp -= dommages
		lanceur.affiche_stats_change(-dommages, "hp")
		update_widgets()


func dommage_air():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = int(contenu[base_crit]["allies"] * (1 + lanceur.stats.dommages_air / 100.0) * (1 - cible.stats.resistances_air / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible is Invocation:
		var dommages = int(contenu[base_crit]["invocations"] * (1 + lanceur.stats.dommages_air / 100.0) * (1 - cible.stats.resistances_air / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.dommages_air / 100.0) * (1 - cible.stats.resistances_air / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		for effet in lanceur.effets:
			if "IMMUNISE" == effet.etat:
				return
		var dommages = int(contenu[base_crit]["retour"] * (1 + lanceur.stats.dommages_air / 100.0) * (1 - cible.stats.resistances_air / 100.0))
		lanceur.stats.hp -= dommages
		lanceur.affiche_stats_change(-dommages, "hp")
		update_widgets()


func dommage_terre():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = int(contenu[base_crit]["allies"] * (1 + lanceur.stats.dommages_terre / 100.0) * (1 - cible.stats.resistances_terre / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible is Invocation:
		var dommages = int(contenu[base_crit]["invocations"] * (1 + lanceur.stats.dommages_terre / 100.0) * (1 - cible.stats.resistances_terre / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.dommages_terre / 100.0) * (1 - cible.stats.resistances_terre / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		for effet in lanceur.effets:
			if "IMMUNISE" == effet.etat:
				return
		var dommages = int(contenu[base_crit]["retour"] * (1 + lanceur.stats.dommages_terre / 100.0) * (1 - cible.stats.resistances_terre / 100.0))
		lanceur.stats.hp -= dommages
		lanceur.affiche_stats_change(-dommages, "hp")
		update_widgets()


func dommage_feu():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = int(contenu[base_crit]["allies"] * (1 + lanceur.stats.dommages_feu / 100.0) * (1 - cible.stats.resistances_feu / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible is Invocation:
		var dommages = int(contenu[base_crit]["invocations"] * (1 + lanceur.stats.dommages_feu / 100.0) * (1 - cible.stats.resistances_feu / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.dommages_feu / 100.0) * (1 - cible.stats.resistances_feu / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		for effet in lanceur.effets:
			if "IMMUNISE" == effet.etat:
				return
		var dommages = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.dommages_feu / 100.0) * (1 - cible.stats.resistances_feu / 100.0))
		lanceur.stats.hp -= dommages
		lanceur.affiche_stats_change(-dommages, "hp")
		update_widgets()


func dommage_eau():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = int(contenu[base_crit]["allies"] * (1 + lanceur.stats.dommages_eau / 100.0) * (1 - cible.stats.resistances_eau / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible is Invocation:
		var dommages = int(contenu[base_crit]["invocations"] * (1 + lanceur.stats.dommages_eau / 100.0) * (1 - cible.stats.resistances_eau / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.dommages_eau / 100.0) * (1 - cible.stats.resistances_eau / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		cible.affiche_stats_change(-dommages, "hp")
		update_widgets()
	if contenu[base_crit].has("retour"):
		for effet in lanceur.effets:
			if "IMMUNISE" == effet.etat:
				return
		var dommages = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.dommages_eau / 100.0) * (1 - cible.stats.resistances_eau / 100.0))
		lanceur.stats.hp -= dommages
		lanceur.affiche_stats_change(-dommages, "hp")
		update_widgets()


func vole_air():
	var base_crit = trouve_crit()
	if contenu[base_crit].has("allies") and lanceur.equipe == cible.equipe:
		var dommages = int(contenu[base_crit]["allies"] * (1 + lanceur.stats.dommages_air / 100.0) * (1 - cible.stats.resistances_air / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible is Invocation:
		var dommages = int(contenu[base_crit]["invocations"] * (1 + lanceur.stats.dommages_air / 100.0) * (1 - cible.stats.resistances_air / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.dommages_air / 100.0) * (1 - cible.stats.resistances_air / 100.0))
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
		var dommages = int(contenu[base_crit]["allies"] * (1 + lanceur.stats.dommages_terre / 100.0) * (1 - cible.stats.resistances_terre / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible is Invocation:
		var dommages = int(contenu[base_crit]["invocations"] * (1 + lanceur.stats.dommages_terre / 100.0) * (1 - cible.stats.resistances_terre / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.dommages_terre / 100.0) * (1 - cible.stats.resistances_terre / 100.0))
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
		var dommages = int(contenu[base_crit]["allies"] * (1 + lanceur.stats.dommages_feu / 100.0) * (1 - cible.stats.resistances_feu / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible is Invocation:
		var dommages = int(contenu[base_crit]["invocations"] * (1 + lanceur.stats.dommages_feu / 100.0) * (1 - cible.stats.resistances_feu / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.dommages_feu / 100.0) * (1 - cible.stats.resistances_feu / 100.0))
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
		var dommages = int(contenu[base_crit]["allies"] * (1 + lanceur.stats.dommages_eau / 100.0) * (1 - cible.stats.resistances_eau / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("invocations") and cible is Invocation:
		var dommages = int(contenu[base_crit]["invocations"] * (1 + lanceur.stats.dommages_eau / 100.0) * (1 - cible.stats.resistances_eau / 100.0))
		if check_immu(dommages):
			return
		cible.stats.hp -= dommages
		lanceur.stats.hp += min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp)
		cible.affiche_stats_change(-dommages, "hp")
		lanceur.affiche_stats_change(min(dommages / 2, lanceur.max_stats.hp - lanceur.stats.hp), "hp")
		update_widgets()
	elif contenu[base_crit].has("valeur"):
		var dommages = int(contenu[base_crit]["valeur"] * (1 + lanceur.stats.dommages_eau / 100.0) * (1 - cible.stats.resistances_eau / 100.0))
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
	elif contenu[base_crit].has("invocations") and cible is Invocation:
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


func change_stats():
	var base_crit = trouve_crit()
	for stat in contenu.keys():
		if contenu[stat][base_crit].has("perso") and cible.id == lanceur.id:
			cible.stats[stat] += contenu[stat][base_crit]["perso"]
			if contenu[stat][base_crit]["perso"] > 0:
				cible.max_stats[stat] += contenu[stat][base_crit]["perso"]
			if stat in ["pa", "pm", "hp"]:
				cible.affiche_stats_change(contenu[stat][base_crit]["perso"], stat)
		if contenu[stat][base_crit].has("valeur"):
			cible.stats[stat] += contenu[stat][base_crit]["valeur"]
			if contenu[stat][base_crit]["valeur"] > 0:
				cible.max_stats[stat] += contenu[stat][base_crit]["valeur"]
			if stat in ["pa", "pm", "hp"]:
				cible.affiche_stats_change(contenu[stat][base_crit]["valeur"], stat)
		if contenu[stat][base_crit].has("retour"):
			lanceur.stats[stat] += contenu[stat][base_crit]["retour"]
			if contenu[stat][base_crit]["retour"] > 0:
				lanceur.max_stats[stat] += contenu[stat][base_crit]["retour"]
			if stat in ["pa", "pm", "hp"]:
				lanceur.affiche_stats_change(contenu[stat][base_crit]["retour"], stat)
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
	var grid = lanceur.get_parent().tilemap.grid
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
					for combattant in lanceur.get_parent().combattants:
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
	var grid = lanceur.get_parent().tilemap.grid
	var stopped = false
	for i in range(contenu):
		var grid_pos = cible.grid_pos + (i + 1) * direction
		if grid_pos.x >= 0 and grid_pos.x < len(grid) and grid_pos.y >= 0 and grid_pos.y < len(grid[0]):
			if grid[grid_pos.x][grid_pos.y] == 0 or grid[grid_pos.x][grid_pos.y] == -1:
				if not stopped:
					if grid_pos != lanceur.grid_pos:
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
					for combattant in lanceur.get_parent().combattants:
						if combattant.grid_pos == grid_pos:
							combattant.stats.hp -= (contenu - i) * 3
							combattant.affiche_stats_change(-(contenu - i) * 3, "hp")
		else:
			break
	if not stopped:
		cible.bouge_perso(Vector2i(cible.grid_pos) + Vector2i(contenu * direction))
	update_widgets()


func immobilise():
	etat = "IMMOBILISE"


func teleporte():
	lanceur.bouge_perso(cible)


func transpose():
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
	pass


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
	pass


func lance():
	pass


func picole():
	etat = "PICOLE"


func sacrifice():
	pass


func tourne():
	pass


func immunise_retrait_pa():
	etat = "IMMUNISE_RETRAIT_PA"


func immunise_retrait_pm():
	etat = "IMMUNISE_RETRAIT_PM"
