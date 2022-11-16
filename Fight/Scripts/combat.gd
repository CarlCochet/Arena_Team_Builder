extends Node2D


var scene_personnage = preload("res://Fight/personnage.tscn")
var personnages: Array
var sorts
var timeline
var tilemap


func _ready():
	sorts = get_node("Sorts")
	timeline = get_node("Timeline")
	tilemap = get_node("TileMap")
	creer_personnages()


func creer_personnages():
	var x = 100
	for personnage in GlobalData.equipe_actuelle.personnages:
		var nouveau_personnage = Personnage.new()
		nouveau_personnage.position.x = x
		nouveau_personnage.position.y = 200
		x += 100
		personnages.append(nouveau_personnage.copy(personnage))
		add_child(nouveau_personnage)
	
	x = 100
	for personnage in GlobalData.equipe_test.personnages:
		var nouveau_personnage = Personnage.new()
		nouveau_personnage.equipe = 1
		nouveau_personnage.position.x = x
		nouveau_personnage.position.y = 400
		x += 100
		personnages.append(nouveau_personnage.copy(personnage))
		add_child(nouveau_personnage)
	
	personnages.sort_custom(func(a, b): return a.stats.initiative > b.stats.initiative)


func _process(_delta):
	pass


func _input(event):
	pass
