extends Node
class_name Stats


var kamas: int
var pa: int
var pm: int
var hp: int
var initiative: int
var dommages_air: int
var dommages_terre: int
var dommages_feu: int
var dommages_eau: int
var resistances_air: int
var resistances_terre: int
var resistances_feu: int
var resistances_eau: int
var po: int
var esquive: int
var blocage: int
var soins: int
var cc: int
var renvoi_dommage: int


func _init():
	kamas = 0
	pa = 0
	pm = 0
	hp = 0
	initiative = 0
	dommages_air = 0
	dommages_terre = 0
	dommages_feu = 0
	dommages_eau = 0
	resistances_air = 0
	resistances_terre = 0
	resistances_feu = 0
	resistances_eau = 0
	po = 0
	esquive = 0
	blocage = 0
	soins = 0
	cc = 0
	renvoi_dommage = 0


func from_json(data):
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
	return self


func to_json():
	return {
		"kamas": kamas,
		"pa": pa,
		"pm": pm,
		"hp": hp,
		"initiative": initiative,
		"dommages_air": dommages_air,
		"dommages_terre": dommages_terre,
		"dommages_feu": dommages_feu,
		"dommages_eau": dommages_eau,
		"resistances_air": resistances_air,
		"resistances_terre": resistances_terre,
		"resistances_feu": resistances_feu,
		"resistances_eau": resistances_eau,
		"po": po,
		"esquive": esquive,
		"blocage": blocage,
		"soins": soins,
		"cc": cc,
		"renvoi_dommage": renvoi_dommage
	}
	
