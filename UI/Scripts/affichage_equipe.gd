extends Control


var equipe_nodes
var fond_equipes


func _ready():
	equipe_nodes = get_node("Equipe").get_children()
	fond_equipes = get_node("FondEquipe").get_children()

func update():
	if GlobalData.equipe_actuelle.personnages:
		for i in range(len(GlobalData.equipe_actuelle.personnages)):
			var personnage = GlobalData.equipe_actuelle.personnages[i]
			if personnage.classe:
				equipe_nodes[i].texture = load("res://Classes/" + personnage.classe + "/" + personnage.classe.to_lower() + ".png")
				fond_equipes[i].update(i)

