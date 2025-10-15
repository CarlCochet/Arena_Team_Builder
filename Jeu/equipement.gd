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


func from_json(data, json_categorie):
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
	return self


func to_json():
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
