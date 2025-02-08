extends Node2D

# Where the game is played, holds the level and players

var playerScene : PackedScene = preload("res://player/player.tscn")

const TOTAL_LEVELS = 2

var playerNum = 0          # number of players in game
var alivePlayers = 0
var playerConfigs = []     # device configs for each player
var playerList : Array[Player] = []  # reference to each player
var playerPoints : Array[int] = []  # Points each player has

var winGoal = 0                    # points to win

var currentLevelIndex : int = -1   # index corresponding to name "level_i"
var currentLevel : Level = null    # current level in play

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
		new_level_index = randi_range(1, TOTAL_LEVELS)
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
		add_child(player)
		player.position = spawnpoint
		player.killed.connect(playerDeath)
		playerList.push_back(player)
		
func clear_players():
	for player in playerList:
		if player != null:
			player.queue_free()
	playerList = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_game([[0,false],[0,true],[1,true],[2,true]], 3)

func playerDeath(playerDied) -> void:
	alivePlayers -= 1	
	for i in range(playerNum):
		if playerList[i] == playerDied:
			playerList[i].queue_free()
			playerList[i] = null
			break
				
		
	print(playerList)
	if alivePlayers != 1:
		return
	print("hey")
	for i in range(playerNum):
		if playerList[i] != null:
			playerPoints[i] += 1
			break
	init_match()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
