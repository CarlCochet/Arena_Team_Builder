extends Control


func _ready():
	GlobalData.charger_equipes()


func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
		GlobalData.sauver_equipes()
		get_tree().quit()
	if Input.is_key_pressed(KEY_ENTER) and event is InputEventKey and not event.echo:
		get_tree().change_scene_to_file("res://UI/gestion_equipes.tscn")


func _on_builder_pressed():
	get_tree().change_scene_to_file("res://UI/gestion_equipes.tscn")


func _on_multijoueur_pressed():
	get_tree().change_scene_to_file("res://UI/multijoueur_setup.tscn")


func _on_quitter_pressed():
	GlobalData.sauver_equipes()
	get_tree().quit()