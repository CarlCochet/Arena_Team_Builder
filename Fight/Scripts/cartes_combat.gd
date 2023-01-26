extends HBoxContainer


func update(cartes_combat: Array):
	for carte in get_children():
		carte.queue_free()
	
	for carte_combat in cartes_combat:
		var texture_rect = TextureRect.new()
		var carte = Sprite2D.new()
		
		texture_rect.texture = load("res://Fight/CartesCombat/" + carte_combat + ".png")
		carte.texture = load("res://Fight/CartesCombat/" + carte_combat + ".png")
		carte.position = Vector2(-140, 1000)
		carte.scale = Vector2(3, 3)
		carte.name = "carte"
		
		add_child(texture_rect)
		carte.visible = false
		texture_rect.add_child(carte)
		
		texture_rect.connect("mouse_entered", carte_hovered.bind(texture_rect))
		texture_rect.connect("mouse_exited", carte_exited.bind(texture_rect))


func carte_hovered(carte):
	carte.get_node("carte").visible = true


func carte_exited(carte):
	carte.get_node("carte").visible = false
