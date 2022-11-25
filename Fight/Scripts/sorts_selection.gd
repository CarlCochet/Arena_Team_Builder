extends HBoxContainer


func update(classe, sorts):
	for sort in get_children():
		sort.queue_free()
	for sort in sorts:
		var texture_rect = TextureRect.new()
		texture_rect.texture = load(
			"res://UI/Logos/Spells/" + classe + "/" + sort + ".png"
		)
		add_child(texture_rect)
