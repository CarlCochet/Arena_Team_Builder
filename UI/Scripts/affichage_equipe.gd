extends Control
class_name AffichageEquipe


@onready var fond_equipes: Array = $FondEquipe.get_children()


func update(equipe: Equipe) -> void:
	if not equipe.personnages:
		return
	
	for i in range(6):
		var affichage_personnage: AffichagePersonnage = fond_equipes[i]
		affichage_personnage.update(i, equipe)
