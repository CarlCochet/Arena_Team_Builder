extends Node2D
class_name Combattant


var classe: String
var stats: Stats
var equipements: Dictionary
var sorts: Array
var equipe: int
var effets: Dictionary

var cercle_bleu = preload("res://Fight/Images/cercle_personnage_bleu.png")
var cercle_rouge = preload("res://Fight/Images/cercle_personnage_rouge.png")

@onready var cercle: Sprite2D = $Cercle
@onready var fleche: Sprite2D = $Fleche
@onready var classe_sprite: Sprite2D = $Classe


func _ready():
	effets = {}


func update_visuel():
	if equipe == 0:
		cercle.texture = cercle_bleu
	else:
		cercle.texture = cercle_rouge
	classe_sprite.texture = load(
		"res://Classes/" + classe + "/" + classe.to_lower() + ".png"
	)


func _process(delta):
	pass


func from_personnage(personnage: Personnage, equipe_id: int):
	classe = personnage.classe
	stats = personnage.stats.copy()
	equipements = personnage.equipements
	sorts = personnage.sorts
	equipe = equipe_id
	return self
