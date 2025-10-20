extends Control
class_name ChoixClasse


var classe_initiale: int
var classe_selected: int

@onready var personnage: TextureRect = $Personnage
@onready var classes: Array = $Classes.get_children()
@onready var nom: TextEdit = $ChoixNom/TextEdit


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
	nom.text = GlobalData.get_perso_actuel().nom
	classe_initiale = GlobalData.classes.find(GlobalData.get_perso_actuel().classe)
	classe_selected = classe_initiale
	classes[classe_initiale].button_pressed = true


func _on_class_pressed(id: int):
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


func _input(event: InputEvent):
	if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
		_on_fermer_pressed()
	if Input.is_key_pressed(KEY_ENTER) and event is InputEventKey and not event.echo:
		_on_valider_pressed()


func _on_fermer_pressed():
	GlobalData.equipe_actuelle.sort_ini()
	GlobalData.sauver_equipes()
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_valider_pressed() -> void:
	if nom.text.is_empty():
		return
	if classe_selected != classe_initiale:
		var nouveau_personnage = Personnage.new()
		nouveau_personnage.classe = GlobalData.classes[classe_selected]
		nouveau_personnage.calcul_stats()
		GlobalData.set_perso_actuel(nouveau_personnage)
	GlobalData.get_perso_actuel().nom = nom.text
	get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")
