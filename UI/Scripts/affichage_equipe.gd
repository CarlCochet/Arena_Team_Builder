extends Control


var equipe_nodes


func _ready():
	equipe_nodes = get_node("Equipe").get_children()


func update_affichage():
	if GlobalData.equipe_actuelle.personnages:
		for i in range(len(GlobalData.equipe_actuelle.personnages)):
			var personnage = GlobalData.equipe_actuelle.personnages[i]
			var texture = CompressedTexture2D.new()
			texture.load("res://Classes/" + personnage.classe + "/" + personnage.classe.to_lower() + ".png")
			equipe_nodes[i].texture = texture
