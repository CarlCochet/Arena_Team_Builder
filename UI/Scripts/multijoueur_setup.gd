extends Control


var PORT: int = 55001
@onready var menu: VBoxContainer = $Menu
@onready var adresse: TextEdit = $Menu/Adresse
@onready var texte_attente: Label = $TexteAttente


func _ready():
	Client.reset()
	Client.multiplayer_peer.create_server(PORT)
	Client.multiplayer.multiplayer_peer = Client.multiplayer_peer
	Client.multiplayer_peer.peer_connected.connect(func(id): Client.ajouter_peer(id))


func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE) and event is InputEventKey and not event.echo:
		get_tree().change_scene_to_file("res://UI/menu_principal.tscn")


func _on_heberger_pressed():
	Client.is_host = true
	Client.ajouter_peer(1)
	menu.visible = false
	texte_attente.visible = true


func _on_rejoindre_pressed():
	Client.reset()
	var error = Client.multiplayer_peer.create_client("ws://" + adresse.text + ":" + str(PORT))
	if error == OK:
		Client.multiplayer.multiplayer_peer = Client.multiplayer_peer
		get_tree().change_scene_to_file("res://UI/choix_equipe_multi.tscn")


func _on_retour_pressed():
	Client.reset()
	get_tree().change_scene_to_file("res://UI/menu_principal.tscn")
