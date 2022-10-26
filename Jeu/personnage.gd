extends Node
class_name Personnage


var classe: String
var stats: Stats
var equipements: Dictionary
var sorts: Array


func _init():
	classe = ""
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
		for equipement in equipements.values():
			if equipement:
				stats.add(GlobalData.equipements[equipement].stats)
		for sort in sorts:
			stats.kamas += GlobalData.sorts[sort].kamas
	else:
		stats.kamas = 0
	return stats.kamas


func ajoute_sort(nom_sort):
	sorts.append(nom_sort)


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
	stats = Stats.new().from_json(personnage_json["stats"])
	equipements = personnage_json["equipements"]
	sorts = personnage_json["sorts"]
	calcul_stats()
	return self


func to_json():	
	return {
		"classe": classe,
		"stats": stats.to_json(),
		"equipements": equipements,
		"sorts": sorts
	}
