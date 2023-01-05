extends Combattant
class_name Invocation


@onready var hitbox: Area2D = $Area2D


func _ready():
	effets = []
	classe_sprite.material = ShaderMaterial.new()
	classe_sprite.material.shader = outline_shader
	classe_sprite.material.set_shader_parameter("width", 0.0)
	orientation = 1
	stat_buffs = Stats.new()
	stat_ret = Stats.new()
	is_selected = false
	is_hovered = false
	is_invocation = true
	hp_label.text = str(stats.hp) + "/" + str(max_stats.hp)
	combat = get_parent()
	update_hitbox()
	invocations = []


func init(classe_int: int):
	print(classe_int as GlobalData.Invocations)
	match classe_int as GlobalData.Invocations:
		GlobalData.Invocations.BOUFTOU:
			classe = "Bouftou"
		GlobalData.Invocations.CRAQUELEUR:
			classe = "Craqueleur"
		GlobalData.Invocations.PRESPIC:
			classe = "Prespic"
		GlobalData.Invocations.TOFU:
			classe = "Tofu"
		GlobalData.Invocations.ARBRE:
			classe = "Arbre"
		GlobalData.Invocations.BLOQUEUSE:
			classe = "La_Bloqueuse"
		GlobalData.Invocations.FOLLE:
			classe = "La_Folle"
		GlobalData.Invocations.SACRIFIEE:
			classe = "La_Sacrifiee"
		GlobalData.Invocations.DOUBLE:
			classe = "Double"
		GlobalData.Invocations.CADRAN_DE_XELOR:
			classe = "Cadran_De_Xelor"
		GlobalData.Invocations.BOMBE_A_EAU:
			classe = "Bombe_A_Eau"
		GlobalData.Invocations.BOMBE_INCENDIAIRE:
			classe = "Bombe_Incendiaire"
		_:
			print("Non-existent summon.")
	print(classe)
	stats = GlobalData.stats_classes[classe].copy()
	max_stats = GlobalData.stats_classes[classe].copy()
	init_stats = GlobalData.stats_classes[classe].copy()
	sorts = []
	if GlobalData.sorts_lookup.has(classe):
		var nom_sorts = GlobalData.sorts_lookup[classe]
		for sort in nom_sorts:
			sorts.append(GlobalData.sorts[sort])


func update_hitbox():
	if equipe == 0:
		cercle.texture = cercle_bleu
	else:
		cercle.texture = cercle_rouge
	match classe:
		"Tofu":
			classe_sprite.position = Vector2(0, -10)
			hitbox.position = Vector2(0, -10)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -60)
		"Bouftou":
			classe_sprite.position = Vector2(0, -13)
			hitbox.position = Vector2(0, -13)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"Craqueleur":
			classe_sprite.position = Vector2(0, -40)
			hitbox.position = Vector2(0, -40)
			hitbox.scale = Vector2(3, 5)
			hp.position = Vector2(0, -120)
		"Prespic":
			classe_sprite.position = Vector2(0, -17)
			hitbox.position = Vector2(0, -15)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"La_Bloqueuse":
			classe_sprite.position = Vector2(0, -25)
			hitbox.position = Vector2(0, -20)
			hitbox.scale = Vector2(2, 2.5)
			hp.position = Vector2(0, -80)
		"La_Folle":
			classe_sprite.position = Vector2(0, -17)
			hitbox.position = Vector2(0, -20)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"La_Sacrifiee":
			classe_sprite.position = Vector2(0, -20)
			hitbox.position = Vector2(0, -12)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"Arbre":
			classe_sprite.position = Vector2(0, -60)
			classe_sprite.scale = Vector2(1, 1)
			hitbox.position = Vector2(0, -50)
			hitbox.scale = Vector2(2, 5)
			hp.position = Vector2(0, -120)
		"Double":
			classe_sprite.position = Vector2(0, -48)
			hitbox.position = Vector2(0, -38)
			hitbox.scale = Vector2(2, 4)
			hp.position = Vector2(0, -110)
		"Cadran_De_Xelor":
			classe_sprite.position = Vector2(0, -35)
			hitbox.position = Vector2(0, -30)
			hitbox.scale = Vector2(2, 3)
			hp.position = Vector2(0, -80)
		"Bombe_A_Eau":
			classe_sprite.position = Vector2(0, -20)
			classe_sprite.scale = Vector2(0.4, 0.4)
			hitbox.position = Vector2(0, -12)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -80)
		"Bombe_Incendiaire":
			classe_sprite.position = Vector2(0, -20)
			classe_sprite.scale = Vector2(0.4, 0.4)
			hitbox.position = Vector2(0, -12)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -80)
	classe_sprite.texture = load(
		"res://Classes/Invocations/" + classe.to_lower() + ".png"
	)


