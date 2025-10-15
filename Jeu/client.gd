extends Node


var multiplayer_peer: WebSocketMultiplayerPeer
var other_id: int
var peer_count: int
var is_host: bool


func _ready():
	multiplayer_peer = WebSocketMultiplayerPeer.new()
	other_id = 0
	reset()


func _process(_delta):
	multiplayer_peer.poll()


func reset():
	peer_count = 0
	is_host = false


func ajouter_peer(id=1):
	peer_count += 1
	if peer_count == 2:
		other_id = id
		get_tree().change_scene_to_file("res://UI/choix_equipe_multi.tscn")
