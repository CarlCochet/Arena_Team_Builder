extends Control


func _on_fermer_pressed():
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_valider_pressed():
	get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")
