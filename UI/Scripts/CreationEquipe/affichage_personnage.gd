extends TextureRect


@onready var sprite_classe: Sprite2D = $SpriteClasse
@onready var grid_sorts: GridContainer = $GridSorts
@onready var grid_equipements: GridContainer = $GridEquipements


func update(id, equipe):
	for sort in grid_sorts.get_children():
		sort.queue_free()
	for equipement in grid_equipements.get_children():
		equipement.queue_free()
	for sort in equipe.personnages[id].sorts:
		var texture_rect = TextureRect.new()
		texture_rect.texture = load(
			"res://UI/Logos/Spells/" + equipe.personnages[id].classe + 
			"/" + sort + ".png"
		)
		grid_sorts.add_child(texture_rect)
	for equipement in equipe.personnages[id].equipements:
		if equipe.personnages[id].equipements[equipement]:
			var path = "res://UI/Logos/Equipements/" + equipement + "/" + equipe.personnages[id].equipements[equipement] + ".png"
			var texture_rect = TextureRect.new()
			texture_rect.texture = load(path)
			grid_equipements.add_child(texture_rect)


func from_combattant(combattant: Combattant):
	for sort in grid_sorts.get_children():
		sort.queue_free()
	for equipement in grid_equipements.get_children():
		equipement.queue_free()
	sprite_classe.texture = combattant.classe_sprite.texture
	for equipement in combattant.equipements:
		if combattant.equipements[equipement]:
			var path = "res://UI/Logos/Equipements/" + equipement + "/" + combattant.equipements[equipement] + ".png"
			var texture_rect = TextureRect.new()
			texture_rect.texture = load(path)
			grid_equipements.add_child(texture_rect)
