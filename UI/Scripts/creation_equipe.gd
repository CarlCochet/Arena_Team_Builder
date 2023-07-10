extends Control


var equipe: Equipe

@onready var boutons_recruter: Array = $GridRecruter.get_children()
@onready var affichage_equipe: Control = $AffichageEquipe
@onready var stats_primaires: Array = $GridStatsPrimaires.get_children()
@onready var stats_secondaires: Array = $GridStatsSecondaires.get_children()
@onready var affichage_budget: TextureRect = $AffichageBudget


func _ready():
	for i in range(len(boutons_recruter)):
		if i < 6:
			boutons_recruter[i].connect("pressed", _on_recruter_pressed.bind(i))
		else:
			boutons_recruter[i].connect("pressed", _on_supprimer_pressed.bind(i))
	update_affichage()


func update_affichage():
	affichage_equipe.update(GlobalData.equipe_actuelle)
	for i in range(len(GlobalData.equipe_actuelle.personnages)):
		stats_primaires[i].update(i)
		stats_secondaires[i].update(i)
	affichage_budget.update()


func _on_recruter_pressed(id):
	GlobalData.perso_actuel = id
	get_tree().change_scene_to_file("res://UI/choix_classe.tscn")


func _on_supprimer_pressed(id):
	GlobalData.equipe_actuelle.personnages[id - 6] = Personnage.new()
	GlobalData.equipe_actuelle.sort_ini()
	update_affichage()


func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
		_on_fermer_pressed()
	if Input.is_key_pressed(KEY_ENTER) and event is InputEventKey and not event.echo:
		_on_tester_pressed()


func _on_fermer_pressed():
	GlobalData.sauver_equipes()
	get_tree().change_scene_to_file("res://UI/gestion_equipes.tscn")


func _on_tester_pressed():
	get_tree().change_scene_to_file("res://UI/choix_ennemis.tscn")
