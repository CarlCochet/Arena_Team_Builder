extends Popup
class_name AffichageCombattant


@onready var affichage_personnage: AffichagePersonnage = $UI/AffichagePersonnage
@onready var affichage_stats: AffichageStats = $UI/AffichageStats
@onready var etats: RichTextLabel = $UI/Etats
@onready var sorts: SortsSelection = $UI/ContainerSorts/Sorts


func update(combattant_id: int):
	var combattant = get_parent().combattants[combattant_id]
	if GlobalData.is_multijoueur and int(Client.is_host) == combattant.equipe and not combattant.is_visible:
		visible = false
		return
	update_etats(combattant)
	affichage_personnage.from_combattant(combattant)
	affichage_stats.update(combattant.stats, combattant.max_stats)
	sorts.update(combattant)


func update_etats(combattant: Combattant):
	var text: String = ""
	etats.text = ""
	var nom_sort: String = ""
	var id_lanceur: int = -1
	var stats = Stats.new().nom_stats
	if GlobalData.is_multijoueur and combattant.combat.tour > 1:
		text += "---------------------------------------------------------------------------------------------------------\n"
		text += "Carte du tour : " + combattant.combat.noms_cartes_combat[0] + "\n"
		for stat in stats:
			var valeur = combattant.stat_cartes_combat[stat]
			if valeur != 0:
				text += ("+" if valeur > 0 else "") + str(valeur) + " " + stat + " (1 tours)\n"
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
