extends Combattant
class_name Invocation


@onready var hitbox: Area2D = $Area2D


func _ready():
	effets = []
	classe_sprite.material = ShaderMaterial.new()
	classe_sprite.material.shader = outline_shader
	classe_sprite.material.set_shader_parameter("width", 0.0)
	is_selected = false
	is_hovered = false
	hp_label.text = str(stats.hp) + "/" + str(max_stats.hp)
	update_hitbox()


func update_hitbox():
	match classe:
		"Tofu":
			classe_sprite.position = Vector2(0, -10)
			hitbox.position = Vector2(0, -10)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -60)
		"Bouftou":
			classe_sprite.position = Vector2(0, -13)
			hitbox.position = Vector2(0, -13)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"Craqueleur":
			classe_sprite.position = Vector2(0, -40)
			hitbox.position = Vector2(0, -40)
			hitbox.scale = Vector2(3, 5)
			hp.position = Vector2(0, -120)
		"Prespic":
			classe_sprite.position = Vector2(0, -17)
			hitbox.position = Vector2(0, -15)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"La_Bloqueuse":
			classe_sprite.position = Vector2(0, -25)
			hitbox.position = Vector2(0, -20)
			hitbox.scale = Vector2(2, 2.5)
			hp.position = Vector2(0, -80)
		"La_Folle":
			classe_sprite.position = Vector2(0, -17)
			hitbox.position = Vector2(0, -20)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"La_Sacrifiee":
			classe_sprite.position = Vector2(0, -20)
			hitbox.position = Vector2(0, -12)
			hitbox.scale = Vector2(2, 2)
			hp.position = Vector2(0, -70)
		"Arbre":
			classe_sprite.position = Vector2(0, -60)
			hitbox.position = Vector2(0, -50)
			hitbox.scale = Vector2(2, 5)
			hp.position = Vector2(0, -120)
		"Double":
			classe_sprite.position = Vector2(0, -48)
			hitbox.position = Vector2(0, -38)
			hitbox.scale = Vector2(2, 4)
			hp.position = Vector2(0, -110)
		"Cadran_De_Xelor":
			classe_sprite.position = Vector2(0, -35)
			hitbox.position = Vector2(0, -30)
			hitbox.scale = Vector2(2, 3)
			hp.position = Vector2(0, -80)


func _input(event):
	pass
