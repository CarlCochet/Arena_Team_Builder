extends TextureRect


func update():
	get_node("CoutTotal").text = str(GlobalData.equipe_actuelle.calcul_budget())
