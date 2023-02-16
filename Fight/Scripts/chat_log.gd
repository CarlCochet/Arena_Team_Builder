extends Control


var lignes: Array
var VERT: String = "[color=#58B539]"
var JAUNE: String = "[color=yellow]"
var AIR: String = "[color=#53E050]"
var TERRE: String = "[color=#A37649]"
var FEU: String = "[color=#D33434]"
var EAU: String = "[color=#428FB5]"
var NEUTRE: String = "[color=white]"
var SOIN: String = "[color=pink]"


@onready var chat: RichTextLabel = $ChatText
@onready var background: ColorRect = $Background


func _ready():
	lignes = []


func stats(cible: Combattant, valeur: int, stat: String, duree: int, tag_cible: String):
	var nom = cible.nom if tag_cible.is_empty() else tag_cible
	var text = VERT + "[b]" + nom + "[/b] " + VERT
	text += "perd " if valeur < 0 else "gagne "
	if stat in ["dommages_air", "resistances_air"]:
		text += AIR
	if stat in ["dommages_terre", "resistances_terre"]:
		text += TERRE
	if stat in ["dommages_feu", "resistances_feu"]:
		text += FEU
	if stat in ["dommages_eau", "resistances_eau"]:
		text += EAU
	text += str(abs(valeur))
	if not stat in ["pa", "pm", "hp", "po", "invocations"]:
		text += "%"
	if stat in ["pa", "pm", "hp", "po", "cc"]:
		stat = stat.to_upper()
	text += VERT + " " + stat.replace("_", " ")
	if duree > 0:
		text += " (" + str(duree) + " tours)"
	text += "."
	ajoute_text(text)


func critique():
	ajoute_text(JAUNE + "Coup critique!")


func dommages(cible: Combattant, valeur: int, element: String):
	var text = VERT + "[b]" + cible.nom + "[/b] " + VERT
	text += "perd " if valeur < 0 else "gagne "
	if element == "dommages_air":
		text += AIR
	if element == "dommages_terre":
		text += TERRE
	if element == "dommages_feu":
		text += FEU
	if element == "dommages_eau":
		text += EAU
	if element == "soin":
		text += SOIN
	if element.is_empty():
		text += NEUTRE
	text += str(abs(valeur)) + VERT + " PV."
	ajoute_text(text)


func sort(lanceur: Combattant, nom_sort: String):
	ajoute_text(VERT + "[b]" + lanceur.nom + "[/b]" + VERT + " lance [b]" + nom_sort.replace("_", " ") + "[/b].")


func generic(cible: Combattant, text: String):
	if cible == null:
		ajoute_text(VERT + text + ".")
	else:
		ajoute_text(VERT + "[b]" + cible.nom + "[/b] " + VERT + text + ".")


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
