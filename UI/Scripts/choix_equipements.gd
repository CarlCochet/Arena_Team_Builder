extends Control


func _on_retour_pressed():
	get_tree().change_scene_to_file("res://UI/choix_classe.tscn")


func _on_sorts_pressed():
	get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")
