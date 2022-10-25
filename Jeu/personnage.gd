extends Node
class_name Personnage


var classe: String = ""
var stats: Stats
var equipements: Array = []
var sorts: Array = []


func _init(p_classe, p_stats, p_equipements, p_sorts):
	classe = p_classe
	stats = p_stats
	equipements = p_equipements
	sorts = p_sorts


func calcul_stats():
	stats.kamas = 600
	stats.esquive = 100
	for equipement in equipements:
		stats.kamas += equipement.kamas
	for sort in sorts:
		stats.kamas += sort.kamas
