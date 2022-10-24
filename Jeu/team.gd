extends Node
class_name Equipe


var personnages: Array
var budget: int


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func calcul_budget():
	budget = 0
	for personnage in personnages:
		budget += personnage.get_cout()
