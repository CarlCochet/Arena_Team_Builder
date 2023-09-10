extends Node2D


enum TypeZone {
	CERCLE = 0, 
	LIGNE = 1, 
	BATON = 2, 
	CARRE = 3, 
	CROIX = 4, 
	MARTEAU = 5
}

enum Cible {
	LIBRE = 0, 
	MOI = 1, 
	VIDE = 2, 
	ALLIES = 3, 
	ENNEMIS = 4, 
	INVOCATIONS = 5, 
	INVOCATIONS_ALLIEES = 6, 
	INVOCATIONS_ENNEMIES = 7, 
	TOUT = 8, 
	CLASSE = 9, 
	PERSONNAGES = 10, 
	PERSONNAGES_ALLIES = 11, 
	PERSONNAGES_ENNEMIS = 12,
	MA_LANCE = 13
}

enum TypeLDV {
	CERCLE = 0, 
	LIGNE = 1, 
	DIAGONAL = 2
}

enum Invocations {
	BOUFTOU = 0,
	CRAQUELEUR = 1,
	PRESPIC = 2,
	TOFU = 3,
	ARBRE = 4,
	BLOQUEUSE = 5,
	FOLLE = 6,
	SACRIFIEE = 7,
	DOUBLE = 8,
	CADRAN_DE_XELOR = 9,
	BOMBE_A_EAU = 10,
	BOMBE_INCENDIAIRE = 11,
	HARPONNEUSE = 12,
	GARDIENNE = 13,
	TACTIRELLE = 14,
	GARDIEN_ELEMENTAIRE = 15,
	ROQUET = 16,
	LANCE_DU_FORGELANCE = 17
}

var classes = [
	"Cra", 
	"Eca", 
	"Eni", 
	"Enu", 
	"Feca", 
	"Iop", 
	"Osa", 
	"Panda", 
	"Sacrieur", 
	"Sadida", 
	"Sram", 
	"Xelor", 
	"Roublard", 
	"Zobal", 
	"Steamer", 
	"Elio", 
	"Hupper", 
	"Ouginak", 
	"Forgelance",
]
var classes_mapping = {
	"Cra": "Cra",
	"Eca": "Ecaflip",
	"Eni": "Eniripsa",
	"Enu": "Enutrof",
	"Feca": "Feca",
	"Iop": "Iop",
	"Osa": "Osamodas",
	"Panda": "Pandawa",
	"Sacrieur": "Sacrieur",
	"Sadida": "Sadida",
	"Sram": "Sram",
	"Xelor": "Xelor",
	"Roublard": "Roublard",
	"Zobal": "Zobal",
	"Steamer": "Steamer", 
	"Elio": "Eliotrope", 
	"Hupper": "Huppermage", 
	"Ouginak": "Ouginak", 
	"Forgelance": "Forgelance",
}

var sorts: Dictionary
var equipements: Dictionary
var stats_classes: Dictionary
var equipes: Array[Equipe]
var sorts_lookup: Dictionary
var equipements_lookup: Dictionary
var cartes_combat: Dictionary

var equipe_actuelle: Equipe
var equipe_test: Equipe
var perso_actuel: int
var map_actuelle: String
var mort_subite_active: bool
var is_multijoueur: bool
var rng: RandomNumberGenerator
var regles_multi: Dictionary = {
	"classes": [true, true, true, true, true, true, true, true, true, true, true, true, true, false, false, false, false, false, false],
	"budget_max": 6000, 
	"persos_max": 6, 
	"debut_ms": 15
}


func _ready():
	map_actuelle = "map_2"
	rng = RandomNumberGenerator.new()
	rng.randomize()
	charger_stats_classes()
	charger_sorts()
	charger_equipements()
	charger_equipes()
	charger_cartes_combat()


func charger_cartes_combat():
	var file: FileAccess = FileAccess.open("res://Jeu/cartes_combat.json", FileAccess.READ)
	cartes_combat = JSON.parse_string(file.get_as_text())


func charger_sorts():
	var file: FileAccess = FileAccess.open("res://Jeu/sorts.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	var sort: Sort
	
	for classe in json_data.keys():
		if classe not in sorts_lookup.keys():
			sorts_lookup[classe] = []
		for nom_sort in json_data[classe].keys():
			sort = Sort.new()
			sort.from_json(json_data[classe][nom_sort])
			sort.nom = nom_sort
			sorts[nom_sort] = sort
			sorts_lookup[classe].append(nom_sort)


func charger_equipements():
	var file: FileAccess = FileAccess.open("res://Jeu/equipements.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	var equipement: Equipement
	
	for categorie in json_data.keys():
		if categorie not in equipements_lookup.keys():
			equipements_lookup[categorie] = []
		for nom_equipement in json_data[categorie].keys():
			equipement = Equipement.new().from_json(json_data[categorie][nom_equipement], categorie)
			equipements[nom_equipement] = equipement
			equipements_lookup[categorie].append(nom_equipement)


func charger_stats_classes():
	var file: FileAccess = FileAccess.open("res://Jeu/stats_classes.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	var stats: Stats
	
	for classe in json_data.keys():
		stats = Stats.new().from_json(json_data[classe])
		stats_classes[classe] = stats


func charger_equipes():
	var file_access: FileAccess = FileAccess.open("user://save.json", FileAccess.READ)
	if not file_access:
		equipes = [Equipe.new()]
	else:
		var json_content = JSON.parse_string(file_access.get_as_text())
		equipes = []
		for equipe in json_content:
			equipes.append(Equipe.new().from_json(equipe).sort_ini())
	equipe_actuelle = equipes[0]
	equipe_test = equipes[0]
	sauver_equipes()


func sauver_equipes():
	var equipes_json = []
	for equipe in GlobalData.equipes:
		equipes_json.append(equipe.to_json())
	var json_string = JSON.stringify(equipes_json)
	var file_access = FileAccess.open("user://save.json", FileAccess.WRITE)
	file_access.store_string(json_string)


func get_perso_actuel() -> Personnage:
	return equipe_actuelle.personnages[perso_actuel]


func set_perso_actuel(personnage: Personnage):
	equipe_actuelle.personnages[perso_actuel] = personnage
