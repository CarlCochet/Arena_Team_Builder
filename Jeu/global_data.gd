extends Node


enum TypeZone {CERCLE, LIGNE, BATON, CARRE, CROIX, MARTEAU}
enum Cible {LIBRE, MOI, VIDE, ALLIES, ENNEMIS, INVOCATIONS, INVOCATIONS_ALLIEES, INVOCATIONS_ENNEMIES}
enum TypeLDV {CERCLE, LIGNE, DIAGONAL}

var classes = ["Cra", "Eca", "Eni", "Enu", "Feca", "Iop", "Osa", "Panda", "Sacrieur", "Sadida", "Sram", "Xelor"]

var sorts: Dictionary
var equipements: Dictionary
var stats_classes: Dictionary
var equipes: Array

var equipe_actuelle: Equipe
var perso_actuel: int


func _ready():
	charger_stats_classes()
	charger_sorts()
	charger_equipements()
	charger_equipes()


func charger_sorts():
	var file = FileAccess.open("res://Jeu/sorts.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	var sort: Sort
	
	for classe in json_data.keys():
		for nom_sort in json_data[classe].keys():
			sort = Sort.new()
			sort.from_json(json_data[classe][nom_sort])
			sorts[nom_sort] = sort


func charger_equipements():
	var file = FileAccess.open("res://Jeu/equipements.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	var equipement: Equipement
	
	for categorie in json_data.keys():
		for nom_equipement in json_data[categorie].keys():
			equipement = Equipement.new().from_json(json_data[categorie][nom_equipement], categorie)
			equipements[nom_equipement] = equipement


func charger_stats_classes():
	var file = FileAccess.open("res://Jeu/stats_classes.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	var stats: Stats
	
	for classe in json_data.keys():
		stats = Stats.new().from_json(json_data[classe])
		stats_classes[classe] = stats


func charger_equipes():
	var file_access = FileAccess.open("user://save.json", FileAccess.READ)
	if not file_access:
		equipes = []
		for i in range(10):
			equipes.append(Equipe.new())
	else:
		var json_content = JSON.parse_string(file_access.get_as_text())
		equipes = []
		for equipe in json_content:
			equipes.append(Equipe.new().from_json(equipe))
	equipe_actuelle = equipes[0]
	sauver_equipes()


func sauver_equipes():
	var equipes_json = []
	for equipe in GlobalData.equipes:
		equipes_json.append(equipe.to_json())
	var json_string = JSON.stringify(equipes_json)
	var file_access = FileAccess.open("user://save.json", FileAccess.WRITE)
	file_access.store_string(json_string)


func get_perso_actuel():
	return equipe_actuelle.personnages[perso_actuel]


func set_perso_actuel(personnage):
	equipe_actuelle.personnages[perso_actuel] = personnage
