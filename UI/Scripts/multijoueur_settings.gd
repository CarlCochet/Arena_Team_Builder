extends Control
class_name MultijoueurSettings


@onready var classes: Array[CheckBox] = $Settings/Conditions/ChoixClasses/Classes/Checkboxes.get_children()
@onready var conditions_values: Array[Label] = $Settings/Conditions/ConditionsDiverses/Conditions/Values.get_children()
@onready var mode_label: Label = $Settings/ModeJeu/Label


func _ready():
	for i in range(len(classes)):
		classes[i].connect("pressed", _on_classe_pressed.bind(i))


func _on_classe_pressed(id: int):
	rpc("classe_pressed", id)


@rpc("any_peer", "call_local")
func classe_pressed(id: int):
	GlobalData.regles_multi["classes"][id] = not GlobalData.regles_multi["classes"][id]
	classes[id].pressed = GlobalData.regles_multi["classes"][id]


func _on_retour_pressed():
	rpc("retour_pressed")


func _on_valider_pressed():
	rpc("valider_pressed")


@rpc("any_peer", "call_local")
func retour_pressed():
	get_tree().change_scene_to_file("res://UI/multijoueur_setup.tscn")


@rpc("any_peer", "call_local")
func valider_pressed():
	get_tree().change_scene_to_file("res://UI/choix_equipe_multi.tscn")


func _on_budget_drag_ended(value_changed: float):
	rpc("update_limite_budget", int(conditions_values[0].text))


func _on_perso_drag_ended(value_changed: float):
	rpc("update_limite_budget", int(conditions_values[1].text))


func _on_ms_drag_ended(value_changed: float):
	rpc("update_limite_budget", int(conditions_values[2].text))


@rpc("any_peer", "call_local")
func update_limite_budget(budget: int):
	GlobalData.regles_multi["budget_max"] = budget


@rpc("any_peer", "call_local")
func update_personnages_max(persos_max: int):
	GlobalData.regles_multi["persos_max"] = persos_max


@rpc("any_peer", "call_local")
func update_tours_avant_ms(tours: int):
	GlobalData.regles_multi["debut_ms"] = tours


func _on_budget_value_changed(value: float):
	conditions_values[0].text = str(int(value))


func _on_perso_value_changed(value: float):
	conditions_values[1].text = str(int(value))


func _on_ms_value_changed(value: float):
	conditions_values[2].text = str(int(value))
