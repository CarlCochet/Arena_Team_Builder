extends HBoxContainer


func update(classe: String, sorts: Array):
	for sort in get_children():
		sort.queue_free()
	for sort in sorts:
		if sort.nom != "arme":
			var texture_rect = TextureRect.new()
			texture_rect.texture = load(
				"res://UI/Logos/Spells/" + classe + "/" + sort.nom + ".png"
			)
			add_child(texture_rect)
