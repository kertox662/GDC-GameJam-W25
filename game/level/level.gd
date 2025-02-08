extends Node
class_name Level

# Describes the unique level layout
# Currently just a tilemap and a spawn manager, which holds spawnpoints

func get_spawnpoints() -> Array[Vector2]:
	var spawnManager : SpawnManager = $SpawnManager
	return spawnManager.get_spawnpoints()
			
	
