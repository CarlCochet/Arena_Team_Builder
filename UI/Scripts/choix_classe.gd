extends Control


var classe_initiale: int
var classe_selected: int

@onready var personnage: TextureRect = $Personnage
@onready var classes: Array = $Classes.get_children()


func _ready():
	for i in range(len(classes)):
		classes[i].connect("pressed", _on_class_pressed.bind(i))
	if GlobalData.get_perso_actuel().classe.is_empty():
		GlobalData.get_perso_actuel().classe = GlobalData.classes[0]
		GlobalData.get_perso_actuel().calcul_stats()
	personnage.texture = load(
		"res://Classes/" + GlobalData.get_perso_actuel().classe + 
		"/" + GlobalData.get_perso_actuel().classe.to_lower() + ".png"
	)
	classe_initiale = GlobalData.classes.find(GlobalData.get_perso_actuel().classe)
	classe_selected = classe_initiale
	classes[classe_initiale].button_pressed = true


func _on_class_pressed(id):
	classe_selected = id
	for i in range(len(classes)):
		if i != id:
			classes[i].button_pressed = false
		else:
			classes[i].button_pressed = true
			personnage.texture = load(
				"res://Classes/" + GlobalData.classes[i] + 
				"/" + GlobalData.classes[i].to_lower() + ".png"
			)


func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and not event.echo:
		get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")
	if event is InputEventKey and event.keycode == KEY_ENTER and not event.echo:
		get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")


func _on_fermer_pressed():
	GlobalData.equipe_actuelle.sort_ini()
	GlobalData.sauver_equipes()
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_valider_pressed():
	if classe_selected != classe_initiale:
		var nouveau_personnage = Personnage.new()
		nouveau_personnage.classe = GlobalData.classes[classe_selected]
		nouveau_personnage.calcul_stats()
		GlobalData.set_perso_actuel(nouveau_personnage)
	get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")
