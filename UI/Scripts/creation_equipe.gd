extends Control


var equipe: Equipe
var stats_primaires
var stats_secondaires
var boutons_recruter


func _ready():
	boutons_recruter = get_node("GridRecruter").get_children()
	for i in range(len(boutons_recruter)):
		if i < 6:
			boutons_recruter[i].connect("pressed", _on_recruter_pressed.bind(i))
		else:
			boutons_recruter[i].connect("pressed", _on_supprimer_pressed.bind(i))
	stats_primaires = get_node("GridStatsPrimaires").get_children()
	stats_secondaires = get_node("GridStatsSecondaires").get_children()
	update_affichage()


func update_affichage():
	get_node("AffichageEquipe").update()
	for i in range(len(GlobalData.equipe_actuelle.personnages)):
		stats_primaires[i].update(i)
		stats_secondaires[i].update(i)
	get_node("AffichageBudget").update()


func _on_recruter_pressed(id):
	GlobalData.perso_actuel = id
	get_tree().change_scene_to_file("res://UI/choix_classe.tscn")


func _on_supprimer_pressed(id):
	GlobalData.equipe_actuelle.personnages[id - 6] = Personnage.new()
	update_affichage()


func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and not event.echo:
		GlobalData.sauver_equipes()
		get_tree().change_scene_to_file("res://UI/gestion_equipes.tscn")


func _on_fermer_pressed():
	GlobalData.sauver_equipes()
	get_tree().change_scene_to_file("res://UI/gestion_equipes.tscn")
