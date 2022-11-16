extends TextureRect


@onready var cout_total: Label = $CoutTotal


func update():
	cout_total.text = str(GlobalData.equipe_actuelle.calcul_budget())
