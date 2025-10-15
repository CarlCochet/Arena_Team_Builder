extends Node2D
class_name Personnage


var classe: String
var nom: String
var stats: Stats
var equipements: Dictionary[String, String]
var sorts: Array[String]


func _ready():
	classe = ""
	nom = ""
	stats = Stats.new()
	equipements = {
		"Armes": "",
		"Familiers": "",
		"Coiffes": "",
		"Capes": "",
		"Dofus": ""
	}
	sorts = []
	calcul_stats()


func _init():
	classe = ""
	nom = ""
	stats = Stats.new()
	equipements = {
		"Armes": "",
		"Familiers": "",
		"Coiffes": "",
		"Capes": "",
		"Dofus": ""
	}
	sorts = []
	calcul_stats()


func calcul_stats():
	if classe:
		stats = Stats.new().add(GlobalData.stats_classes[classe])
		stats.invocations = 1
		for equipement in equipements.values():
			if equipement:
				stats.add(GlobalData.equipements[equipement].stats)
		for sort in sorts:
			stats.kamas += GlobalData.sorts[sort].kamas
	else:
		stats.kamas = 0
	return stats.kamas


func ajoute_sort(nom_sort: String):
	sorts.append(nom_sort)


func copy(personnage: Personnage):
	classe = personnage.classe
	nom = personnage.nom
	stats =  personnage.stats.copy()
	equipements = {}
	sorts = []
	
	for equipement in personnage.equipements:
		equipements[equipement] = personnage.equipements[equipement]
	for sort in personnage.sorts:
		sorts.append(sort)
	
	return self


func from_json(personnage_json):
	equipements = {
		"Armes": "",
		"Familiers": "",
		"Coiffes": "",
		"Capes": "",
		"Dofus": ""
	}
	sorts = []
	classe = personnage_json["classe"]
	equipements = personnage_json["equipements"]
	sorts = personnage_json["sorts"]
	if personnage_json.has("nom"):
		nom = personnage_json["nom"]
	else:
		nom = ""
	calcul_stats()
	return self


func to_json():
	return {
		"classe": classe,
		"nom": nom,
		"equipements": equipements,
		"sorts": sorts
	}
