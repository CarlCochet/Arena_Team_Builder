extends HBoxContainer


var fond_rouge = preload("res://Fight/Images/timeline_rouge.png")
var fond_bleu = preload("res://Fight/Images/timeline_bleu.png")
var fond_rouge_selected = preload("res://Fight/Images/timeline_rouge_selected.png")
var fond_bleu_selected = preload("res://Fight/Images/timeline_bleu_selected.png")


func init(combattants: Array, select_id):
	for combattant in get_children():
		combattant.queue_free()
	var combattant_id = 0
	for combattant in combattants:
		var texture_rect = TextureRect.new()
		var sprite = Sprite2D.new()
		
		if combattant_id != select_id:
			texture_rect.texture = fond_rouge if combattant.equipe else fond_bleu
		else:
			texture_rect.texture = fond_rouge_selected if combattant.equipe else fond_bleu_selected
		
		sprite.texture = combattant.classe_sprite.texture
		sprite.position = Vector2(38, 60)
		
		add_child(texture_rect)
		texture_rect.add_child(sprite)
		
		texture_rect.connect("gui_input", input_received.bind(combattant_id))
		combattant_id += 1


func input_received(event, combattant_id):
	if not event is InputEventMouseMotion and event.pressed:
		print(combattant_id)
		get_parent().get_node("AffichageCombattant").visible = true
