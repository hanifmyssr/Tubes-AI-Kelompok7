class_name NPC
extends Node2D

@export var map_data: MapData
@export var player: Player
@export_enum("A_STAR", "UCS") var algorithm_type: String = "A_STAR"
@export var step_interval: float = 0.4 # Interval waktu antar-langkah NPC (detik)

var grid_position: Vector2i = Vector2i(2, 2)
var is_chasing: bool = false
var step_timer: Timer

func _ready() -> void:
	update_world_position()
	_setup_timer()

# Membuat Timer otomatis lewat kode
func _setup_timer() -> void:
	step_timer = Timer.new()
	step_timer.wait_time = step_interval
	step_timer.one_shot = false
	step_timer.timeout.connect(_on_timer_timeout)
	add_child(step_timer)

# Menangani input tombol trigger (Tombol Spasi)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): # "ui_accept" default-nya tombol Space / Enter
		toggle_chase()

# Fungsi untuk mengaktifkan / mematikan fitur pengejaran otomatis
func toggle_chase() -> void:
	is_chasing = !is_chasing
	if is_chasing:
		step_timer.start()
	else:
		step_timer.stop()

# Dijalankan setiap kali timer habis (misal tiap 0.4 detik)
func _on_timer_timeout() -> void:
	if not player or not map_data or not is_chasing:
		return
		
	# Jika NPC sudah sampai di ubin tempat Player berdiri, stop
	if grid_position == player.grid_position:
		return
		
	var path = find_path_to(player.grid_position)
	if path.size() > 1:
		grid_position = path[1]
		update_world_position()

func find_path_to(target_pos: Vector2i) -> Array[Vector2i]:
	if not map_data:
		return [grid_position]
		
	if algorithm_type == "A_STAR":
		return run_a_star(grid_position, target_pos)
	else:
		return run_ucs(grid_position, target_pos)

# --- ALGORITMA 1: UCS ---
func run_ucs(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var open_set: Array = []
	var came_from: Dictionary = {}
	var cost_so_far: Dictionary = {}

	open_set.append({"pos": start, "cost": 0})
	cost_so_far[start] = 0

	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	while open_set.size() > 0:
		open_set.sort_custom(func(a, b): return a["cost"] < b["cost"])
		var current_node = open_set.pop_front()
		var current: Vector2i = current_node["pos"]

		if current == goal:
			break

		for dir in directions:
			var neighbor: Vector2i = current + dir
			if not map_data.is_valid_position(neighbor) or map_data.is_obstacle(neighbor):
				continue

			var step_cost = map_data.get_step_cost(neighbor)
			var new_cost = cost_so_far[current] + step_cost

			if neighbor not in cost_so_far or new_cost < cost_so_far[neighbor]:
				cost_so_far[neighbor] = new_cost
				open_set.append({"pos": neighbor, "cost": new_cost})
				came_from[neighbor] = current

	return reconstruct_path(came_from, start, goal)

# --- ALGORITMA 2: A* ---
func run_a_star(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var open_set: Array = []
	var came_from: Dictionary = {}
	var g_score: Dictionary = {}

	g_score[start] = 0
	var h_start = heuristic(start, goal)
	open_set.append({"pos": start, "f_score": h_start})

	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	while open_set.size() > 0:
		open_set.sort_custom(func(a, b): return a["f_score"] < b["f_score"])
		var current_node = open_set.pop_front()
		var current: Vector2i = current_node["pos"]

		if current == goal:
			break

		for dir in directions:
			var neighbor: Vector2i = current + dir
			if not map_data.is_valid_position(neighbor) or map_data.is_obstacle(neighbor):
				continue

			var step_cost = map_data.get_step_cost(neighbor)
			var tentative_g = g_score[current] + step_cost

			if neighbor not in g_score or tentative_g < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				var f_score = tentative_g + heuristic(neighbor, goal)
				open_set.append({"pos": neighbor, "f_score": f_score})

	return reconstruct_path(came_from, start, goal)

func heuristic(a: Vector2i, b: Vector2i) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

func reconstruct_path(came_from: Dictionary, start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current = goal

	if current not in came_from and current != start:
		return [start]

	while current != start:
		path.append(current)
		if current in came_from:
			current = came_from[current]
		else:
			break
	path.append(start)
	path.reverse()
	return path

func update_world_position() -> void:
	if map_data:
		position = Vector2(
			grid_position.x * map_data.CELL_SIZE + map_data.CELL_SIZE / 2.0,
			grid_position.y * map_data.CELL_SIZE + map_data.CELL_SIZE / 2.0
		)
		
# Tambahkan variabel jalur di bagian atas npc.gd
var current_path: Array[Vector2i] = []

# Pada fungsi _draw(), gambar garis merah menghubungkan titik jalur
func _draw() -> void:
	# Cukup kosongkan fungsinya pakai pass
	pass

# Panggil queue_redraw() setiap kali path dihitung ulang di move_one_step_towards()
func move_one_step_towards(target_grid_pos: Vector2i) -> void:
	if not map_data or grid_position == target_grid_pos:
		current_path.clear()
		queue_redraw()
		return
		
	current_path = find_path_to(target_grid_pos)
	queue_redraw() # Memperbarui tampilan garis di layar
	if current_path.size() > 1:
		grid_position = current_path[1]
		update_world_position()

func toggle_algorithm() -> String:
	if algorithm_type == "A_STAR":
		algorithm_type = "UCS"
	else:
		algorithm_type = "A_STAR"
	return algorithm_type

func _on_btn_algo_pressed() -> void:
	var new_algo = toggle_algorithm()
	var btn = get_node_or_null("../CanvasLayer/BtnAlgo") as Button
	if btn:
		btn.text = "Algoritma: " + new_algo
	
	# Minta NPC langsung hitung ulang rute ke lokasi Player saat ini
	if player:
		current_path = find_path_to(player.grid_position)
		queue_redraw()
