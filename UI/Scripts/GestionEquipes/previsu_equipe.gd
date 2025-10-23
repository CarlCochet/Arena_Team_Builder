extends TextureButton
class_name PrevisuEquipe


var signal_id: int

@onready var equipe_nodes: Array = get_children()


func update(id):
	if GlobalData.equipes[id].personnages:
		for i in range(len(GlobalData.equipes[id].personnages)):
			var personnage: Personnage = GlobalData.equipes[id].personnages[i]
			var previsu: PrevisuPersonnage = equipe_nodes[i]
			previsu.update(personnage, 1)
			previsu.scale = Vector2(0.8, 0.8)
