extends TextureRect
class_name AffichagePersonnage


@onready var grid_sorts: GridContainer = $GridSorts
@onready var grid_equipements: GridContainer = $GridEquipements
@onready var nom: RichTextLabel = $Nom
@onready var previsu_personnage: PrevisuPersonnage = $PrevisuPersonnage


func update(id: int, equipe: Equipe):
	for sort in grid_sorts.get_children():
		sort.queue_free()
	for equipement in grid_equipements.get_children():
		equipement.queue_free()

	var personnage: Personnage = equipe.personnages[id]
	previsu_personnage.update(personnage, 0)
	
	for sort in personnage.sorts:
		var texture_rect = TextureRect.new()
		texture_rect.texture = GlobalData.sorts[sort].icone
		grid_sorts.add_child(texture_rect)
	for equipement in personnage.equipements:
		if personnage.equipements[equipement]:
			var texture_rect = TextureRect.new()
			texture_rect.texture = GlobalData.equipements[personnage.equipements[equipement]].icone
			grid_equipements.add_child(texture_rect)
	nom.text = "[center]" + personnage.nom


func from_combattant(combattant: Combattant):
	for sort in grid_sorts.get_children():
		sort.queue_free()
	for equipement in grid_equipements.get_children():
		equipement.queue_free()
		
	previsu_personnage.from_previsu(combattant.previsu_personnage)
	
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
