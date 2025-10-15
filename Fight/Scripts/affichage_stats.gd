extends TextureRect
class_name AffichageStats


@onready var hp: Label = $Stats/HP
@onready var pa: Label = $Stats/PA
@onready var pm: Label = $Stats/PM
@onready var ini: Label = $Stats/Ini
@onready var po: Label = $Stats/PO
@onready var cc: Label = $Stats/CC
@onready var dommages_air: Label = $Stats/DommageAir
@onready var dommages_terre: Label = $Stats/DommageTerre
@onready var dommages_feu: Label = $Stats/DommageFeu
@onready var dommages_eau: Label = $Stats/DommageEau
@onready var blocage: Label = $Stats/Blocage
@onready var soins: Label = $Stats/Soins
@onready var resistances_air: Label = $Stats/ResitanceAir
@onready var resistances_terre: Label = $Stats/ResistanceTerre
@onready var resistances_feu: Label = $Stats/ResistanceFeu
@onready var resistances_eau: Label = $Stats/ResistanceEau
@onready var esquive: Label = $Stats/Esquive
@onready var renvoi: Label = $Stats/Renvoi


func update(stats_actuelles: Stats, stats_max: Stats):
	hp.text = str(stats_actuelles.hp) + "/" + str(stats_max.hp)
	pa.text = str(stats_actuelles.pa)
	pm.text = str(stats_actuelles.pm)
	ini.text = str(stats_actuelles.initiative)
	po.text = "+" + str(stats_actuelles.po)
	cc.text = str(stats_actuelles.cc) + "%"
	dommages_air.text = str(stats_actuelles.dommages_air) + "%"
	dommages_terre.text = str(stats_actuelles.dommages_terre) + "%"
	dommages_feu.text = str(stats_actuelles.dommages_feu) + "%"
	dommages_eau.text = str(stats_actuelles.dommages_eau) + "%"
	blocage.text = str(stats_actuelles.blocage) + "%"
	soins.text = str(stats_actuelles.soins) + "%"
	resistances_air.text = str(stats_actuelles.resistances_air) + "%"
	resistances_terre.text = str(stats_actuelles.resistances_terre) + "%"
	resistances_feu.text = str(stats_actuelles.resistances_feu) + "%"
	resistances_eau.text = str(stats_actuelles.resistances_eau) + "%"
	esquive.text = str(stats_actuelles.esquive) + "%"
	renvoi.text = str(stats_actuelles.renvoi_dommage) + "%"
