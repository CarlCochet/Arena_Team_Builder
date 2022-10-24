extends Node
class_name Personnage


var cout: int = 600
var equipements: Array
var sorts: Array


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func calcul_cout():
	cout = 600
	for equipement in equipements:
		cout += equipement.cout
	for sort in sorts:
		cout += sort.cout
