extends Node
class_name Stats


var kamas: int = 0
var pa: int = 0
var pm: int = 0
var hp: int = 0
var initiative: int = 0
var dommages_air: int = 0
var dommages_terre: int = 0
var dommages_feu: int = 0
var dommages_eau: int = 0
var resistances_air: int = 0
var resistances_terre: int = 0
var resistances_feu: int = 0
var resistances_eau: int = 0
var po: int = 0
var esquive: int = 0
var blocage: int = 0
var soins: int = 0
var cc: int = 0
var renvoi_dommage: int = 0


func _init(data):
	kamas = data["kamas"]
	pa = data["pa"]
	pm = data["pm"]
	hp = data["hp"]
	initiative = data["initiative"]
	dommages_air = data["dommages_air"]
	dommages_terre = data["dommages_terre"]
	dommages_feu = data["dommages_feu"]
	dommages_eau = data["dommages_eau"]
	resistances_air = data["resistances_air"]
	resistances_terre = data["resistances_terre"]
	resistances_feu = data["resistances_feu"]
	resistances_eau = data["resistances_eau"]
	po = data["po"]
	esquive = data["esquive"]
	blocage = data["blocage"]
	soins = data["soins"]
	cc = data["cc"]
	renvoi_dommage = data["renvoi_dommage"]
