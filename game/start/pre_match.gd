extends PanelContainer

const PLAYER_NAME_TEMPLATE = "P%d"
const MIN_PLAYERS := 2

var matchScene: PackedScene = preload("res://game/match.tscn")

var winLabel : Label
var winGoal := 3
var players_joined := 0

func _ready() -> void:
	winLabel = $MarginContainer/VBoxContainer/MiddleRow/Panel/HBoxContainer/WinLabel
	winLabel.text = str(winGoal)

func _input(event: InputEvent) -> void:
	var device = InputDevice.fromInputEvent(event)
	if not event.is_pressed():
		return
	if event.is_action("join_game"):
		handle_player_join(device)
	#elif event.is_action("leave_game"):
		#handle_player_leave(device)
	#elif event.is_action("start_game"):
		#handle_match_start()
	

func handle_player_join(device: InputDevice):
	if is_player_joined(device):
		handle_player_leave(device)
		return
	var playerInd = 1
	for child in $MarginContainer/VBoxContainer/PlayerJoinBlocks.get_children():
		if child.inputDevice == null:
			child.set_player_joined(device, PLAYER_NAME_TEMPLATE % playerInd)
			players_joined += 1
			if (players_joined >= MIN_PLAYERS):
				$MarginContainer/VBoxContainer/MarginContainer/BottomRow/StartButton.disabled = false
			$PlayerJoin.play(0)
			break
		playerInd += 1

func handle_player_leave(device: InputDevice):
	for child in $MarginContainer/VBoxContainer/PlayerJoinBlocks.get_children():
		if child.inputDevice and child.inputDevice.equals(device):
			child.set_player_left()
			players_joined -= 1
			if (players_joined >= MIN_PLAYERS):
				$MarginContainer/VBoxContainer/MarginContainer/BottomRow/StartButton.disabled = true
			$PlayerLeave.play(0)
			break

func handle_match_start():
	var players = []
	var ind = 0
	for child in $MarginContainer/VBoxContainer/PlayerJoinBlocks.get_children():
		if child.inputDevice:
			var data = child.get_player_data()
			data.push_back(ind)
			players.push_back(data)
		ind += 1
	if players.size() < MIN_PLAYERS:
		return
		
	$StartGame.play(0)
	$StartTimer.start()
	await $StartTimer.timeout
	
	var matchInst = matchScene.instantiate()
	matchInst.initialize_game(players, winGoal)
	get_tree().root.add_child(matchInst)
	matchInst.start_match()
	queue_free()

func is_player_joined(device: InputDevice):
	for child in $MarginContainer/VBoxContainer/PlayerJoinBlocks.get_children():
		if child.inputDevice and child.inputDevice.equals(device):
			return true
	return false
	



func _on_left_button_pressed() -> void:
	winGoal = clamp(winGoal-1, 1, 7)
	winLabel.text = str(winGoal)


func _on_right_button_pressed() -> void:
	winGoal = clamp(winGoal+1, 1, 7)
	winLabel.text = str(winGoal)
	


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/start/start_screen.tscn")


func _on_start_button_pressed() -> void:
	handle_match_start()
