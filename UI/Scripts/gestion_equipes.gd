extends Control


var previsu = preload("res://UI/Displays/Scenes/previsu_equipe.tscn")
var equipes_grid
var equipes: Array
var affichage_personnages
var equipe_selectionnee: int


func _ready():
	equipes_grid = get_node("ScrollContainer/Equipes")
	affichage_personnages = get_node("AffichageEquipe")
	equipes = []
	GlobalData.charger_equipes()
	generer_affichage()


func generer_affichage():
	for i in range(len(GlobalData.equipes)):
		var previsu_equipe = previsu.instantiate()
		previsu_equipe.signal_id = i
		previsu_equipe.connect("pressed", previsu_pressed.bind(i))
		equipes.append(previsu_equipe)
		equipes_grid.add_child(previsu_equipe)
		previsu_equipe.update(i)
	equipes[0].button_pressed = true
	affichage_personnages.update()


func previsu_pressed(id):
	equipe_selectionnee = id
	for i in range(len(equipes)):
		if i != id:
			equipes[i].button_pressed = false
		else:
			equipes[i].button_pressed = true
			GlobalData.equipe_actuelle = GlobalData.equipes[i]
			affichage_personnages.update()


func _on_supprimer_pressed():
	if len(GlobalData.equipes) > 1:
		GlobalData.equipes.remove_at(equipe_selectionnee)
		equipes.remove_at(equipe_selectionnee)
		for equipe in equipes_grid.get_children():
			equipe.queue_free()
			equipes_grid.get_children()[equipe_selectionnee].queue_free()
		equipe_selectionnee = 0
		equipes.clear()
		GlobalData.equipe_actuelle = GlobalData.equipes[equipe_selectionnee]
		generer_affichage()
		affichage_personnages.update()
		GlobalData.sauver_equipes()
	else:
		GlobalData.equipes[equipe_selectionnee] = Equipe.new()
		GlobalData.equipe_actuelle = GlobalData.equipes[equipe_selectionnee]
		equipes_grid.get_children()[equipe_selectionnee].update(equipe_selectionnee)
		affichage_personnages.update()
		GlobalData.sauver_equipes()


func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and not event.echo:
		GlobalData.sauver_equipes()
		get_tree().quit()
	if event is InputEventKey and event.keycode == KEY_ENTER and not event.echo:
		get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_editer_pressed():
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_creer_pressed():
	GlobalData.equipes.append(Equipe.new())
	GlobalData.equipe_actuelle = GlobalData.equipes[-1]
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_exporter_pressed():
	$ExportDialog.popup()


func _on_importer_pressed():
	$ImportDialog.popup()


func _on_export_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(GlobalData.equipe_actuelle.to_json()))


func _on_import_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var equipe_json = JSON.parse_string(file.get_as_text())
	GlobalData.equipes.append(Equipe.new().from_json(equipe_json))
	
	var previsu_equipe = previsu.instantiate()
	var equipe_id = len(equipes) - 1
	previsu_equipe.connect("pressed", previsu_pressed.bind(equipe_id))
	equipes.append(previsu_equipe)
	equipes_grid.add_child(previsu_equipe)
	
	previsu_equipe.update(equipe_id)
	equipes[equipe_selectionnee].button_pressed = false
	equipes[-1].button_pressed = true
	GlobalData.equipe_actuelle = GlobalData.equipes[-1]
	equipe_selectionnee = equipe_id
	affichage_personnages.update()
	
	GlobalData.sauver_equipes()
