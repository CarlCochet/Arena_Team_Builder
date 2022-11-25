extends Node2D
class_name Combattant


signal clicked


var classe: String
var stats: Stats
var max_stats: Stats
var equipements: Dictionary
var sorts: Array
var equipe: int
var effets: Dictionary

var grid_pos: Vector2i
var id

var is_selected: bool
var is_hovered: bool

var cercle_bleu = preload("res://Fight/Images/cercle_personnage_bleu.png")
var cercle_rouge = preload("res://Fight/Images/cercle_personnage_rouge.png")
var outline_shader = preload("res://Fight/Shaders/combattant_outline.gdshader")

@onready var cercle: Sprite2D = $Cercle
@onready var fleche: Sprite2D = $Fleche
@onready var classe_sprite: Sprite2D = $Classe


func _ready():
	effets = {}
	classe_sprite.material = ShaderMaterial.new()
	classe_sprite.material.shader = outline_shader
	classe_sprite.material.set_shader_parameter("width", 0.0)
	is_selected = false
	is_hovered = false


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
	equipements = personnage.equipements
	sorts = personnage.sorts
	equipe = equipe_id
	return self


func _on_area_2d_mouse_entered():
	classe_sprite.material.set_shader_parameter("width", 3.0)
	is_hovered = true
	get_parent().stats_hover.update(stats, stats)
	get_parent().stats_hover.visible = true


func _on_area_2d_mouse_exited():
	classe_sprite.material.set_shader_parameter("width", 0.0)
	is_hovered = false
	if is_selected:
		classe_sprite.material.set_shader_parameter("width", 2.0)
	get_parent().stats_hover.visible = false


func change_orientation(orientation: int):
	fleche.texture = load("res://Fight/Images/fleche_" + str(orientation) + ".png")


func debut_tour():
	pass


func fin_tour():
	pass


func _input(event):
	if event is InputEventMouseButton:
		if is_hovered:
			emit_signal("clicked")
