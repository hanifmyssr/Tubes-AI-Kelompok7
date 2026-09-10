class_name MapData
extends Node2D

const GRID_WIDTH: int = 24
const GRID_HEIGHT: int = 14
const CELL_SIZE: int = 48

enum TerrainType { GRASS, OBSTACLE, RIVER }
var grid: Dictionary = {}

func _ready() -> void:
	init_grid()
	queue_redraw()

func init_grid() -> void:
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			grid[Vector2i(x, y)] = TerrainType.GRASS
	
	# Contoh rintangan dan sungai untuk tes visual
	grid[Vector2i(5, 5)] = TerrainType.OBSTACLE
	grid[Vector2i(5, 6)] = TerrainType.OBSTACLE
	grid[Vector2i(5, 7)] = TerrainType.OBSTACLE
	grid[Vector2i(10, 10)] = TerrainType.OBSTACLE
	grid[Vector2i(11, 10)] = TerrainType.OBSTACLE
	grid[Vector2i(10, 11)] = TerrainType.OBSTACLE

	grid[Vector2i(3, 2)] = TerrainType.RIVER

func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GRID_WIDTH and pos.y >= 0 and pos.y < GRID_HEIGHT

func is_obstacle(pos: Vector2i) -> bool:
	if not is_valid_position(pos):
		return true
	return grid.get(pos, TerrainType.OBSTACLE) == TerrainType.OBSTACLE

func get_step_cost(pos: Vector2i) -> int:
	var terrain = grid.get(pos, TerrainType.OBSTACLE)
	match terrain:
		TerrainType.GRASS: return 1
		TerrainType.RIVER: return 3
		_: return 9999

func _draw() -> void:
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var pos = Vector2i(x, y)
			var rect = Rect2(Vector2(x * CELL_SIZE, y * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
			var terrain = grid.get(pos, TerrainType.GRASS)
			
			var color = Color(0.4, 0.8, 0.4) # Hijau (Rumput)
			if terrain == TerrainType.OBSTACLE:
				color = Color(0.8, 0.2, 0.2) # Merah (Rintangan)
			elif terrain == TerrainType.RIVER:
				color = Color(0.2, 0.4, 0.8) # Biru (Sungai)
				
			draw_rect(rect, color)
			draw_rect(rect, Color(0, 0, 0, 0.3), false, 1.0) # Garis batas grid

func is_walkable(pos: Vector2i) -> bool:
	return is_valid_position(pos) and not is_obstacle(pos)
	
func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for dir in directions:
		var target_pos = pos + dir
		if is_walkable(target_pos):
			neighbors.append(target_pos)
	return neighbors
