extends PanelContainer

const PLAYER_NAME_TEMPLATE = "P%d"

var matchScene: PackedScene = preload("res://game/match.tscn")

func _input(event: InputEvent) -> void:
	var device = InputDevice.fromInputEvent(event)
	if not event.is_pressed():
		return
	if event.is_action("join_game"):
		handle_player_join(device)
	elif event.is_action("leave_game"):
		handle_player_leave(device)
	elif event.is_action("start_game"):
		handle_match_start()
	

func handle_player_join(device: InputDevice):
	if is_player_joined(device):
		return
	var playerInd = 1
	for child in $VBoxContainer/PlayerJoinBlocks.get_children():
		if child.inputDevice == null:
			child.set_player_joined(device, PLAYER_NAME_TEMPLATE % playerInd)
			break
		playerInd += 1

func handle_player_leave(device: InputDevice):
	for child in $VBoxContainer/PlayerJoinBlocks.get_children():
		if child.inputDevice and child.inputDevice.equals(device):
			child.set_player_left()
			break

func handle_match_start():
	var players = []
	var ind = 0
	for child in $VBoxContainer/PlayerJoinBlocks.get_children():
		if child.inputDevice:
			var data = child.get_player_data()
			data.push_back(ind)
			players.push_back(data)
		ind += 1
	#if players.size() < 2:
		#return
	var matchInst = matchScene.instantiate()
	matchInst.initialize_game(players, 3)
	get_tree().root.add_child(matchInst)
	matchInst.start_match()
	queue_free()

func is_player_joined(device: InputDevice):
	for child in $VBoxContainer/PlayerJoinBlocks.get_children():
		if child.inputDevice and child.inputDevice.equals(device):
			return true
	return false
