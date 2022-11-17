extends TextureRect


@onready var pm: Label = $PM
@onready var hp: Label = $HP
@onready var ini: Label = $Ini
@onready var pa: Label = $PA
@onready var kamas: Label = $Kamas


func update(id):
	var personnage = GlobalData.equipe_actuelle.personnages[id]
	pm.text = str(personnage.stats.pm)
	hp.text = str(personnage.stats.hp)
	ini.text = str(personnage.stats.initiative)
	pa.text = str(personnage.stats.pa)
	kamas.text = str(personnage.stats.kamas)
