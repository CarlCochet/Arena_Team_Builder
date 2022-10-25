extends Node


enum TypeZone {CERCLE, LIGNE, BATON, CARRE, CROIX, MARTEAU}
enum Cible {LIBRE, MOI, VIDE, ALLIES, ENNEMIS, INVOCATIONS, INVOCATIONS_ALLIEES, INVOCATIONS_ENNEMIES}
enum TypeLDV {CERCLE, LIGNE, DIAGONAL}

var sorts: Dictionary
var equipements: Dictionary
var equipes: Array

var equipe_actuelle: Equipe
var personnage_actuel: Personnage


func _ready():
	charger_sorts()
	charger_equipements()
	charger_equipes()


func charger_sorts():
	var file = FileAccess.open("res://Jeu/sorts.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	var sort: Sort
	
	for classe in json_data.keys():
		for nom_sort in json_data[classe].keys():
			sort = Sort.new(json_data[classe][nom_sort])
			sorts[nom_sort] = sort


func charger_equipements():
	var file = FileAccess.open("res://Jeu/equipements.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	var equipement: Equipement
	
	for categorie in json_data.keys():
		for nom_equipement in json_data[categorie].keys():
			equipement = Equipement.new(json_data[categorie][nom_equipement], categorie)
			equipements[nom_equipement] = equipement


func charger_equipes():
	var file_access = FileAccess.open("user://equipes.save", FileAccess.READ)
	if not file_access:
		equipes = []
		for i in range(20):
			equipes.append(Equipe.new())
	else:
		equipes = file_access.get_var(true)
	equipe_actuelle = equipes[0]


func sauver_equipes():
	var file_access = FileAccess.open("user://equipes.save", FileAccess.WRITE)
	file_access.store_var(equipes, true)
