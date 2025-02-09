extends PanelContainer

const WINNER_TEXT = "Winner: P%d"

var player_sprites = [
	preload("res://assets/player/red-idle.png"),
	preload("res://assets/player/blue-idle.png"),
	preload("res://assets/player/green-idle.png"),
	preload("res://assets/player/yellow-idle.png")
]

func initialize_and_tween(config, current_state, winner, target, tree):
	var ind = 1
	for player in config:
		var summary = $CenterContainer/PanelContainer/Summaries.get_child(ind)
		summary.set_texture(player_sprites[player[3]])
		summary.set_num_visible(target)
		summary.set_num_active(current_state[ind-1])
		if winner == ind:
			summary.tween_icon(current_state[ind-1], tree)
		summary.visible = true
		ind += 1

func set_winner(winner):
	$CenterContainer/PanelContainer/Summaries/Winner.text = WINNER_TEXT % (winner + 1) 
	$CenterContainer/PanelContainer/Summaries/Winner.visible = true
