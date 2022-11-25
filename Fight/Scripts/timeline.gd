extends HBoxContainer


var fond_rouge = preload("res://Fight/Images/timeline_rouge.png")
var fond_bleu = preload("res://Fight/Images/timeline_bleu.png")
var start_x: float
var max_x: float
var x_spacing: float = 73.3

@onready var fleche = $Fleche


func init(combattants):
	for combattant in combattants:
		var fond = TextureButton.new()
		if combattant.equipe == 0:
			fond.texture_normal = fond_bleu
		else:
			fond.texture_normal = fond_rouge
		add_child(fond)
		var combattant_sprite = Sprite2D.new()
		combattant_sprite.position = Vector2(38, 60)
		combattant_sprite.texture = combattant.classe_sprite.texture
		fond.add_child(combattant_sprite)
	start_x = fleche.position.x
	max_x = start_x + (x_spacing * (len(combattants) - 1))

func select(id):
	fleche.position.x = start_x + id * x_spacing
