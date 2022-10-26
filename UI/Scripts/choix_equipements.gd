extends Control


func _ready():
	get_node("Personnage").texture = load(
		"res://Classes/" + GlobalData.get_perso_actuel().classe + 
		"/" + GlobalData.get_perso_actuel().classe.to_lower() + ".png"
	)
	update_affichage()


func update_affichage():
	get_node("AffichageBudget").update()
	get_node("AffichageStatsPrimaires").update()
	get_node("AffichageStatsSecondaires").update()


func _on_retour_pressed():
	get_tree().change_scene_to_file("res://UI/choix_classe.tscn")


func _on_sorts_pressed():
	get_tree().change_scene_to_file("res://UI/choix_sorts.tscn")
