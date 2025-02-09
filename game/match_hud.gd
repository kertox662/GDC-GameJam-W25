extends CanvasLayer


func show_countdown():
	$CountLabel.show()
	
func hide_countdown():
	$CountLabel.hide()
	
func set_countdown(t : int):
	$CountLabel.text = str(t)
	
func show_scores(scores : Array[int]):
	var scoreline = ""
	for i in range(scores.size()):
		scoreline += "P" + str(i+1) + ": " + str(scores[i]) + " "
	$Scores.show()
	$Scores.text = scoreline
	
func hide_scores():
	$Scores.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
