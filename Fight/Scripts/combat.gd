extends Node2D
class_name Combat


var scene_combattant = preload("res://Fight/combattant.tscn")
var combattants: Array
var etat: int

@onready var sorts: Control = $Sorts
@onready var timeline: Control = $Timeline
@onready var tilemap: TileMap = $TileMap


func _ready():
	etat = 0
	creer_personnages()


func creer_personnages():
	var x = 100
	for personnage in GlobalData.equipe_actuelle.personnages:
		if not personnage.classe.is_empty():
			print(personnage.classe)
			var nouveau_combattant = scene_combattant.instantiate()
			nouveau_combattant.position.x = x
			nouveau_combattant.position.y = 200
			x += 100
			combattants.append(nouveau_combattant.from_personnage(personnage, 0))
			add_child(nouveau_combattant)
			nouveau_combattant.update_visuel()
	
	x = 100
	for personnage in GlobalData.equipe_test.personnages:
		if not personnage.classe.is_empty():
			print(personnage.classe)
			var nouveau_combattant = scene_combattant.instantiate()
			nouveau_combattant.position.x = x
			nouveau_combattant.position.y = 400
			x += 100
			combattants.append(nouveau_combattant.from_personnage(personnage, 1))
			add_child(nouveau_combattant)
			nouveau_combattant.update_visuel()
	
	combattants.sort_custom(func(a, b): return a.stats.initiative > b.stats.initiative)


func _process(_delta):
	pass


func _input(event):
	pass
