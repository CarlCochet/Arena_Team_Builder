extends Node2D
class_name Combattant


signal clicked


var classe: String
var stats: Stats
var max_stats: Stats
var init_stats: Stats
var equipements: Dictionary
var sorts: Array
var equipe: int
var effets: Dictionary

var grid_pos: Vector2i
var id: int
var orientation: int
var all_path: Array
var path_actuel: Array
var all_ldv: Array

var is_selected: bool
var is_hovered: bool

var cercle_bleu = preload("res://Fight/Images/cercle_personnage_bleu.png")
var cercle_rouge = preload("res://Fight/Images/cercle_personnage_rouge.png")
var outline_shader = preload("res://Fight/Shaders/combattant_outline.gdshader")

@onready var cercle: Sprite2D = $Cercle
@onready var fleche: Sprite2D = $Fleche
@onready var classe_sprite: Sprite2D = $Classe
@onready var hp: Sprite2D = $HP
@onready var hp_label: Label = $HP/Label


func _ready():
	effets = {}
	classe_sprite.material = ShaderMaterial.new()
	classe_sprite.material.shader = outline_shader
	classe_sprite.material.set_shader_parameter("width", 0.0)
	is_selected = false
	is_hovered = false
	hp_label.text = str(stats.hp) + "/" + str(max_stats.hp)


func update_visuel():
	if equipe == 0:
		cercle.texture = cercle_bleu
	else:
		cercle.texture = cercle_rouge
	classe_sprite.texture = load(
		"res://Classes/" + classe + "/" + classe.to_lower() + ".png"
	)


func select():
	classe_sprite.material.set_shader_parameter("width", 2.0)
	get_parent().stats_select.update(stats, stats)
	is_selected = true
	get_parent().sorts.update(classe, sorts)


func unselect():
	classe_sprite.material.set_shader_parameter("width", 0.0)
	is_selected = false


func from_personnage(personnage: Personnage, equipe_id: int):
	classe = personnage.classe
	stats = personnage.stats.copy()
	max_stats = personnage.stats.copy()
	init_stats = personnage.stats.copy()
	equipements = personnage.equipements
	sorts = personnage.sorts
	equipe = equipe_id
	return self


func _on_area_2d_mouse_entered():
	for combattant in get_parent().combattants:
		if combattant.is_hovered:
			combattant._on_area_2d_mouse_exited()
	classe_sprite.material.set_shader_parameter("width", 3.0)
	is_hovered = true
	get_parent().stats_hover.update(stats, stats)
	get_parent().stats_hover.visible = true
	hp.visible = true
	if get_parent().action == 7:
		affiche_path(Vector2i(99, 99))


func _on_area_2d_mouse_exited():
	if is_hovered:
		classe_sprite.material.set_shader_parameter("width", 0.0)
		is_hovered = false
		if is_selected:
			classe_sprite.material.set_shader_parameter("width", 2.0)
		get_parent().stats_hover.visible = false
		hp.visible = false
		if get_parent().action == 7:
			get_parent().change_action(7)


func change_orientation(orientation: int):
	fleche.texture = load("res://Fight/Images/fleche_" + str(orientation) + ".png")


func affiche_path(pos_event):
	all_path = get_parent().tilemap.get_atteignables(grid_pos, stats.pm)
	var path = get_parent().tilemap.get_chemin(grid_pos, pos_event)
	if len(path) > 0 and len(path) <= stats.pm + 1:
		path.pop_front()
		path_actuel = path
		get_parent().tilemap.clear_layer(2)
		for cell in path:
			get_parent().tilemap.set_cell(2, cell - get_parent().offset, 3, Vector2i(1, 0))
	else:
		path_actuel = []
		get_parent().tilemap.clear_layer(2)
		for cell in all_path:
			get_parent().tilemap.set_cell(2, cell - get_parent().offset, 3, Vector2i(1, 0))


func affiche_ldv(action, pos_event):
	var data
	if action == 0:
		if not equipements["Armes"].is_empty():
			data = GlobalData.equipements[equipements["Armes"]].to_json()
			data["ldv"] = 1
			data["type_ldv"] = 0
		else:
			data = {"po": [1, 1], "type_ldv": 0, "ldv": 1}
	else:
		data = GlobalData.sorts[sorts[action-1]]
	all_ldv = get_parent().tilemap.get_ldv(
		grid_pos, 
		data["po"][0],
		data["po"][1],
		data["type_ldv"],
		data["ldv"]
	)
	get_parent().tilemap.clear_layer(2)
	for cell in all_ldv:
		get_parent().tilemap.set_cell(2, cell - get_parent().offset, 3, Vector2i(2, 0))
	if pos_event in all_ldv:
		if data["taille_zone"] == 0:
			get_parent().tilemap.set_cell(2, pos_event - get_parent().offset, 3, Vector2i(0, 0))
		else:
			var zone = get_parent().tilemap.get_zone(
				grid_pos,
				pos_event,
				data["type_zone"],
				data["taille_zone"]
			)
			for cell in zone:
				get_parent().tilemap.set_cell(2, cell - get_parent().offset, 3, Vector2i(0, 0))


func debut_tour():
	for effet in effets:
		pass
	all_path = get_parent().tilemap.get_atteignables(grid_pos, stats.pm)


func fin_tour():
	stats.pa = max_stats.pa
	stats.pm = max_stats.pm


func execute_effets():
	for effet in effets:
		pass




func _input(event):
	if event is InputEventMouseButton:
		if is_hovered:
			emit_signal("clicked")
