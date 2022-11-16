extends Control


var equipe_nodes
var fond_equipes


func _ready():
	equipe_nodes = get_node("Equipe").get_children()
	fond_equipes = get_node("FondEquipe").get_children()

func update(equipe):
	if equipe.personnages:
		for i in range(len(equipe.personnages)):
			var personnage = equipe.personnages[i]
			if personnage.classe:
				equipe_nodes[i].texture = load("res://Classes/" + personnage.classe + "/" + personnage.classe.to_lower() + ".png")
				fond_equipes[i].update(i)
			else:
				equipe_nodes[i].texture = load("res://Classes/empty.png")
				fond_equipes[i].update(i)
