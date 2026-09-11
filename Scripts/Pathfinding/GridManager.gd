class_name GridManager
extends RefCounted

var map_data: MapData

func _init(p_map_data: MapData = null) -> void:
	map_data = p_map_data

func is_walkable(pos: Vector2i) -> bool:
	if map_data:
		return map_data.is_walkable(pos)
	return false

func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	if map_data:
		return map_data.get_neighbors(pos)
	return []

func get_step_cost(pos: Vector2i) -> float:
	if map_data:
		return map_data.get_step_cost(pos)
	return 1.0

func map_to_world(grid_pos: Vector2i) -> Vector2:
	if map_data:
		return map_data.map_to_world(grid_pos)
	return Vector2.ZERO

func world_to_map(world_pos: Vector2) -> Vector2i:
	if map_data:
		return map_data.world_to_map(world_pos)
	return Vector2i.ZERO
