extends Control


var previsu = preload("res://UI/Displays/Scenes/previsu_equipe.tscn")
var equipes_grid
var equipes: Array
var affichage_personnages


func _ready():
	equipes_grid = get_node("ScrollContainer/Equipes")
	affichage_personnages = get_node("AffichageEquipe")
	equipes = []
	GlobalData.charger_equipes()
	generer_affichage()


func generer_affichage():
	for equipe in GlobalData.equipes:
		var previsu_equipe = previsu.instantiate()
		previsu_equipe.connect("pressed", previsu_pressed.bind(previsu_equipe))
		equipes.append(previsu_equipe)
		equipes_grid.add_child(previsu_equipe)
		affichage_personnages.update_affichage()


func previsu_pressed(button_reference):
	for i in range(len(equipes)):
		if equipes[i].name != button_reference.name:
			equipes[i].button_pressed = false
		else:
			GlobalData.equipe_actuelle = GlobalData.equipes[i]


func _on_supprimer_pressed():
	pass


func _on_editer_pressed():
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_creer_pressed():
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")
