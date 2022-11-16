extends Control


var previsu = preload("res://UI/Displays/Scenes/previsu_equipe.tscn")
var equipes_grid
var equipes: Array
var affichage_personnages
var equipe_selectionnee: int


func _ready():
	equipes_grid = get_node("ScrollContainer/Equipes")
	affichage_personnages = get_node("AffichageEquipe")
	equipes = []
	generer_affichage()


func generer_affichage():
	for i in range(len(GlobalData.equipes)):
		var previsu_equipe = previsu.instantiate()
		previsu_equipe.signal_id = i
		previsu_equipe.connect("pressed", previsu_pressed.bind(i))
		equipes.append(previsu_equipe)
		equipes_grid.add_child(previsu_equipe)
		previsu_equipe.update(i)
	equipes[0].button_pressed = true
	affichage_personnages.update(GlobalData.equipe_test)


func previsu_pressed(id):
	equipe_selectionnee = id
	for i in range(len(equipes)):
		if i != id:
			equipes[i].button_pressed = false
		else:
			equipes[i].button_pressed = true
			GlobalData.equipe_test = GlobalData.equipes[i]
			affichage_personnages.update(GlobalData.equipe_test)


func _on_retour_pressed():
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_valider_pressed():
	get_tree().change_scene_to_file("res://Fight/combat.tscn")
