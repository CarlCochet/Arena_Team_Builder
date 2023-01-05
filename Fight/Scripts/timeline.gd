extends HBoxContainer


var fond_rouge = preload("res://Fight/Images/timeline_rouge.png")
var fond_bleu = preload("res://Fight/Images/timeline_bleu.png")
var fond_rouge_selected = preload("res://Fight/Images/timeline_rouge_selected.png")
var fond_bleu_selected = preload("res://Fight/Images/timeline_bleu_selected.png")


func init(combattants, id):
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var i = 0
	for combattant in combattants:
		var fond = TextureButton.new()
		fond.name = str(combattant.equipe)
		fond.toggle_mode = true
		if i != id:
			fond.texture_normal = fond_rouge if combattant.equipe else fond_bleu
		else:
			fond.texture_normal = fond_rouge_selected if combattant.equipe else fond_bleu_selected
		add_child(fond)
		var combattant_sprite = Sprite2D.new()
		combattant_sprite.position = Vector2(38, 60)
		combattant_sprite.texture = combattant.classe_sprite.texture
		fond.add_child(combattant_sprite)
		i += 1
