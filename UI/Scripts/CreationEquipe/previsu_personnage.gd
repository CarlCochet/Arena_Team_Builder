extends Node2D
class_name PrevisuPersonnage

@onready var cape: Sprite2D = $Cape
@onready var classe: Sprite2D = $Classe
@onready var cape2: Sprite2D = $Cape2
@onready var coiffe: Sprite2D = $Coiffe
@onready var coiffe2: Sprite2D = $Coiffe2

var nom_classe: String
var classe_texture: Texture2D
var classe_texture2: Texture2D


func update(personnage: Personnage, orientation: int):
	if personnage.classe and personnage.classe != nom_classe:
		nom_classe = personnage.classe
		classe_texture = load("res://Classes/" + nom_classe + "/" + nom_classe.to_lower() + ".png")
		classe_texture2 = load("res://Classes/" + nom_classe + "/" + nom_classe.to_lower() + "2.png")
	if not personnage.classe:
		nom_classe = personnage.classe
		classe_texture = GlobalData.empty_classe
		classe_texture2 = GlobalData.empty_classe

	if personnage.equipements["Capes"]:
		cape.texture = GlobalData.equipements[personnage.equipements["Capes"]].visuel1
	else:
		cape.texture = GlobalData.empty_classe
	if personnage.equipements["Capes"]:
		cape2.texture = GlobalData.equipements[personnage.equipements["Capes"]].visuel2
	else:
		cape2.texture = GlobalData.empty_classe
	if personnage.classe:
		classe.texture = classe_texture
	else:
		classe.texture = GlobalData.empty_classe
	if personnage.equipements["Coiffes"]:
		coiffe.texture = GlobalData.equipements[personnage.equipements["Coiffes"]].visuel1
	else:
		coiffe.texture = GlobalData.empty_classe
	if personnage.equipements["Coiffes"]:
		coiffe2.texture = GlobalData.equipements[personnage.equipements["Coiffes"]].visuel2
	else:
		coiffe2.texture = GlobalData.empty_classe
	
	update_orientation(orientation)


func update_orientation(orientation: int):
	if orientation == 0 or orientation == 3:
		coiffe2.visible = true
		cape2.visible = true
		coiffe.visible = false
		cape.visible = false
		classe.texture = classe_texture2
	else:
		coiffe2.visible = false
		cape2.visible = false
		coiffe.visible = true
		cape.visible = true
		classe.texture = classe_texture
	
	if orientation == 0 or orientation == 2:
		scale = Vector2(-1, 1)
	else:
		scale = Vector2(1, 1)
		


func from_previsu(previsu: PrevisuPersonnage):
	cape.texture = previsu.cape.texture
	classe.texture = previsu.classe.texture
	coiffe.texture = previsu.coiffe.texture


func setup_classe(invocation: String):
	classe_texture = load(
		"res://Classes/Invocations/" + invocation.to_lower() + ".png"
	)
	classe_texture2 = classe_texture
	classe.texture = classe_texture


func invisible():
	modulate = Color(1, 1, 1, 0.5)


func visible():
	modulate = Color(1, 1, 1, 1)
