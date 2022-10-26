extends Control


var equipe_nodes


func _ready():
	equipe_nodes = get_node("Equipe").get_children()


func update():
	if GlobalData.equipe_actuelle.personnages:
		for i in range(len(GlobalData.equipe_actuelle.personnages)):
			var personnage = GlobalData.equipe_actuelle.personnages[i]
			equipe_nodes[i].texture = load("res://Classes/" + personnage.classe + "/" + personnage.classe.to_lower() + ".png")
