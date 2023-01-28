extends Popup


@onready var affichage_personnage = $UI/AffichagePersonnage
@onready var affichage_stats = $UI/AffichageStats
@onready var etats = $UI/Scroll/Etats
@onready var sorts = $UI/ContainerSorts/Sorts


func update(combattant_id: int):
	var combattant = get_parent().combattants[combattant_id]
	affichage_personnage.from_combattant(combattant)
	affichage_stats.update(combattant.stats, combattant.max_stats)
	sorts.update(combattant)
	update_etats(combattant)


func update_etats(combattant):
	for effet in combattant.effets:
		pass

