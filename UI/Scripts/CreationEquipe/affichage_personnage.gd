extends TextureRect


@onready var personnage: Node2D = $Personnage
@onready var grid_sorts: GridContainer = $GridSorts
@onready var grid_equipements: GridContainer = $GridEquipements
@onready var nom: RichTextLabel = $Nom


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
	nom.text = "[center]" + equipe.personnages[id].nom


func from_combattant(combattant: Combattant):
	for sort in grid_sorts.get_children():
		sort.queue_free()
	for equipement in grid_equipements.get_children():
		equipement.queue_free()
	personnage.get_node("Cape").texture = combattant.personnage.get_node("Cape").texture
	personnage.get_node("Classe").texture = combattant.classe_sprite.texture
	personnage.get_node("Coiffe").texture = combattant.personnage.get_node("Coiffe").texture
	nom.text = "[center]" + combattant.nom
	for equipement in combattant.equipements:
		if combattant.equipements[equipement]:
			var path = "res://UI/Logos/Equipements/" + equipement + "/" + combattant.equipements[equipement] + ".png"
			var texture_rect = TextureRect.new()
			var carte = Sprite2D.new()
			texture_rect.texture = load(path)
			carte.texture = load("res://Equipements/" + equipement + "/" + combattant.equipements[equipement] + ".png")
			carte.position = Vector2(800, 1550)
			carte.scale = Vector2(7, 7)
			carte.name = "carte"
			carte.visible = false
			carte.z_index = 3
			grid_equipements.add_child(texture_rect)
			texture_rect.add_child(carte)
			texture_rect.connect("mouse_entered", item_hovered.bind(texture_rect))
			texture_rect.connect("mouse_exited", item_exited.bind(texture_rect))


func item_hovered(item):
	item.get_node("carte").visible = true

func item_exited(item):
	item.get_node("carte").visible = false
