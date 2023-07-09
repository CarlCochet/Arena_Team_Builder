extends TextureRect


var carte_hovered: int = -1
@onready var carte: Sprite2D = $carte
@export var is_popup: bool


func update(combattant: Combattant):
	var nom_arme: String = combattant.equipements["Armes"] if not combattant.equipements["Armes"].is_empty() else "poing"
	carte.texture = load("res://Equipements/Armes/" + nom_arme + ".png")
	carte.position = Vector2(130, -200)
	carte.scale = Vector2(1, 1)
	carte.name = "carte"
	carte.visible = false


func _on_mouse_entered():
	get_node("carte").visible = true
	carte_hovered = 0


func _on_mouse_exited():
	get_node("carte").visible = false
	carte_hovered = -1


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if (not is_popup) and carte_hovered == 0 and get_parent().etat == 1:
			get_parent().spell_pressed = true
			get_parent().change_action(carte_hovered)
