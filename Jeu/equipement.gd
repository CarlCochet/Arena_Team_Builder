extends Node
class_name Equipement

enum Categories {VIDE, ARME, FAMILIER, COIFFE, CAPE, DOFUS}

var categorie: Categories = Categories.VIDE
var stats: Stats
var pa: int = 0
var po: Vector2 = Vector2(0, 0)
var type_zone: GlobalData.TypeZone = GlobalData.TypeZone.CERCLE
var taille_zone: int = 0
var cible: GlobalData.Cible = GlobalData.Cible.LIBRE


func _init(data, json_categorie):
	categorie = Categories.keys().find(json_categorie) as Categories
	stats = Stats.new(data["stats"])
	if categorie == Categories.ARME:
		pa = data["pa"]
		po = Vector2(data["po"][0], data["po"][1])
		type_zone = data["type_zone"]
		taille_zone = data["taille_zone"]
		cible = data["cible"]
