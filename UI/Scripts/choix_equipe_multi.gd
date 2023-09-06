extends Control


var previsu = preload("res://UI/Displays/Scenes/previsu_equipe.tscn")
var equipes: Array
var equipe_selectionnee: int
var adversaire_pret: bool

@onready var menu: Control = $Menu
@onready var equipes_grid: GridContainer = $Menu/ScrollContainer/Equipes
@onready var affichage_personnages: Control = $Menu/AffichageEquipe
@onready var attente_hote: Label = $AttenteHote
@onready var attente_adversaire: Label = $AttenteAdversaire


func _ready():
	equipes = []
	equipe_selectionnee = 0
	adversaire_pret = false
	GlobalData.is_multijoueur = true
	generer_affichage()


func generer_affichage():
	for i in range(len(GlobalData.equipes)):
		if not check_condition(i):
			continue
		var previsu_equipe = previsu.instantiate()
		previsu_equipe.signal_id = i
		previsu_equipe.connect("pressed", previsu_pressed.bind(i))
		equipes.append(previsu_equipe)
		equipes_grid.add_child(previsu_equipe)
		previsu_equipe.update(i)
	equipes[equipe_selectionnee].button_pressed = true
	if Client.is_host:
		affichage_personnages.update(GlobalData.equipe_actuelle)
	else:
		affichage_personnages.update(GlobalData.equipe_test)


func check_condition(id: int) -> bool:
	var equipe: Equipe = GlobalData.equipes[id]
	if equipe.budget > GlobalData.regles_multi["budget_max"]:
		return false
	for personnage in equipe.personnages:
		pass
	return true


func previsu_pressed(id):
	equipe_selectionnee = id
	for i in range(len(equipes)):
		if i != id:
			equipes[i].button_pressed = false
		else:
			equipes[i].button_pressed = true
			if Client.is_host:
				GlobalData.equipe_actuelle = GlobalData.equipes[i]
				affichage_personnages.update(GlobalData.equipe_actuelle)
			else:
				GlobalData.equipe_test = GlobalData.equipes[i]
				affichage_personnages.update(GlobalData.equipe_test)


func _on_retour_pressed():
	Client.reset()
	get_tree().change_scene_to_file("res://UI/multijoueur_setup.tscn")
	rpc("retour_pressed")


func _on_valider_pressed():
	var change_scene_check = adversaire_pret
	if Client.is_host:
		if GlobalData.equipe_actuelle.calcul_budget() > 6000:
			return
		rpc("transfert_equipe", GlobalData.equipe_actuelle.to_json())
		attente_adversaire.visible = true
	else:
		if GlobalData.equipe_test.calcul_budget() > 6000:
			return
		rpc("transfert_equipe", GlobalData.equipe_test.to_json())
		attente_hote.visible = true
	menu.visible = false
	if change_scene_check:
		rpc("change_scene")


@rpc("any_peer")
func retour_pressed():
	Client.reset()
	get_tree().change_scene_to_file("res://UI/multijoueur_setup.tscn")


@rpc("any_peer")
func transfert_equipe(equipe: Array):
	if multiplayer.get_remote_sender_id() == 1:
		GlobalData.equipe_actuelle = Equipe.new().from_json(equipe)
	else:
		GlobalData.equipe_test = Equipe.new().from_json(equipe)
	adversaire_pret = true


@rpc("any_peer", "call_local")
func change_scene():
	get_tree().change_scene_to_file("res://UI/choix_map.tscn")


func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
		_on_retour_pressed()
	if Input.is_key_pressed(KEY_ENTER) and event is InputEventKey and not event.echo:
		_on_valider_pressed()
