extends TextureRect
class_name AffichageBudget


@onready var cout_total: Label = $CoutTotal


func update():
	var budget = GlobalData.equipe_actuelle.calcul_budget()
	cout_total.text = str(budget)
	
	if budget <= 6000:
		cout_total.label_settings.font_color = Color(1.0, 0.753, 0.0)
	else:
		cout_total.label_settings.font_color = Color(1.0, 0.0, 0.0)
	
	if budget < 10000:
		cout_total.label_settings.font_size = 22
	else:
		cout_total.label_settings.font_size = 18
