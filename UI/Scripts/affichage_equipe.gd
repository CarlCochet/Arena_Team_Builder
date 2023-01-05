extends Control


@onready var equipe_nodes: Array = $Equipe.get_children()
@onready var fond_equipes: Array = $FondEquipe.get_children()


func update(equipe):
	if equipe.personnages:
		for i in range(len(equipe.personnages)):
			var personnage = equipe.personnages[i]
			if personnage.classe:
				equipe_nodes[i].texture = load("res://Classes/" + personnage.classe + "/" + personnage.classe.to_lower() + ".png")
				fond_equipes[i].update(i, equipe)
			else:
				equipe_nodes[i].texture = load("res://Classes/empty.png")
				fond_equipes[i].update(i, equipe)
