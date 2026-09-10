class_name Player
extends Node2D

# Sinyal yang dipancarkan saat Player berpindah ubin (direspons oleh AI NPC)
signal player_moved(new_grid_position: Vector2i)

@export var map_data: MapData
var grid_position: Vector2i = Vector2i(12, 7) # Posisi awal player di koordinat grid

func _ready() -> void:
	update_world_position()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
		
	var direction: Vector2i = Vector2i.ZERO
	if event.is_action_pressed("ui_up"):
		direction = Vector2i.UP
	elif event.is_action_pressed("ui_down"):
		direction = Vector2i.DOWN
	elif event.is_action_pressed("ui_left"):
		direction = Vector2i.LEFT
	elif event.is_action_pressed("ui_right"):
		direction = Vector2i.RIGHT

	if direction != Vector2i.ZERO:
		try_move(direction)

func try_move(direction: Vector2i) -> void:
	var target_pos: Vector2i = grid_position + direction
	
	# Minta validasi ke map_data apakah koordinat tujuan aman (bukan rintangan)
	if map_data and not map_data.is_obstacle(target_pos):
		grid_position = target_pos
		update_world_position()
		player_moved.emit(grid_position) # Beritahu sistem bahwa posisi player berubah

func update_world_position() -> void:
	if map_data:
		# Konversi koordinat grid (x, y) ke titik pixel di layar
		position = Vector2(
			grid_position.x * map_data.CELL_SIZE + map_data.CELL_SIZE / 2.0,
			grid_position.y * map_data.CELL_SIZE + map_data.CELL_SIZE / 2.0
		)
