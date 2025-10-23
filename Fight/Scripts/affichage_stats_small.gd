extends TextureRect
class_name AffichageStatsSmall


@onready var hp: Label = $Stats/HP
@onready var pa: Label = $Stats/PA
@onready var pm: Label = $Stats/PM


func update(stats_actuelles: Stats):
	hp.text = str(stats_actuelles.hp)
	pa.text = str(stats_actuelles.pa)
	pm.text = str(stats_actuelles.pm)
