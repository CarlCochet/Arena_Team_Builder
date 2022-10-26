extends Node
class_name Equipement

enum Categorie {VIDE, ARME, FAMILIER, COIFFE, CAPE, DOFUS}

var categorie: Categorie
var stats: Stats
var pa: int
var po: Vector2 
var type_zone: GlobalData.TypeZone
var taille_zone: int
var cible: GlobalData.Cible


func _init():
	categorie = Categorie.VIDE
	stats = Stats.new()
	pa = 0
	po = Vector2(0, 0)
	type_zone = GlobalData.TypeZone.CERCLE
	taille_zone = 0
	cible = GlobalData.Cible.LIBRE


func from_json(data, json_categorie):
	categorie = Categorie.keys().find(json_categorie) as Categorie
	stats.from_json(data["stats"])
	if categorie == Categorie.ARME:
		pa = data["pa"]
		po = Vector2(data["po"][0], data["po"][1])
		type_zone = data["type_zone"] as GlobalData.TypeZone
		taille_zone = data["taille_zone"]
		cible = data["cible"] as GlobalData.Cible
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
			"cible": cible
		}
	else:
		return {
			"categorie": Categorie.keys()[categorie],
			"stats": stats.to_json()
		}
