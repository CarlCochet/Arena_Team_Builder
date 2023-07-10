extends Control


@onready var classes: Array = $Settings/Conditions/ChoixClasses/Classes/Checkboxes.get_children()
@onready var conditions_values: Array = $Settings/Conditions/ConditionsDiverses/Conditions/Values.get_children()
@onready var mode_label: Label = $Settings/ModeJeu/Label


func _ready():
	for i in range(len(classes)):
		classes[i].connect("pressed", _on_class_pressed.bind(i))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mode_jeu_pressed():
	pass


func _on_class_pressed(id: int):
	pass


func _on_retour_pressed():
	pass # Replace with function body.


func _on_valider_pressed():
	pass # Replace with function body.


func _on_budget_drag_ended(value_changed: float):
	pass # Replace with function body.


func _on_perso_drag_ended(value_changed: float):
	pass # Replace with function body.


func _on_ms_drag_ended(value_changed: float):
	pass # Replace with function body.
