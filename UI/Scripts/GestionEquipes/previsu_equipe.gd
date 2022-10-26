extends TextureButton

var equipe_nodes


func _ready():
	equipe_nodes = get_node("Equipe").get_children()


func update(id):
	if GlobalData.equipes[id].personnages:
		for i in range(len(GlobalData.equipes[id].personnages)):
			var personnage = GlobalData.equipes[id].personnages[i]
			equipe_nodes[i].texture = load("res://Classes/" + personnage.classe + "/" + personnage.classe.to_lower() + ".png")
