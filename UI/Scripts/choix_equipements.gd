extends Control


var grid_equipements
var grid_logos


func _ready():
	get_node("Personnage").texture = load(
		"res://Classes/" + GlobalData.get_perso_actuel().classe + 
		"/" + GlobalData.get_perso_actuel().classe.to_lower() + ".png"
	)
	grid_equipements = get_node("ScrollContainer/Cartes")
	grid_logos = get_node("GridLogos")
	update_cartes("Armes")
	update_affichage()
	update_logos()


func update_affichage():
	get_node("AffichageBudget").update()
	get_node("StatsPrimaires").update(GlobalData.perso_actuel)
	get_node("StatsSecondaires").update(GlobalData.perso_actuel)


func update_cartes(categorie):
	for equipement in grid_equipements.get_children():
		equipement.queue_free()
	var base_path: String = "res://Equipements/" + categorie
	var directory = DirAccess.open(base_path)
	if directory:
		directory.list_dir_begin()
		while true:
			var file = directory.get_next()
			if file == "":
				break
			var nom_equipement = file.split(".")[0]
			if file.split(".")[-1] == "png":
				var bouton = TextureButton.new()
				bouton.texture_normal = load(base_path + "/" + file)
				bouton.connect("pressed", _on_card_clicked.bind(nom_equipement, categorie))
				grid_equipements.add_child(bouton)
		directory.list_dir_end()


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


func _on_retour_pressed():
	get_tree().change_scene_to_file("res://UI/choix_classe.tscn")


func _on_sorts_pressed():
	get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")


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
