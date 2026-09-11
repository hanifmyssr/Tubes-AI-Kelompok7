class_name MapData
extends Node2D

## Signal dipancarkan saat data peta selesai dimuat
signal map_loaded

@export var ground_layer: TileMapLayer
@export var obstacle_layer: TileMapLayer

var CELL_SIZE: int = 16
var walkable_cells: Dictionary = {}
var obstacle_cells: Dictionary = {}
var ground_cells: Dictionary = {}

## Raw TileMap bounds – position stores the top-left tile coordinate of the map.
var grid_bounds: Rect2i = Rect2i()

func _ready() -> void:
	find_layers()
	load_map_data()
	map_loaded.emit()

func find_layers() -> void:
	if not ground_layer:
		ground_layer = get_node_or_null("GroundLayer")
	if not obstacle_layer:
		obstacle_layer = get_node_or_null("ObstacleLayer")

func load_map_data() -> void:
	walkable_cells.clear()
	obstacle_cells.clear()
	ground_cells.clear()

	if ground_layer:
		if ground_layer.tile_set:
			CELL_SIZE = ground_layer.tile_set.tile_size.x
		
		# grid_bounds stores the raw TileMap rect (may start at negative coords).
		grid_bounds = ground_layer.get_used_rect()
		var origin: Vector2i = grid_bounds.position

		var ground_used: Array[Vector2i] = ground_layer.get_used_cells()
		for pos in ground_used:
			# Normalize: (0,0) maps to top-left tile of the ground layer.
			ground_cells[pos - origin] = true

	if obstacle_layer:
		var origin: Vector2i = grid_bounds.position
		var obstacle_used: Array[Vector2i] = obstacle_layer.get_used_cells()
		for pos in obstacle_used:
			obstacle_cells[pos - origin] = true

	# Build walkable set (ground minus obstacles), all in normalized coords.
	if ground_cells.size() > 0:
		var origin: Vector2i = grid_bounds.position
		for pos in ground_cells.keys():
			var raw_pos: Vector2i = pos + origin
			var is_road: bool = false
			if ground_layer:
				var atlas_coords: Vector2i = ground_layer.get_cell_atlas_coords(raw_pos)
				is_road = _is_dirt_road_tile(atlas_coords)

			# Jika ubin adalah jalan cokelat (dirt road), biarkan tetap dapat dilalui.
			# Rintangan (rumah, pohon, dll.) di ubin rumput tetap 100% padat/berfungsi sebagai obstacle.
			if is_road:
				walkable_cells[pos] = true
			elif not obstacle_cells.has(pos):
				walkable_cells[pos] = true
	else:
		# Fallback dummy grid jika map.tscn belum ada TileMapLayer
		CELL_SIZE = 16
		var default_width = 24
		var default_height = 14
		grid_bounds = Rect2i(0, 0, default_width, default_height)
		for x in range(default_width):
			for y in range(default_height):
				var pos = Vector2i(x, y)
				ground_cells[pos] = true
				walkable_cells[pos] = true

func _is_dirt_road_tile(coords: Vector2i) -> bool:
	# Ubin jalan cokelat pada atlas Ext_10a_DEMO (baris 2-4, kolom 0-11)
	if coords.x >= 0 and coords.x <= 11 and coords.y >= 2 and coords.y <= 4:
		return true
	return false

func is_valid_position(pos: Vector2i) -> bool:
	return ground_cells.has(pos)

func is_walkable(pos: Vector2i) -> bool:
	return walkable_cells.has(pos)

func is_obstacle(pos: Vector2i) -> bool:
	return not is_walkable(pos)

func get_step_cost(_pos: Vector2i) -> float:
	return 1.0

## Returns the normalized center tile of the map (0,0 = top-left of tiles).
func get_map_center() -> Vector2i:
	# grid_bounds stores the raw TileMap rect; size gives us tile count.
	# Dividing by 2 gives the center tile in normalized space.
	return Vector2i(grid_bounds.size.x / 2, grid_bounds.size.y / 2)

func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for dir in directions:
		var target_pos = pos + dir
		if is_walkable(target_pos):
			neighbors.append(target_pos)
	return neighbors

func map_to_world(grid_pos: Vector2i) -> Vector2:
	# grid_pos is normalized (0,0 = top-left of map).
	# Add grid_bounds.position to convert back to raw TileMap coordinates.
	var tile_pos: Vector2i = grid_pos + grid_bounds.position
	if ground_layer:
		return ground_layer.to_global(ground_layer.map_to_local(tile_pos))
	return to_global(Vector2(
		tile_pos.x * CELL_SIZE + CELL_SIZE / 2.0,
		tile_pos.y * CELL_SIZE + CELL_SIZE / 2.0
	))

func world_to_map(world_pos: Vector2) -> Vector2i:
	# Convert world position to a raw TileMap cell, then normalize.
	if ground_layer:
		var local: Vector2 = ground_layer.to_local(world_pos)
		var cell: Vector2i = ground_layer.local_to_map(local)
		return cell - grid_bounds.position
	var local_pos: Vector2 = to_local(world_pos)
	var cell := Vector2i(
		int(floor(local_pos.x / CELL_SIZE)),
		int(floor(local_pos.y / CELL_SIZE))
	)
	return cell - grid_bounds.position

## Mencari titik koordinat walkable terdekat dari preferred position
func get_valid_spawn_point(preferred: Vector2i) -> Vector2i:
	if is_walkable(preferred):
		return preferred

	# BFS – find nearest walkable cell in normalized coords
	var visited: Dictionary = {preferred: true}
	var queue: Array[Vector2i] = [preferred]
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	while queue.size() > 0:
		var curr: Vector2i = queue.pop_front()
		if is_walkable(curr):
			return curr
		for dir in directions:
			var n: Vector2i = curr + dir
			if not visited.has(n) and is_valid_position(n):
				visited[n] = true
				queue.append(n)

	# Fallback: return any walkable cell
	if walkable_cells.size() > 0:
		return walkable_cells.keys()[0]
	return Vector2i.ZERO
