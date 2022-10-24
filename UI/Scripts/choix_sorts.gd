extends Control


func _on_equipements_pressed():
	get_tree().change_scene_to_file("res://UI/choix_equipements.tscn")


func _on_retour_pressed():
	get_tree().change_scene_to_file("res://UI/choix_classe.tscn")
