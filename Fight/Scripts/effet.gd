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


func execute():
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


func dommage_fixe():
	var damage = contenu["base"]["valeur"]
	for effet in cible.effets:
		if "IMMUNISE" == effet.etat:
			return
		if "RENVOIE_SORT" == effet.etat and nom_sort != "arme":
			lanceur.stats.hp -= damage
			return
	cible.stats.hp -= damage


func dommage_pourcent():
	for effet in cible.effets:
		if "IMMUNISE" == effet.etat:
			return
		if "RENVOIE_SORT" == effet.etat:
			lanceur.stats.hp -= lanceur.stats.hp * (contenu["base"]["valeur"] / 100)
			return
	cible.stats.hp -= cible.stats.hp * (contenu["base"]["valeur"] / 100)


func dommage_air():
	var damage = contenu["base"]["valeur"] * (1 + lanceur.stats.dommages_air)
	for effet in cible.effets:
		if "IMMUNISE" == effet.etat:
			return
		if "RENVOIE_SORT" == effet.etat:
			lanceur.stats.hp -= contenu["base"]["valeur"]
			return
	pass


func dommage_terre():
	pass


func dommage_feu():
	pass


func dommage_eau():
	pass


func vole_air():
	pass


func vole_terre():
	pass


func vole_feu():
	pass


func vole_eau():
	pass


func soin():
	pass


func change_stats():
	pass


func vole_stats():
	pass


func pousse():
	pass


func attire():
	pass


func immobilise():
	pass


func teleporte():
	pass


func transpose():
	pass


func petrifie():
	pass


func rate_sort():
	pass


func revele_invisible():
	pass


func devient_invisible():
	pass


func desenvoute():
	pass


func non_portable():
	pass


func intransposable():
	pass


func immunise():
	pass


func stabilise():
	pass


func renvoie_sort():
	pass


func invocation():
	pass


func porte():
	pass


func lance():
	pass


func picole():
	pass


func sacrifice():
	pass


func tourne():
	pass


func immunise_retrait_pa():
	pass


func immunise_retrait_pm():
	pass
