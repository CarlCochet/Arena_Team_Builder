extends Node2D
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
var resistance_zone: int
var invocations: int


var nom_stats: Array[String] = [
	"hp", "pa", "pm", "initiative", "po", "cc", "invocations",
	"dommages_air", "dommages_terre", "dommages_feu", "dommages_eau", "blocage", "soins",
	"resistances_air", "resistances_terre", "resistances_feu", "resistances_eau", 
	"esquive", "renvoi_dommage", "resistance_zone"
]


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
	resistance_zone = 0
	invocations = 0


func add(stats: Stats) -> Stats:
	kamas += stats.kamas
	pa += stats.pa
	pm += stats.pm
	hp += stats.hp
	initiative += stats.initiative
	dommages_air += stats.dommages_air
	dommages_terre += stats.dommages_terre
	dommages_feu += stats.dommages_feu
	dommages_eau += stats.dommages_eau
	resistances_air += stats.resistances_air
	resistances_terre += stats.resistances_terre
	resistances_feu += stats.resistances_feu
	resistances_eau += stats.resistances_eau
	po += stats.po
	esquive += stats.esquive
	blocage += stats.blocage
	soins += stats.soins
	cc += stats.cc
	renvoi_dommage += stats.renvoi_dommage
	resistance_zone += stats.resistance_zone
	invocations += stats.invocations
	return self


func copy() -> Stats:
	var stats_copy := Stats.new()
	stats_copy.kamas = kamas
	stats_copy.pa = pa
	stats_copy.pm = pm
	stats_copy.hp = hp
	stats_copy.initiative = initiative
	stats_copy.dommages_air = dommages_air
	stats_copy.dommages_terre = dommages_terre
	stats_copy.dommages_feu = dommages_feu
	stats_copy.dommages_eau = dommages_eau
	stats_copy.resistances_air = resistances_air
	stats_copy.resistances_terre = resistances_terre
	stats_copy.resistances_feu = resistances_feu
	stats_copy.resistances_eau = resistances_eau
	stats_copy.po = po
	stats_copy.esquive = esquive
	stats_copy.blocage = blocage
	stats_copy.soins = soins
	stats_copy.cc = cc
	stats_copy.renvoi_dommage = renvoi_dommage
	stats_copy.resistance_zone = resistance_zone
	stats_copy.invocations = invocations
	return stats_copy


func from_json(data: Dictionary) -> Stats:
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
	resistance_zone = data.get("resistance_zone", 0)
	return self


func to_json() -> Dictionary:
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
		"renvoi_dommage": renvoi_dommage,
		"resistance_zone": resistance_zone
	}
