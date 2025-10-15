extends TextureButton
class_name PrevisuEquipe


var signal_id: int

@onready var equipe_nodes: Array = get_node("Equipe").get_children()


func update(id):
	if GlobalData.equipes[id].personnages:
		for i in range(len(GlobalData.equipes[id].personnages)):
			var personnage = GlobalData.equipes[id].personnages[i]
			if personnage.classe:
				equipe_nodes[i].texture = load("res://Classes/" + personnage.classe + "/" + personnage.classe.to_lower() + ".png")
			else:
				equipe_nodes[i].texture = load("res://Classes/empty.png")
