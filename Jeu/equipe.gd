extends Node
class_name Equipe


var personnages: Array = []
var budget: int = 0


func calcul_budget():
	budget = 0
	for personnage in personnages:
		budget += personnage.calcul_stats().kamas
