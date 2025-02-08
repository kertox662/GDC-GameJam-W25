extends Node
class_name SpawnManager

# Put marker2Ds as children to mark possible spawn points
# returns spawn point locations

func get_spawnpoints() -> Array[Vector2]:
	var spawnpoints : Array[Vector2] = []
	for child in get_children():
		if child is Marker2D:
			spawnpoints.push_back(child.position)
			
	return spawnpoints
			
	
