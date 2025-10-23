extends Control
class_name ChoixEquipements


var categorie_lookup: Dictionary

@onready var previsu_personnage: PrevisuPersonnage = $PrevisuPersonnage
@onready var grid_equipements: GridContainer = $ScrollContainer/Cartes
@onready var grid_logos: GridContainer = $GridLogos
@onready var affichage_budget: AffichageBudget = $AffichageBudget
@onready var stats_primaires: AffichageStatsPrimaires = $StatsPrimaires
@onready var stats_secondaires: AffichageStatsSecondaires = $StatsSecondaires


func _ready():
	categorie_lookup = {
		"Armes": "ARME",
		"Coiffes": "COIFFE",
		"Capes": "CAPE",
		"Dofus": "DOFUS",
		"Familiers": "FAMILIER"
	}
	update_personnage()
	update_cartes("Armes")
	update_affichage()
	update_logos()


func update_personnage():
	previsu_personnage.update(GlobalData.get_perso_actuel(), 1)


func update_affichage():
	affichage_budget.update()
	stats_primaires.update(GlobalData.perso_actuel)
	stats_secondaires.update(GlobalData.perso_actuel)


func update_cartes(categorie: String):
	for equipement in grid_equipements.get_children():
		equipement.queue_free()
	for nom_equipement in GlobalData.equipements_lookup[categorie_lookup[categorie]]:
		var bouton = TextureButton.new()
		bouton.texture_normal = GlobalData.equipements[nom_equipement].carte
		bouton.connect("pressed", _on_card_clicked.bind(nom_equipement, categorie))
		grid_equipements.add_child(bouton)


func update_logos():
	for logo in grid_logos.get_children():
		logo.texture = GlobalData.empty_equipement_icone
	
	var equipement_perso: Dictionary = GlobalData.get_perso_actuel().equipements
	for equipement in equipement_perso.keys():
		if equipement_perso[equipement]:
			grid_logos.get_node(equipement).texture = GlobalData.equipements[equipement_perso[equipement]].icone


func _on_card_clicked(nom_equipement: String, categorie: String):
	if GlobalData.get_perso_actuel().equipements[categorie] == nom_equipement:
		GlobalData.get_perso_actuel().equipements[categorie] = ""
	else:
		GlobalData.get_perso_actuel().equipements[categorie] = nom_equipement
	GlobalData.get_perso_actuel().calcul_stats()
	update_personnage()
	update_affichage()
	update_logos()


func _input(event: InputEvent):
	if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
		_on_retour_pressed()
	if Input.is_key_pressed(KEY_ENTER) and event is InputEventKey and not event.echo:
		_on_valider_pressed()


func _on_retour_pressed():
	get_tree().change_scene_to_file("res://UI/choix_classe.tscn")


func _on_sorts_pressed():
	get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")


func _on_valider_pressed():
	GlobalData.equipe_actuelle.sort_ini()
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
