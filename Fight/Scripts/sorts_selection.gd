extends HBoxContainer
class_name SortsSelection


var carte_hovered: int = -1
@export var is_popup: bool


func update(combattant: Combattant):
	for sort in get_children():
		sort.queue_free()
	var sort_id: int = 1
	for sort: Sort in combattant.sorts:
		if sort.nom != "arme" and sort_id < combattant.compte_sorts:
			var texture_rect := TextureRect.new()
			var sprite := Sprite2D.new()
			var carte := Sprite2D.new()
			var label := Label.new()
			
			texture_rect.texture = sort.icone
			sprite.texture = GlobalData.sort_cover
			sprite.position = Vector2(19, 20)
			sprite.scale = Vector2(1.05, 1.05)
			
			carte.texture = sort.carte
			carte.position = Vector2(130, -200)
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
		if (not is_popup) and carte_hovered > 0 and get_parent().etat == 1:
			get_parent().spell_pressed = true
			get_parent().change_action(carte_hovered)
