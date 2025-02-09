extends HBoxContainer

const active_colour = Color(1,1,1)
const inactive_colour = Color(0.2,0.2,0.2)
const TWEEN_TIME = 1

func set_num_visible(n: int) -> void:
	var ind = 0
	for icon in $WinSummaries.get_children():
		if ind >= n:
			icon.visible = false
		else:
			icon.visible = true
		ind += 1

func set_num_active(n: int) -> void:
	var ind = 0
	for icon in $WinSummaries.get_children():
		if ind < n:
			icon.modulate = active_colour
		else:
			icon.modulate = inactive_colour
		ind += 1

func set_texture(texture) -> void:
	$TextureRect.texture = texture

func tween_icon(ind: int, tree):
	var tween = tree.create_tween()
	tween.tween_property($WinSummaries.get_child(ind), "modulate", active_colour, TWEEN_TIME)
	
