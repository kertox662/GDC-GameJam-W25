extends Node2D

# Where the game is played, holds the level and players

var playerScene : PackedScene = preload("res://player/player.tscn")
var preMatchScene : PackedScene = load("res://game/start/pre_match.tscn")
var summaryScene: PackedScene = preload("res://game/round_summary.tscn")
var HUD

const TOTAL_LEVELS = 5

var playerNum = 0          # number of players in game
var alivePlayers = 0
var playerConfigs = []     # device configs for each player
var playerList : Array[Player] = []  # reference to each player
var playerPoints : Array[int] = []  # Points each player has

var winGoal = 0                    # points to win

var currentLevelIndex : int = -1   # index corresponding to name "level_i"
var currentLevel : Level = null    # current level in play

var player_animations = [
	preload("res://player/red_player_sprites.tres"),
	preload("res://player/blue_player_sprites.tres"),
	preload("res://player/green_player_sprites.tres"),
	preload("res://player/yellow_player_sprites.tres"),
]
var blockPlayerInput := false

var matchState = "INITIALIZING"

func initialize_game(configs:Array, win_goal:int) -> void:
	playerNum = configs.size()
	playerConfigs = configs
	for i in range(playerNum):
		playerPoints.append(0)
	winGoal = win_goal
	
	init_match()

func init_match(level_index : int = -1) -> void:
	clear_players()
	
	var new_level_index
	if level_index == -1:
		new_level_index = randi_range(2, TOTAL_LEVELS)
	else: new_level_index = level_index
	
	alivePlayers = playerNum
	if new_level_index != currentLevelIndex:
		if currentLevel != null:
			currentLevel.queue_free()
		var levelScene : PackedScene = load("res://game/level/levels/level_" + str(new_level_index) + ".tscn")
		currentLevel = levelScene.instantiate()
		add_child(currentLevel)
		
	var spawnpoints : Array[Vector2] = currentLevel.get_spawnpoints()
	
	for i in playerNum:
		var spawnpoint : Vector2 = spawnpoints.pop_at(randi_range(0, spawnpoints.size()-1))
		var player : Player = playerScene.instantiate()
		player.deviceId = playerConfigs[i][0]
		player.useController = playerConfigs[i][1]
		player.get_node("AnimatedSprite2D").sprite_frames = player_animations[playerConfigs[i][3]]
		add_child(player)
		player.position = spawnpoint
		player.killed.connect(playerDeath)
		playerList.push_back(player)
		
func start_match():
	blockPlayerInput = true
	for player in playerList:
		player.disable_shooting()
	
	matchState = "STARTING"
	HUD.show_countdown()
	$StartTimer.start()
	await $StartTimer.timeout
	
	matchState = "PLAYING"
	HUD.hide_countdown()
	blockPlayerInput = false
	for player in playerList:
		if player:
			player.enable_shooting()
		
func clear_players():
	for player in playerList:
		if player != null:
			player.queue_free()
	playerList = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HUD = $MatchHUD

# called when each player died
func playerDeath(playerDied) -> void:
	alivePlayers -= 1	
	
	# find and free dead players
	for i in range(playerNum):
		if playerList[i] == playerDied:
			playerList[i].queue_free()
			playerList[i] = null
			break
				
	
	if alivePlayers != 1:
		return
		
	# only one player standing
	
	var summary = null
	
	var winner := 0
	# give player point, and make invincible
	for i in range(playerNum):
		if playerList[i] != null:
			playerList[i].invincible = true
			summary = summaryScene.instantiate()
			summary.initialize_and_tween(playerConfigs, playerPoints, i+1, winGoal, get_tree())
			HUD.add_child(summary)
			playerPoints[i] += 1
			if playerPoints[i] >= winGoal:
				winner = i + 1
				
			break
	
	if winner > 0:
		matchState = "GAMEOVER"
		#HUD.show_winner(winner)
		summary.set_winner(winner)
	else:
		matchState = "MATCHOVER"
		
	HUD.show_scores(playerPoints)
	$win_sound.play()
	$NextMatchTimer.start()
	await $NextMatchTimer.timeout
	if summary:
		summary.queue_free()
	
	if winner > 0:
		var error := get_tree().change_scene_to_packed(preMatchScene)
		queue_free()
		return
	
	HUD.hide_scores()
	get_tree().call_group("projectiles", "queue_free")
	get_tree().call_group("corpses", "queue_free")
	
	get_tree().call_group("projectiles", "queue_free")
	init_match()
	start_match()
		
var count = 0
func _input(event: InputEvent) -> void:
	if blockPlayerInput and event.is_action("shoot"):
		get_viewport().set_input_as_handled()
		
func _process(delta: float) -> void:
	if matchState == "STARTING":
		HUD.set_countdown(int(ceil($StartTimer.time_left)))
