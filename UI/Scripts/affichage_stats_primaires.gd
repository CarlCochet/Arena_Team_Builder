extends TextureRect


func update(id):
	var personnage = GlobalData.equipe_actuelle.personnages[id]
	get_node("PM").text = str(personnage.stats.pm)
	get_node("HP").text = str(personnage.stats.hp)
	get_node("Ini").text = str(personnage.stats.initiative)
	get_node("PA").text = str(personnage.stats.pa)
	get_node("Kamas").text = str(personnage.stats.kamas)
