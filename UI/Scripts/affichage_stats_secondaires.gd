extends TextureRect


func update(id):
	var personnage = GlobalData.equipe_actuelle.personnages[id]
	get_node("GridContainer/Dommages/Air").text = str(personnage.stats.dommages_air) + "%"
	get_node("GridContainer/Dommages/Terre").text = str(personnage.stats.dommages_terre) + "%"
	get_node("GridContainer/Dommages/Feu").text = str(personnage.stats.dommages_feu) + "%"
	get_node("GridContainer/Dommages/Eau").text = str(personnage.stats.dommages_eau) + "%"
	get_node("GridContainer/Resistances/Air").text = str(personnage.stats.resistances_air) + "%"
	get_node("GridContainer/Resistances/Terre").text = str(personnage.stats.resistances_terre) + "%"
	get_node("GridContainer/Resistances/Feu").text = str(personnage.stats.resistances_feu) + "%"
	get_node("GridContainer/Resistances/Eau").text = str(personnage.stats.resistances_eau) + "%"
	get_node("GridContainer/Capacites/Portee").text = "+" + str(personnage.stats.po)
	get_node("GridContainer/Capacites/Esquive").text = str(personnage.stats.esquive) + "%"
	get_node("GridContainer/Capacites/Blocage").text = str(personnage.stats.blocage) + "%"
	get_node("GridContainer/Capacites/Soins").text = str(personnage.stats.soins) + "%"
	get_node("GridContainer/Capacites/CC").text = str(personnage.stats.cc) + "%"
	get_node("GridContainer/Capacites/RenvoiDmg").text = str(personnage.stats.renvoi_dommage) + "%"
