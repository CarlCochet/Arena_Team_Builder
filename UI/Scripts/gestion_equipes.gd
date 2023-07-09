extends Control


var previsu = preload("res://UI/Displays/Scenes/previsu_equipe.tscn")
var equipes: Array
var equipe_selectionnee: int

@onready var equipes_grid: GridContainer = $ScrollContainer/Equipes
@onready var affichage_personnages: Control = $AffichageEquipe
@onready var export_dialog: FileDialog = $ExportDialog
@onready var import_dialog: FileDialog = $ImportDialog


func _ready():
	equipes = []
	equipe_selectionnee = 0
	GlobalData.is_multijoueur = false
	discord_sdk.state = "Dans les menus"
	discord_sdk.refresh()
	generer_affichage()


func generer_affichage():
	for i in range(len(GlobalData.equipes)):
		var previsu_equipe = previsu.instantiate()
		previsu_equipe.signal_id = i
		previsu_equipe.connect("pressed", previsu_pressed.bind(i))
		equipes.append(previsu_equipe)
		equipes_grid.add_child(previsu_equipe)
		previsu_equipe.update(i)
	equipes[equipe_selectionnee].button_pressed = true
	affichage_personnages.update(GlobalData.equipe_actuelle)


func previsu_pressed(id):
	equipe_selectionnee = id
	for i in range(len(equipes)):
		if i != id:
			equipes[i].button_pressed = false
		else:
			equipes[i].button_pressed = true
			GlobalData.equipe_actuelle = GlobalData.equipes[i]
			affichage_personnages.update(GlobalData.equipe_actuelle)


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
		affichage_personnages.update(GlobalData.equipe_actuelle)
		GlobalData.sauver_equipes()
	else:
		GlobalData.equipes[equipe_selectionnee] = Equipe.new()
		GlobalData.equipe_actuelle = GlobalData.equipes[equipe_selectionnee]
		equipes_grid.get_children()[equipe_selectionnee].update(equipe_selectionnee)
		affichage_personnages.update(GlobalData.equipe_actuelle)
		GlobalData.sauver_equipes()


func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
		GlobalData.sauver_equipes()
		get_tree().change_scene_to_file("res://UI/menu_principal.tscn")
	if Input.is_key_pressed(KEY_ENTER) and event is InputEventKey and not event.echo:
		_on_editer_pressed()


func _on_retour_pressed():
	get_tree().change_scene_to_file("res://UI/menu_principal.tscn")


func _on_editer_pressed():
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_creer_pressed():
	GlobalData.equipes.append(Equipe.new())
	GlobalData.equipe_actuelle = GlobalData.equipes[-1]
	get_tree().change_scene_to_file("res://UI/creation_equipe.tscn")


func _on_exporter_pressed():
	export_dialog.popup()


func _on_importer_pressed():
	import_dialog.popup()


func _on_export_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(GlobalData.equipe_actuelle.to_json()))


func _on_import_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var equipe_json = JSON.parse_string(file.get_as_text())
	GlobalData.equipes.append(Equipe.new().from_json(equipe_json).sort_ini())
	
	for equipe in equipes_grid.get_children():
		equipe.queue_free()
		equipes_grid.get_children()[equipe_selectionnee].queue_free()
	
	equipe_selectionnee = len(GlobalData.equipes) - 1
	equipes.clear()
	GlobalData.equipe_actuelle = GlobalData.equipes[equipe_selectionnee]
	generer_affichage()
	affichage_personnages.update(GlobalData.equipe_actuelle)
	GlobalData.sauver_equipes()
