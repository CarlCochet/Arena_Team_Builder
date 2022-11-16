extends Control


@onready var personnage: TextureRect = $Personnage
@onready var grid_sorts: GridContainer = $GridSortsCartes
@onready var grid_logos: GridContainer = $GridSortsLogos
@onready var affichage_budget: TextureRect = $AffichageBudget
@onready var stats_primaires: TextureRect = $StatsPrimaires
@onready var stats_secondaires: TextureRect = $StatsSecondaires


func _ready():
	if GlobalData.get_perso_actuel().classe:
		personnage.texture = load(
			"res://Classes/" + GlobalData.get_perso_actuel().classe + 
			"/" + GlobalData.get_perso_actuel().classe.to_lower() + ".png"
		)
	update_cartes()
	update_affichage()
	update_logos()


func update_affichage():
	affichage_budget.update()
	stats_primaires.update(GlobalData.perso_actuel)
	stats_secondaires.update(GlobalData.perso_actuel)


func update_cartes():
	var base_path: String = "res://Classes/" + GlobalData.get_perso_actuel().classe + "/Sorts/"
	for nom_sort in GlobalData.sorts_lookup[GlobalData.get_perso_actuel().classe]:
		var bouton = TextureButton.new()
		bouton.texture_normal = load(base_path + nom_sort + ".png")
		bouton.connect("pressed", _on_card_clicked.bind(nom_sort))
		grid_sorts.add_child(bouton)


func update_logos():
	for logo in grid_logos.get_children():
		logo.queue_free()
	for sort in GlobalData.get_perso_actuel().sorts:
		var bouton = TextureButton.new()
		bouton.texture_normal = load(
			"res://UI/Logos/Spells/" + GlobalData.get_perso_actuel().classe + 
			"/" + sort + ".png"
		)
		bouton.connect("pressed", _on_logo_clicked.bind(sort))
		grid_logos.add_child(bouton)


func _on_card_clicked(nom_sort):
	if len(GlobalData.get_perso_actuel().sorts) < 6 and nom_sort not in GlobalData.get_perso_actuel().sorts:
		GlobalData.get_perso_actuel().sorts.append(nom_sort)
	GlobalData.get_perso_actuel().calcul_stats()
	update_affichage()
	update_logos()


func _on_logo_clicked(sort):
	GlobalData.get_perso_actuel().sorts.erase(sort)
	GlobalData.get_perso_actuel().calcul_stats()
	update_affichage()
	update_logos()


func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and not event.echo:
		get_tree().change_scene_to_file("res://UI/choix_classe.tscn")
	if event is InputEventKey and event.keycode == KEY_ENTER and not event.echo:
		get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_equipements_pressed():
	get_tree().change_scene_to_file("res://UI/choix_equipements.tscn")


func _on_retour_pressed():
	get_tree().change_scene_to_file("res://UI/choix_classe.tscn")


func _on_valider_pressed():
	GlobalData.sauver_equipes()
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")
