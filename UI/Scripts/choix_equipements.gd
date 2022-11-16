extends Control


var categorie_lookup: Dictionary

@onready var personnage: TextureRect = $Personnage
@onready var grid_equipements: GridContainer = $ScrollContainer/Cartes
@onready var grid_logos: GridContainer = $GridLogos
@onready var affichage_budget: TextureRect = $AffichageBudget
@onready var stats_primaires: TextureRect = $StatsPrimaires
@onready var stats_secondaires: TextureRect = $StatsSecondaires

func _ready():
	categorie_lookup = {
		"Armes": "ARME",
		"Coiffes": "COIFFE",
		"Capes": "CAPE",
		"Dofus": "DOFUS",
		"Familiers": "FAMILIER"
	}
	personnage.texture = load(
		"res://Classes/" + GlobalData.get_perso_actuel().classe + 
		"/" + GlobalData.get_perso_actuel().classe.to_lower() + ".png"
	)
	update_cartes("Armes")
	update_affichage()
	update_logos()


func update_affichage():
	affichage_budget.update()
	stats_primaires.update(GlobalData.perso_actuel)
	stats_secondaires.update(GlobalData.perso_actuel)


func update_cartes(categorie):
	for equipement in grid_equipements.get_children():
		equipement.queue_free()
	var base_path: String = "res://Equipements/" + categorie
	for nom_equipement in GlobalData.equipements_lookup[categorie_lookup[categorie]]:
		var bouton = TextureButton.new()
		bouton.texture_normal = load(base_path + "/" + nom_equipement + ".png")
		bouton.connect("pressed", _on_card_clicked.bind(nom_equipement, categorie))
		grid_equipements.add_child(bouton)


func update_logos():
	for logo in grid_logos.get_children():
		logo.texture = load("res://UI/Logos/Equipements/empty.png")
	for equipement in GlobalData.get_perso_actuel().equipements:
		if GlobalData.get_perso_actuel().equipements[equipement]:
			var path = "res://UI/Logos/Equipements/" + equipement + "/" + GlobalData.get_perso_actuel().equipements[equipement] + ".png"
			grid_logos.get_node(equipement).texture = load(path)


func _on_card_clicked(nom_equipement, categorie):
	if GlobalData.get_perso_actuel().equipements[categorie] == nom_equipement:
		GlobalData.get_perso_actuel().equipements[categorie] = ""
	else:
		GlobalData.get_perso_actuel().equipements[categorie] = nom_equipement
	GlobalData.get_perso_actuel().calcul_stats()
	update_affichage()
	update_logos()


func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and not event.echo:
		get_tree().change_scene_to_file("res://UI/choix_classe.tscn")
	if event is InputEventKey and event.keycode == KEY_ENTER and not event.echo:
		get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_retour_pressed():
	get_tree().change_scene_to_file("res://UI/choix_classe.tscn")


func _on_sorts_pressed():
	get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")


func _on_valider_pressed():
	GlobalData.sauver_equipes()
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_arme_pressed():
	update_cartes("Armes")
	update_logos()


func _on_familier_pressed():
	update_cartes("Familiers")
	update_logos()


func _on_coiffe_pressed():
	update_cartes("Coiffes")
	update_logos()


func _on_cape_pressed():
	update_cartes("Capes")
	update_logos()


func _on_dofus_pressed():
	update_cartes("Dofus")
	update_logos()
