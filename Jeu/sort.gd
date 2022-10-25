extends Node
class_name Sort


var nom: String
var kamas: int = 0
var pa: int
var po: Vector2
var type_zone: GlobalData.TypeZone
var taille_zone: int
var cible: GlobalData.Cible
var ldv: int
var type_ldv: GlobalData.TypeLDV
var cooldown: int
var cooldown_global: int
var effets: Dictionary


func _init(data):
	kamas = data["kamas"]
	pa = data["pa"]
	po = Vector2(data["po"][0], data["po"][1])
	type_zone = data["type_zone"]
	taille_zone = data["taille_zone"]
	cible = data["cible"]
	ldv = data["ldv"]
	type_ldv = data["type_ldv"]
	cooldown = data["cooldown"]
	cooldown_global = data["cooldown_global"]
	effets = data["effets"]
