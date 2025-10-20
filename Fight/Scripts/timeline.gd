extends HBoxContainer
class_name Timeline


var fond_rouge = preload("res://Fight/Images/timeline_rouge.png")
var fond_bleu = preload("res://Fight/Images/timeline_bleu.png")
var fond_rouge_selected = preload("res://Fight/Images/timeline_rouge_selected.png")
var fond_bleu_selected = preload("res://Fight/Images/timeline_bleu_selected.png")


func init(combattants: Array, select_id):
	for combattant in get_children():
		combattant.queue_free()
	var combattant_id: int = 0
	for combattant in combattants:
		var texture_rect := TextureRect.new()
		var cape_sprite := Sprite2D.new()
		var classe_sprite := Sprite2D.new()
		var coiffe_sprite := Sprite2D.new()
		texture_rect.name = "timeline_" + str(combattant_id)
		if combattant_id != select_id:
			texture_rect.texture = fond_rouge if combattant.equipe else fond_bleu
		else:
			texture_rect.texture = fond_rouge_selected if combattant.equipe else fond_bleu_selected
		
		cape_sprite.texture = combattant.personnage.get_node("Cape").texture
		cape_sprite.position = Vector2(38, 60)
		classe_sprite.texture = combattant.classe_sprite.texture
		classe_sprite.position = Vector2(38, 60)
		coiffe_sprite.texture = combattant.personnage.get_node("Coiffe").texture
		coiffe_sprite.position = Vector2(38, 60)
		
		add_child(texture_rect)
		texture_rect.connect("gui_input", input_received.bind(combattant_id))
		
		texture_rect.add_child(cape_sprite)
		texture_rect.add_child(classe_sprite)
		texture_rect.add_child(coiffe_sprite)
		combattant_id += 1
	var affichage_tour := Label.new()
	var label_settings := LabelSettings.new()
	label_settings.font_size = 40
	affichage_tour.text = str(get_parent().tour)
	affichage_tour.label_settings = label_settings
	add_child(affichage_tour)


func input_received(event, combattant_id):
	if not event is InputEventMouseMotion and event.pressed:
		get_parent().get_node("AffichageCombattant").visible = true
		get_parent().get_node("AffichageCombattant").update(combattant_id)
