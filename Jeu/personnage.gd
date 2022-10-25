extends Node
class_name Personnage


var stats: Stats
var equipements: Array
var sorts: Array


func _ready():
	stats = Stats.new()


func _process(delta):
	pass


func calcul_stats():
	stats.kamas = 600
	stats.esquive = 100
	for equipement in equipements:
		stats.kamas += equipement.kamas
	for sort in sorts:
		stats.kamas += sort.kamas
