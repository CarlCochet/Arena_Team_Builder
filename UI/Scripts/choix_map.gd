extends Control


var map_initiale: int
var map_selected: int

@onready var maps: Array = $Maps.get_children()
@onready var mort_subite_check: CheckBox = $MortSubiteCheck


func _ready():
	for i in range(len(maps)):
		maps[i].connect("pressed", _on_map_pressed.bind(i))
	map_initiale = 0
	map_selected = map_initiale
	maps[map_initiale].button_pressed = true


func _on_map_pressed(id):
	map_selected = id
	for i in range(len(maps)):
		if i != id:
			maps[i].button_pressed = false
		else:
			maps[i].button_pressed = true
			GlobalData.map_actuelle = maps[i].name


func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
		_on_fermer_pressed()
	if Input.is_key_pressed(KEY_ENTER) and event is InputEventKey and not event.echo:
		_on_valider_pressed()


func _on_fermer_pressed():
	get_tree().change_scene_to_file("res://UI/choix_ennemis.tscn")


func _on_valider_pressed():
	GlobalData.mort_subite_active = mort_subite_check.button_pressed
	get_tree().change_scene_to_file("res://Fight/combat.tscn")
