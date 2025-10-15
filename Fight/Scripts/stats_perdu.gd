extends Label
class_name StatsPerdu


var queue: Array
var init_position: Vector2


func _ready():
	queue = []
	text = ""
	label_settings = LabelSettings.new()
	init_position = position


func _process(_delta):
	if len(queue) > 0:
		if text.is_empty():
			set_data(queue[0][0], queue[0][1])
		position -= Vector2(0, 0.5)
		if position.y < -150:
			position = init_position
			queue.pop_front()
			text = ""


func ajoute(valeur: int, stat: String):
	if valeur == 0:
		return
	queue.append([valeur, stat])


func set_data(valeur: int, stat: String):
	if stat == "pa":
		label_settings.font_color = Color.BLUE
	if stat == "pm":
		label_settings.font_color = Color.GREEN
	if stat == "hp":
		label_settings.font_color = Color.RED
	
	if valeur > 0:
		text = "+" + str(valeur) + stat.to_upper()
	else:
		text = str(valeur) + stat.to_upper()
