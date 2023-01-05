extends Node2D
class_name Equipement


enum Categorie {VIDE, ARME, FAMILIER, COIFFE, CAPE, DOFUS}

var categorie: Categorie
var stats: Stats
var pa: int
var po: Vector2 
var type_zone: GlobalData.TypeZone
var taille_zone: Vector2
var cible: GlobalData.Cible
var effets: Dictionary


func _init():
	categorie = Categorie.VIDE
	stats = Stats.new()
	pa = 0
	po = Vector2(0, 0)
	type_zone = GlobalData.TypeZone.CERCLE
	taille_zone = Vector2(0, 0)
	cible = GlobalData.Cible.LIBRE
	effets = {}


func from_json(data, json_categorie):
	categorie = Categorie.keys().find(json_categorie) as Categorie
	stats.from_json(data["stats"])
	if categorie == Categorie.ARME:
		pa = data["pa"]
		po = Vector2(data["po"][0], data["po"][1])
		type_zone = data["type_zone"] as GlobalData.TypeZone
		taille_zone = Vector2(data["taille_zone"][0], data["taille_zone"][1])
		cible = data["cible"] as GlobalData.Cible
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
			"cible": cible,
			"effets": effets
		}
	else:
		return {
			"categorie": Categorie.keys()[categorie],
			"stats": stats.to_json()
		}
