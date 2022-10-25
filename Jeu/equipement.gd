extends Node
class_name Equipement

enum Categories {VIDE, ARME, FAMILIER, COIFFE, CAPE, DOFUS}

var kamas: int = 0
var categorie: Categories = Categories.VIDE
var stats: Stats


func _ready():
	stats = Stats.new()


func _process(delta):
	pass
