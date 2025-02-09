extends CanvasLayer


func show_countdown():
	$CountLabel.show()
	
func hide_countdown():
	$CountLabel.hide()
	
func set_countdown(t : int):
	$CountLabel.text = str(t)
	
func show_scores(scores : Array[int]):
	return
	var scoreline = ""
	for i in range(scores.size()):
		scoreline += "P" + str(i+1) + ": " + str(scores[i]) + " "
	$Scores.show()
	$Scores.text = scoreline
	
func hide_scores():
	$Scores.hide()	
	
func show_winner(winner_num: int) -> void:
	$Winner.show()
	$Winner.text = "Player " + str(winner_num) + " wins!"
	
func hide_winner() -> void:
	$Winner.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
