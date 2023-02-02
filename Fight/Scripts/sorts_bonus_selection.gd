extends HBoxContainer


var carte_hovered = -1


func update(combattant):
	for sort in get_children():
		sort.queue_free()
	if GlobalData.is_multijoueur and get_parent().combattant_selection:
		if get_parent().combattant_selection.equipe == 1 and Client.is_host or get_parent().combattant_selection.equipe == 0 and not Client.is_host:
			return
	var sort_id = 0
	for sort in combattant.sorts:
		if sort_id >= combattant.compte_sorts:
			var texture_rect = TextureRect.new()
			var sprite = Sprite2D.new()
			var carte = Sprite2D.new()
			var label = Label.new()
			
			texture_rect.texture = load("res://UI/Logos/Spells/Bonus/" + sort.nom + ".png")
			
			sprite.texture = load("res://Fight/Images/logo_cover.png")
			sprite.position = Vector2(19, 20)
			sprite.scale = Vector2(1.05, 1.05)
			
			carte.texture = load("res://Classes/Bonus/Sorts/" + sort.nom + ".png")
			carte.position = Vector2(90, -200)
			carte.scale = Vector2(1, 1)
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
			
			texture_rect.connect("mouse_entered", sort_hovered.bind(texture_rect, sort_id))
			texture_rect.connect("mouse_exited", sort_exited.bind(texture_rect))
		sort_id += 1


func sort_hovered(sort, sort_id):
	sort.get_node("carte").visible = true
	carte_hovered = sort_id


func sort_exited(sort):
	sort.get_node("carte").visible = false
	carte_hovered = -1


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if carte_hovered > 0 and get_parent().etat == 1:
			get_parent().spell_pressed = true
			get_parent().change_action(carte_hovered)
