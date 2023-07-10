extends Control


var map_initiale: int
var map_selected: int

@onready var maps: Array = $MapScroll/Maps.get_children()
@onready var mort_subite_check: CheckBox = $MortSubiteCheck


func _ready():
	GlobalData.rng.randomize()
	discord_sdk.state = "Dans les menus"
	discord_sdk.start_timestamp = 0
	discord_sdk.refresh()
	for i in range(len(maps)):
		maps[i].connect("pressed", _on_map_pressed.bind(i))
	map_initiale = 0
	map_selected = map_initiale
	maps[map_initiale].button_pressed = true
	mort_subite_check.button_pressed = true


func _on_map_pressed(id):
	rpc("map_pressed", id)


func _on_mort_subite_check_pressed():
	rpc("ms_pressed", mort_subite_check.button_pressed)


func _on_fermer_pressed():
	if not GlobalData.is_multijoueur:
		get_tree().change_scene_to_file("res://UI/choix_ennemis.tscn")
	else:
		rpc("fermer_pressed")


func _on_valider_pressed():
	rpc("setup_seed", GlobalData.rng.seed)
	rpc("valider_pressed")


func _on_aleatoire_pressed():
	rpc("setup_seed", GlobalData.rng.seed)
	rpc("aleatoire_pressed")


@rpc("any_peer", "call_local")
func map_pressed(id):
	map_selected = id
	for i in range(len(maps)):
		if i != id:
			maps[i].button_pressed = false
		else:
			maps[i].button_pressed = true
			GlobalData.map_actuelle = maps[i].name


@rpc("any_peer")
func ms_pressed(button_pressed: bool):
	mort_subite_check.button_pressed = button_pressed


@rpc("any_peer", "call_local")
func fermer_pressed():
	get_tree().change_scene_to_file("res://UI/choix_equipe_multi.tscn")


@rpc("any_peer", "call_local")
func valider_pressed():
	GlobalData.mort_subite_active = mort_subite_check.button_pressed
	get_tree().change_scene_to_file("res://Fight/combat.tscn")


@rpc("any_peer", "call_local")
func aleatoire_pressed():
	var random_map = GlobalData.rng.randi_range(0, len(maps) - 1)
	GlobalData.map_actuelle = maps[random_map].name
	GlobalData.mort_subite_active = mort_subite_check.button_pressed
	get_tree().change_scene_to_file("res://Fight/combat.tscn")


@rpc("any_peer", "call_local")
func setup_seed(server_seed):
	GlobalData.rng.seed = server_seed


func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
		_on_fermer_pressed()
	if Input.is_key_pressed(KEY_ENTER) and event is InputEventKey and not event.echo:
		_on_valider_pressed()
