extends HBoxContainer


var carte_hovered


func update(combattant):
	for sort in get_children():
		sort.queue_free()
	for sort in combattant.sorts:
		if sort.nom != "arme":
			var texture_rect = TextureRect.new()
			var sprite = Sprite2D.new()
			var carte = Sprite2D.new()
			var label = Label.new()
			
			texture_rect.texture = load("res://UI/Logos/Spells/" + combattant.classe + "/" + sort.nom + ".png")
			
			sprite.texture = load("res://Fight/Images/logo_cover.png")
			sprite.position = Vector2(19, 20)
			sprite.scale = Vector2(1.05, 1.05)
			
			carte.texture = load("res://Classes/" + combattant.classe + "/Sorts/" + sort.nom + ".png")
			carte.position = Vector2(82, -106)
			carte.scale = Vector2(0.5, 0.5)
			carte.name = "carte"
			
			label.text = str(sort.cooldown_actuel)
			label.position = Vector2(14, 8)
			
			add_child(texture_rect)
			
			sprite.visible = not sort.precheck_cast(combattant)
			texture_rect.add_child(sprite)
			
			label.visible = sort.cooldown_actuel > 0
			texture_rect.add_child(label)
			
			carte.visible = false
			texture_rect.add_child(carte)
			
			texture_rect.connect("mouse_entered", sort_hovered.bind(texture_rect, sort.nom))
			texture_rect.connect("mouse_exited", sort_exited.bind(texture_rect, sort.nom))


func sort_hovered(sort, _nom):
	sort.get_node("carte").visible = true


func sort_exited(sort, _nom):
	sort.get_node("carte").visible = false
