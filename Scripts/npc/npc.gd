class_name NPC
extends Node2D

## Sinyal saat NPC selesai bergerak menyusuri rute
signal movement_finished

@export var map_data: MapData
@export var player: Player
@export_enum("UCS", "A_STAR_MANHATTAN", "A_STAR_EUCLIDEAN", "A_STAR_CHEBYSHEV") var algorithm_type: String = "A_STAR_MANHATTAN"
@export var step_duration: float = 0.2
@export var chase_interval: float = 0.35
@export var is_chasing: bool = false

var grid_position: Vector2i = Vector2i(0, 0)
var is_moving: bool = false
var active_tween: Tween = null
var current_path: Array[Vector2i] = []
var step_timer: Timer

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	# Sesuaikan skala visual karakter agar proporsional dengan ubin 16x16
	if sprite:
		sprite.scale = Vector2(0.5, 0.5)

	# Auto-detect node jika belum dihubungkan di Inspector
	if not map_data:
		find_map_data()
	if not player:
		find_player()

	_setup_timer()

	# Hubungkan sinyal dari GameManager saat dropdown UI berganti
	if not GameManager.algorithm_changed.is_connected(_on_algorithm_changed):
		GameManager.algorithm_changed.connect(_on_algorithm_changed)

	# Tunggu MapData siap sebelum inisialisasi posisi
	if map_data:
		if not map_data.is_node_ready():
			await map_data.ready
		_initialize_spawn_position()

	# Hubungkan sinyal pergerakan player
	if player:
		if not player.player_moved.is_connected(_on_player_moved):
			player.player_moved.connect(_on_player_moved)

func find_map_data() -> void:
	map_data = get_node_or_null("../Map") as MapData
	if not map_data:
		map_data = get_node_or_null("../MapData") as MapData
	if not map_data and get_parent() is MapData:
		map_data = get_parent() as MapData

func find_player() -> void:
	player = get_node_or_null("../player") as Player
	if not player:
		player = get_node_or_null("../Player") as Player

func _setup_timer() -> void:
	step_timer = Timer.new()
	step_timer.wait_time = chase_interval
	step_timer.one_shot = false
	step_timer.timeout.connect(_on_timer_timeout)
	add_child(step_timer)
	if is_chasing:
		step_timer.start()

func _initialize_spawn_position() -> void:
	# Spawn NPC near map center, offset from player so they aren't on top of each other
	var target_preferred: Vector2i
	if player:
		target_preferred = player.grid_position + Vector2i(4, 4)
	else:
		var center := map_data.get_map_center()
		target_preferred = center + Vector2i(4, 4)

	grid_position = map_data.get_valid_spawn_point(target_preferred)
	# Use global_position because map_to_world returns global coords
	global_position = map_data.map_to_world(grid_position)

	# Hitung rute awal ke player jika ada
	if player:
		find_path_to(player.grid_position)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): # Tombol Spasi / Enter
		if not is_chasing and player:
			player.show_call_bubble()
		toggle_chase()

func toggle_chase() -> void:
	is_chasing = !is_chasing
	if is_chasing:
		step_timer.start()
		if player:
			move_one_step_towards(player.grid_position)
	else:
		step_timer.stop()

func _on_timer_timeout() -> void:
	if not is_chasing or is_moving or not player or not map_data:
		return

	if grid_position == player.grid_position:
		return

	move_one_step_towards(player.grid_position)

func _on_player_moved(player_pos: Vector2i) -> void:
	# Selalu perbarui kalkulasi rute dan overlay saat player bergerak
	var result = find_path_to(player_pos)
	if is_chasing and not is_moving:
		var path: Array[Vector2i] = result.get("path", [])
		if path.size() > 1:
			move_to_grid(path[1])

func _on_algorithm_changed(new_algo: String) -> void:
	algorithm_type = new_algo
	if player and map_data:
		find_path_to(player.grid_position)

## Menjalankan algoritma pathfinding terpilih dan memancarkan metrik ke GameManager
func find_path_to(target_pos: Vector2i) -> Dictionary:
	if not map_data:
		return {"path": [grid_position], "visited_nodes": [], "total_expanded": 0, "execution_time_ms": 0.0}

	var result: Dictionary = {}
	match algorithm_type:
		"UCS":
			result = UCS.search(grid_position, target_pos, map_data)
		"A_STAR_MANHATTAN":
			result = AStarAlgorithm.search(grid_position, target_pos, map_data, AStarAlgorithm.HeuristicType.MANHATTAN)
		"A_STAR_EUCLIDEAN":
			result = AStarAlgorithm.search(grid_position, target_pos, map_data, AStarAlgorithm.HeuristicType.EUCLIDEAN)
		"A_STAR_CHEBYSHEV":
			result = AStarAlgorithm.search(grid_position, target_pos, map_data, AStarAlgorithm.HeuristicType.CHEBYSHEV)
		_:
			result = AStarAlgorithm.search(grid_position, target_pos, map_data, AStarAlgorithm.HeuristicType.MANHATTAN)

	var path: Array[Vector2i] = result.get("path", [])
	var visited: Array[Vector2i] = result.get("visited_nodes", [])
	var time_ms: float = result.get("execution_time_ms", 0.0)

	current_path = path
	GameManager.path_calculated.emit(path, visited, time_ms)
	return result

func move_one_step_towards(target_grid_pos: Vector2i) -> void:
	if is_moving or not map_data or grid_position == target_grid_pos:
		return

	var result = find_path_to(target_grid_pos)
	var path: Array[Vector2i] = result.get("path", [])
	if path.size() > 1:
		move_to_grid(path[1])

func move_to_grid(target_grid: Vector2i) -> void:
	is_moving = true
	grid_position = target_grid
	var target_world_pos = map_data.map_to_world(target_grid)

	if active_tween and active_tween.is_running():
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	# Use global_position because map_to_world returns a global world coordinate
	active_tween.tween_property(self, "global_position", target_world_pos, step_duration)

	await active_tween.finished
	is_moving = false
	movement_finished.emit()

	if is_chasing and player and map_data and grid_position != player.grid_position:
		move_one_step_towards(player.grid_position)