func debut_tour():
	retrait_durees()
	execute_effets()
	var hp = stats.hp
	stats = init_stats.copy().add(stat_ret).add(stat_buffs)
	stats.hp = hp
	print(classe)
	for effet in effets:
		print(effet.etat, " - ", str(effet.duree))
	all_path = combat.tilemap.get_atteignables(grid_pos, stats.pm)
	if check_etat("PETRIFIE"):
		combat.passe_tour()
	combat.check_morts()
	joue_ia()
	combat.passe_tour()


func chemin_vers_proche() -> Array:
	var voisins = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	var min_dist = 99999999
	var plus_proche = combat.combattants[0]
	var min_chemin = []
	for combattant in combat.combattants:
		if combattant.equipe != equipe:
			for voisin in voisins:
				if combattant.grid_pos == (grid_pos + voisin):
					return []
				var chemin = combat.tilemap.get_chemin(grid_pos, combattant.grid_pos + voisin)
				if len(chemin) < min_dist and len(chemin) > 0:
					plus_proche = combattant
					min_dist = len(chemin)
					min_chemin = chemin
	return min_chemin


func choix_cible(all_ldv: Array):
	var min_dist = 9999999
	var min_hp = 9999999
	var cible = null
	for combattant in combat.combattants:
		if combattant.grid_pos in all_ldv:
			var delta = combattant.grid_pos - grid_pos
			var dist = abs(delta.x) + abs(delta.y)
			if dist < min_dist:
				min_dist = dist
				cible = combattant.grid_pos
				min_hp = combattant.stats.hp
			elif dist == min_dist and combattant.stats.hp < min_hp:
				min_dist = dist
				cible = combattant.grid_pos
				min_hp = combattant.stats.hp
	return cible


func joue_ia():
	combat.check_morts()
	var chemin = chemin_vers_proche()
	if len(chemin) > stats.pm + 1:
		chemin = chemin.slice(0, stats.pm + 1)
	if len(chemin) > 0:
		deplace_perso(chemin)
	for sort in sorts:
		if not sort.precheck_cast(self):
			continue
		all_ldv = combat.tilemap.get_ldv(
			grid_pos, 
			sort.po[0],
			sort.po[1] + (stats.po if sort.po_modifiable else 0),
			sort.type_ldv,
			sort.ldv
		)
		var cible = choix_cible(all_ldv)
		if cible == null:
			continue
		if sort.pa <= stats.pa:
			var valide = false
			if check_etat("RATE_SORT"):
				valide = true
				retire_etats(["RATE_SORT"])
			else:
				valide = sort.execute_effets(self, [cible], cible)
			if valide:
				stats.pa -= sort.pa
				stats_perdu.ajoute(-sort.pa, "pa")
				combat.stats_select.update(stats, max_stats)
			joue_ia()


func fin_tour():
	retrait_cooldown()
	stat_ret = Stats.new()
	var hp = stats.hp
	stats = init_stats.copy().add(stat_buffs)
	stats.hp = hp
	combat.check_morts()
