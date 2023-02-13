extends Popup


@onready var affichage_personnage = $UI/AffichagePersonnage
@onready var affichage_stats = $UI/AffichageStats
@onready var etats: RichTextLabel = $UI/Etats
@onready var sorts = $UI/ContainerSorts/Sorts


func update(combattant_id: int):
	var combattant = get_parent().combattants[combattant_id]
	update_etats(combattant)
	affichage_personnage.from_combattant(combattant)
	affichage_stats.update(combattant.stats, combattant.max_stats)
	sorts.update(combattant)


func update_etats(combattant):
	var text = ""
	etats.text = ""
	var nom_sort = ""
	var id_lanceur = -1
	var stats = Stats.new().nom_stats
	for effet in combattant.effets:
		if effet.sort.nom != nom_sort or effet.lanceur.id != id_lanceur:
			text += "---------------------------------------------------------------------------------------------------------\n"
			text += effet.sort.nom + " - Lanceur : " + effet.lanceur.nom + "\n"
			nom_sort = effet.sort.nom
			id_lanceur = effet.lanceur.id
		if effet.etat != "":
			text += effet.etat + " (" + str(effet.duree) + " tours)\n"
		for stat in stats:
			var valeur = effet.stats_change[stat]
			if valeur != 0:
				text += ("+" if valeur > 0 else "") + str(valeur) + " " + stat + " (" + str(effet.duree) + " tours)\n"
		if effet.valeur_dommage != 0:
			text += str(effet.valeur_dommage) + " " + effet.categorie + " (" + str(effet.duree) + " tours)\n"
	etats.text = text
