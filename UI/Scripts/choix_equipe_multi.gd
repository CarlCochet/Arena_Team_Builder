extends Control


var previsu = preload("res://UI/Displays/Scenes/previsu_equipe.tscn")
var equipes: Array
var equipe_selectionnee: int
var adversaire_pret: bool

@onready var equipes_grid: GridContainer = $ScrollContainer/Equipes
@onready var affichage_personnages: Control = $AffichageEquipe


func _ready():
	equipes = []
	equipe_selectionnee = 0
	adversaire_pret = false
	generer_affichage()


func generer_affichage():
	for i in range(len(GlobalData.equipes)):
		var previsu_equipe = previsu.instantiate()
		previsu_equipe.signal_id = i
		previsu_equipe.connect("pressed", previsu_pressed.bind(i))
		equipes.append(previsu_equipe)
		equipes_grid.add_child(previsu_equipe)
		previsu_equipe.update(i)
	equipes[equipe_selectionnee].button_pressed = true
	if Client.is_host:
		affichage_personnages.update(GlobalData.equipe_actuelle)
	else:
		affichage_personnages.update(GlobalData.equipe_test)


func previsu_pressed(id):
	equipe_selectionnee = id
	for i in range(len(equipes)):
		if i != id:
			equipes[i].button_pressed = false
		else:
			equipes[i].button_pressed = true
			if Client.is_host:
				GlobalData.equipe_actuelle = GlobalData.equipes[i]
				affichage_personnages.update(GlobalData.equipe_actuelle)
			else:
				GlobalData.equipe_test = GlobalData.equipes[i]
				affichage_personnages.update(GlobalData.equipe_test)


func _on_retour_pressed():
	Client.reset()
	get_tree().change_scene_to_file("res://UI/multijoueur_setup.tscn")


func _on_valider_pressed():
	pass # Replace with function body.
