extends Node2D
class_name Sort


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


func _init():
	kamas = 0
	pa = 0
	po = Vector2(0, 0)
	type_zone = GlobalData.TypeZone.CERCLE
	taille_zone = 0
	cible = GlobalData.Cible.LIBRE
	ldv = 0
	type_ldv = GlobalData.TypeLDV.CERCLE
	cooldown = 0
	cooldown_global = 0
	effets = {}


func execute_effets(lanceur, cible, personnages):
	pass


func dommage_fixe(lanceur, cible, personnages):
	pass


func dommage_pourcent(lanceur, cible, personnages):
	pass


func dommage_air(lanceur, cible, personnages):
	pass


func dommage_terre(lanceur, cible, personnages):
	pass


func dommage_feu(lanceur, cible, personnages):
	pass


func dommage_eau(lanceur, cible, personnages):
	pass


func vole_air(lanceur, cible, personnages):
	pass


func vole_terre(lanceur, cible, personnages):
	pass


func vole_feu(lanceur, cible, personnages):
	pass


func vole_eau(lanceur, cible, personnages):
	pass


func soin(lanceur, cible, personnages):
	pass


func change_stats(lanceur, cible, personnages):
	pass


func vole_stats(lanceur, cible, personnages):
	pass


func pousse(lanceur, cible, personnages):
	pass


func attire(lanceur, cible, personnages):
	pass


func immobilise(lanceur, cible, personnages):
	pass


func teleporte(lanceur, cible, personnages):
	pass


func transpose(lanceur, cible, personnages):
	pass


func petrifie(lanceur, cible, personnages):
	pass


func rate_sort(lanceur, cible, personnages):
	pass


func revele_invisible(lanceur, cible, personnages):
	pass


func devient_invisible(lanceur, cible, personnages):
	pass


func desenvoute(lanceur, cible, personnages):
	pass


func non_portable(lanceur, cible, personnages):
	pass


func intransposable(lanceur, cible, personnages):
	pass


func immunise(lanceur, cible, personnages):
	pass


func stabilise(lanceur, cible, personnages):
	pass


func renvoie_sort(lanceur, cible, personnages):
	pass


func invocation(lanceur, cible, personnages):
	pass


func porte(lanceur, cible, personnages):
	pass


func lance(lanceur, cible, personnages):
	pass


func picole(lanceur, cible, personnages):
	pass


func sacrifice(lanceur, cible, personnages):
	pass


func tourne(lanceur, cible, personnages):
	pass


func immunise_retrait_pa(lanceur, cible, personnages):
	pass


func immunise_retrait_pm(lanceur, cible, personnages):
	pass


func from_json(data):
	kamas = data["kamas"]
	pa = data["pa"]
	po = Vector2(data["po"][0], data["po"][1])
	type_zone = data["type_zone"] as GlobalData.TypeZone
	taille_zone = data["taille_zone"]
	cible = data["cible"] as GlobalData.Cible
	ldv = data["ldv"]
	type_ldv = data["type_ldv"] as GlobalData.TypeLDV
	cooldown = data["cooldown"]
	cooldown_global = data["cooldown_global"]
	effets = data["effets"]
	return self


func to_json():
	return {
		"kamas": kamas,
		"pa": pa,
		"po": [po[0], po[1]],
		"type_zone": type_zone,
		"taille_zone": taille_zone,
		"cible": cible,
		"ldv": ldv,
		"type_ldv": type_ldv,
		"cooldown": cooldown,
		"cooldown_global": cooldown_global,
		"effets": effets
	}
