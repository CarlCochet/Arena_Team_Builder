extends Label


func _process(delta):
	position -= Vector2(0, 0.3)
	if position.y < -150:
		queue_free()


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
		text = "-" + str(valeur) + stat.to_upper()
