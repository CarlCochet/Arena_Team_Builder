extends TextureRect


@onready var dommages_air: Label = $GridContainer/Dommages/Air
@onready var dommages_terre: Label = $GridContainer/Dommages/Terre
@onready var dommages_feu: Label = $GridContainer/Dommages/Feu
@onready var dommages_eau: Label = $GridContainer/Dommages/Eau
@onready var resistances_air: Label = $GridContainer/Resistances/Air
@onready var resistances_terre: Label = $GridContainer/Resistances/Terre
@onready var resistances_feu: Label = $GridContainer/Resistances/Feu
@onready var resistances_eau: Label = $GridContainer/Resistances/Eau
@onready var portee: Label = $GridContainer/Capacites/Portee
@onready var esquive: Label = $GridContainer/Capacites/Esquive
@onready var blocage: Label = $GridContainer/Capacites/Blocage
@onready var soins: Label = $GridContainer/Capacites/Soins
@onready var cc: Label = $GridContainer/Capacites/CC
@onready var renvoi_dmg: Label = $GridContainer/Capacites/RenvoiDmg


func update(id):
	var personnage = GlobalData.equipe_actuelle.personnages[id]
	dommages_air.text = str(personnage.stats.dommages_air) + "%"
	dommages_terre.text = str(personnage.stats.dommages_terre) + "%"
	dommages_feu.text = str(personnage.stats.dommages_feu) + "%"
	dommages_eau.text = str(personnage.stats.dommages_eau) + "%"
	resistances_air.text = str(personnage.stats.resistances_air) + "%"
	resistances_terre.text = str(personnage.stats.resistances_terre) + "%"
	resistances_feu.text = str(personnage.stats.resistances_feu) + "%"
	resistances_eau.text = str(personnage.stats.resistances_eau) + "%"
	portee.text = "+" + str(personnage.stats.po)
	esquive.text = str(personnage.stats.esquive) + "%"
	blocage.text = str(personnage.stats.blocage) + "%"
	soins.text = str(personnage.stats.soins) + "%"
	cc.text = str(personnage.stats.cc) + "%"
	renvoi_dmg.text = str(personnage.stats.renvoi_dommage) + "%"
