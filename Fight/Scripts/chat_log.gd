extends Control


var lignes: Array
var VERT: String = "[color=#58B539]"
var JAUNE: String = "[color=yellow]"
var AIR: String = "[color=#53E050]"
var TERRE: String = "[color=#A37649]"
var FEU: String = "color=#D33434]"
var EAU: String = "[color=#428FB5]"
var NEUTRE: String = "[color=white]"


@onready var chat: RichTextLabel = $ChatText
@onready var background: ColorRect = $Background


func _ready():
	lignes = []


func stats(cible: Combattant, valeur: int, stat: String, duree: int):
	pass


func critique():
	ajoute_text(JAUNE + "Coup critique!")


func dommages(cible: Combattant, valeur: int, element: String):
	pass


func sort(lanceur: Combattant, nom_sort: String):
	pass


func etat(cible: Combattant, etat: String, duree: int):
	pass


func ajoute_text(text: String):
	lignes.append(text)
	
	if len(lignes) > 100:
		lignes.pop_front()
	
	chat.text = ""
	for ligne in lignes:
		chat.text += ligne + "\n"


func _on_chat_button_pressed():
	background.visible = not background.visible
	chat.visible = not chat.visible
