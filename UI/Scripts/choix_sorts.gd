extends Control


var grid_sorts
var grid_logos


func _ready():
	get_node("Personnage").texture = load(
		"res://Classes/" + GlobalData.get_perso_actuel().classe + 
		"/" + GlobalData.get_perso_actuel().classe.to_lower() + ".png"
	)
	grid_sorts = get_node("GridSortsCartes")
	grid_logos = get_node("GridSortsLogos")
	update_cartes()
	update_affichage()
	update_logos()


func update_affichage():
	get_node("AffichageBudget").update()
	get_node("StatsPrimaires").update(GlobalData.perso_actuel)
	get_node("StatsSecondaires").update(GlobalData.perso_actuel)


func update_cartes():
	var base_path: String = "res://Classes/" + GlobalData.get_perso_actuel().classe + "/Sorts"
	var directory = DirAccess.open(base_path)
	if directory:
		directory.list_dir_begin()
		while true:
			var file = directory.get_next()
			if file == "":
				break
			var nom_sort = file.split(".")[0]
			if file.split(".")[-1] == "png":
				var bouton = TextureButton.new()
				bouton.texture_normal = load(base_path + "/" + file)
				bouton.connect("pressed", _on_card_clicked.bind(nom_sort))
				grid_sorts.add_child(bouton)
		directory.list_dir_end()


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
	GlobalData.get_perso_actuel().sorts.append(nom_sort)
	update_logos()


func _on_logo_clicked(sort):
	GlobalData.get_perso_actuel().sorts.erase(sort)
	update_logos()


func _on_equipements_pressed():
	get_tree().change_scene_to_file("res://UI/choix_equipements.tscn")


func _on_retour_pressed():
	get_tree().change_scene_to_file("res://UI/choix_classe.tscn")
