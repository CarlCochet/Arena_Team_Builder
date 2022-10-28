extends Control


var classes: Array


func _ready():
	classes = get_node("Classes").get_children()
	for i in range(len(classes)):
		classes[i].connect("pressed", _on_class_pressed.bind(i))
	if GlobalData.get_perso_actuel().classe == "":
		GlobalData.get_perso_actuel().classe = GlobalData.classes[0]
		GlobalData.get_perso_actuel().calcul_stats()
	get_node("Personnage").texture = load(
		"res://Classes/" + GlobalData.get_perso_actuel().classe + 
		"/" + GlobalData.get_perso_actuel().classe.to_lower() + ".png"
	)
	var index_classe = GlobalData.classes.find(GlobalData.get_perso_actuel().classe)
	classes[index_classe].button_pressed = true


func _on_class_pressed(id):
	for i in range(len(classes)):
		if i != id:
			classes[i].button_pressed = false
		else:
			classes[i].button_pressed = true
			if GlobalData.get_perso_actuel().classe != GlobalData.classes[i]:
				var nouveau_personnage = Personnage.new()
				nouveau_personnage.classe = GlobalData.classes[i]
				nouveau_personnage.calcul_stats()
				GlobalData.set_perso_actuel(nouveau_personnage)
				get_node("Personnage").texture = load(
					"res://Classes/" + GlobalData.get_perso_actuel().classe + 
					"/" + GlobalData.get_perso_actuel().classe.to_lower() + ".png"
				)


func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and not event.echo:
		get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")
	if event is InputEventKey and event.keycode == KEY_ENTER and not event.echo:
		get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")


func _on_fermer_pressed():
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_valider_pressed():
	get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")
