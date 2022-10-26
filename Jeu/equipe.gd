extends Node
class_name Equipe


var personnages: Array = []
var budget: int = 0


func _init():
	for i in range(6):
		personnages.append(Personnage.new())
	calcul_budget()


func calcul_budget():
	budget = 0
	for personnage in personnages:
		budget += personnage.calcul_stats()
	return budget


func from_json(personnages_json):
	personnages = []
	for personnage in personnages_json:
		personnages.append(Personnage.new().from_json(personnage))
	calcul_budget()
	return self


func to_json():
	var personnages_json = []
	for personnage in personnages:
		personnages_json.append(personnage.to_json())
	return personnages_json
