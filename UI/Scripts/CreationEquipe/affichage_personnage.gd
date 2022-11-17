extends TextureRect


@onready var grid_sorts: GridContainer = $GridSorts
@onready var grid_equipements: GridContainer = $GridEquipements


func update(id):
	for sort in grid_sorts.get_children():
		sort.queue_free()
	for equipement in grid_equipements.get_children():
		equipement.queue_free()
	for sort in GlobalData.equipe_actuelle.personnages[id].sorts:
		var texture_rect = TextureRect.new()
		texture_rect.texture = load(
			"res://UI/Logos/Spells/" + GlobalData.equipe_actuelle.personnages[id].classe + 
			"/" + sort + ".png"
		)
		grid_sorts.add_child(texture_rect)
	for equipement in GlobalData.equipe_actuelle.personnages[id].equipements:
		if GlobalData.equipe_actuelle.personnages[id].equipements[equipement]:
			var path = "res://UI/Logos/Equipements/" + equipement + "/" + GlobalData.equipe_actuelle.personnages[id].equipements[equipement] + ".png"
			var texture_rect = TextureRect.new()
			texture_rect.texture = load(path)
			grid_equipements.add_child(texture_rect)
