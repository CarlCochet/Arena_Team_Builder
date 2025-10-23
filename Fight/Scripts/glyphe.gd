extends Node
class_name Glyphe

var id: int
var lanceur: Combattant
var tiles: Array[Vector2i]
var effets: Dictionary[String, Variant]
var critique: bool
var bloqueur: bool
var duree: int
var centre: Vector2i
var aoe: bool
var sort: Sort
var deleted: bool
var combattants_id: Array[int]

func _init(p_id: int, p_lanceur: Combattant, p_tiles: Array[Vector2i], p_effets: Dictionary, p_bloqueur: bool, p_critique: bool, p_centre: Vector2i, p_aoe: bool, p_sort: Sort):
	id = p_id
	lanceur = p_lanceur
	tiles = p_tiles
	effets = p_effets
	bloqueur = p_bloqueur
	critique = p_critique
	if critique and effets["GLYPHE"].has("critique"):
		duree = effets["GLYPHE"]["critique"]["duree"]
	else:
		duree = effets["GLYPHE"]["base"]["duree"]
	centre = p_centre
	aoe = p_aoe
	sort = p_sort
	deleted = false
	combattants_id = []

func active_full():
	var triggered: bool = false
	for combattant in lanceur.combat.combattants:
		var affiche_log: bool = true
		if combattant.grid_pos in tiles:
			if combattant.id in combattants_id:
				affiche_log = false
			combattants_id.append(combattant.id)
			var temp_hp: int = combattant.stats.hp
			var temp_pa: int = combattant.stats.pa
			var temp_pm: int = combattant.stats.pm
			combattant.stats = combattant.init_stats.copy().add(combattant.stat_ret).add(combattant.stat_buffs).add(combattant.stat_cartes_combat)
			combattant.stats.hp = temp_hp
			combattant.stats.pa = temp_pa
			combattant.stats.pm = temp_pm
			for effet in effets:
				if effet == "DEVIENT_INVISIBLE" or not combattant.check_etats(["PORTE"]):
					var new_effet: Effet = Effet.new(lanceur, combattant, effet, effets[effet], critique, centre, aoe, sort)
					new_effet.instant = true
					new_effet.affiche_log = affiche_log
					new_effet.execute()
			triggered = true
		else:
			combattants_id.erase(combattant.id)
	if triggered and effets.has("DOMMAGE_FIXE"):
		lanceur.combat.tilemap.delete_glyphes([id])
		deleted = true

func active_mono(combattant: Combattant):
	for tile in tiles:
		if combattant.grid_pos == tile:
			for effet in effets:
				var new_effet = Effet.new(lanceur, combattant, effet, effets[effet], critique, centre, true, sort)
				new_effet.execute()

func affiche():
	for tile in tiles:
		if effets.has("DOMMAGE_FIXE"):
			lanceur.combat.tilemap.set_cell(3, tile - lanceur.combat.offset, 1, Vector2i(0, 0))
		if effets.has("DEVIENT_INVISIBLE"):
			lanceur.combat.tilemap.set_cell(4, tile - lanceur.combat.offset, 1, Vector2i(1, 0))
