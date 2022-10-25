extends Node
class_name Equipe


var personnages: Array
var budget: int


func _ready():
	pass


func _process(delta):
	pass


func calcul_budget():
	budget = 0
	for personnage in personnages:
		budget += personnage.calcul_stats().kamas
