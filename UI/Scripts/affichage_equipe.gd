extends Control
class_name AffichageEquipe


@onready var equipe_nodes: Array = $Equipe.get_children()
@onready var fond_equipes: Array = $FondEquipe.get_children()


func update(equipe):
	if equipe.personnages:
		for i in range(len(equipe.personnages)):
			var personnage = equipe.personnages[i]
			if personnage.equipements["Capes"]:
				equipe_nodes[i].get_node("Cape").texture = load("res://Equipements/Capes/Sprites/" + personnage.equipements["Capes"].to_lower() + ".png")
			else:
				equipe_nodes[i].get_node("Cape").texture = load("res://Classes/empty.png")
			if personnage.classe:
				equipe_nodes[i].get_node("Classe").texture = load("res://Classes/" + personnage.classe + "/" + personnage.classe.to_lower() + ".png")
			else:
				equipe_nodes[i].get_node("Classe").texture = load("res://Classes/empty.png")
			if personnage.equipements["Coiffes"]:
				equipe_nodes[i].get_node("Coiffe").texture = load("res://Equipements/Coiffes/Sprites/" + personnage.equipements["Coiffes"].to_lower() + ".png")
			else:
				equipe_nodes[i].get_node("Coiffe").texture = load("res://Classes/empty.png")
			fond_equipes[i].update(i, equipe)
