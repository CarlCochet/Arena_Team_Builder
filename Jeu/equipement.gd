extends Node2D
class_name Equipement


enum Categorie {VIDE, ARME, FAMILIER, COIFFE, CAPE, DOFUS}

var categorie: Categorie
var stats: Stats
var pa: int
var po: Vector2 
var type_zone: Enums.TypeZone
var taille_zone: Vector2
var po_modifiable: int
var cible: Enums.Cible
var particules_cible: String
var particules_retour: String
var effets: Dictionary
var icone: Texture2D
var carte: Texture2D
var visuel1: Texture2D
var visuel2: Texture2D


func _init():
	categorie = Categorie.VIDE
	stats = Stats.new()
	pa = 0
	po = Vector2(0, 0)
	type_zone = Enums.TypeZone.CERCLE
	taille_zone = Vector2(0, 0)
	po_modifiable = 1
	cible = Enums.Cible.LIBRE
	particules_cible = ""
	particules_cible = ""
	effets = {}


func from_json(data: Dictionary, json_categorie: String, nom: String) -> Equipement:
	categorie = Categorie.keys().find(json_categorie) as Categorie
	stats.from_json(data["stats"])
	if categorie == Categorie.ARME:
		pa = data["pa"]
		po = Vector2(data["po"][0], data["po"][1])
		type_zone = data["type_zone"] as Enums.TypeZone
		taille_zone = Vector2(data["taille_zone"][0], data["taille_zone"][1])
		po_modifiable = data["po_modifiable"]
		cible = data["cible"] as Enums.Cible
		particules_cible = data["particules_cible"]
		particules_retour = data["particules_retour"]
		effets = data["effets"]

	if categorie == Categorie.CAPE:
		carte = load("res://Equipements/Capes/" + nom + ".png")
		icone = load("res://UI/Logos/Equipements/Capes/" + nom + ".png")
		visuel1 = load("res://Equipements/Capes/Sprites/" + nom + ".png")
		visuel2 = load("res://Equipements/Capes/Sprites/" + nom + "2.png")
	if categorie == Categorie.COIFFE:
		carte = load("res://Equipements/Coiffes/" + nom + ".png")
		icone = load("res://UI/Logos/Equipements/Coiffes/" + nom + ".png")
		visuel1 = load("res://Equipements/Coiffes/Sprites/" + nom + ".png")
		visuel2 = load("res://Equipements/Coiffes/Sprites/" + nom + "2.png")
	if categorie == Categorie.DOFUS:
		carte = load("res://Equipements/Dofus/" + nom + ".png")
		icone = load("res://UI/Logos/Equipements/Dofus/" + nom + ".png")
	if categorie == Categorie.ARME:
		carte = load("res://Equipements/Armes/" + nom + ".png")
		icone = load("res://UI/Logos/Equipements/Armes/" + nom + ".png")
	if categorie == Categorie.FAMILIER:
		carte = load("res://Equipements/Familiers/" + nom + ".png")
		icone = load("res://UI/Logos/Equipements/Familiers/" + nom + ".png")
	
	return self


func to_json() -> Dictionary[String, Variant]:
	if categorie == Categorie.ARME:
		return {
			"categorie": Categorie.keys()[categorie],
			"stats": stats.to_json(),
			"pa": pa,
			"po": po,
			"type_zone": type_zone,
			"taille_zone": taille_zone,
			"po_modifiable": po_modifiable,
			"cible": cible,
			"particules_cible": particules_cible,
			"particules_retour": particules_retour,
			"effets": effets
		}
	else:
		return {
			"categorie": Categorie.keys()[categorie],
			"stats": stats.to_json()
		}
