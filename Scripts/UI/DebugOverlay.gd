extends CanvasLayer

@onready var stats_label: Label = $StatsLabel
@onready var algorithm_dropdown: OptionButton = $AlgorithmDropdown

var world_drawer: Node2D = null
var expanded_nodes: Array = []
var path_nodes: Array = []
var tile_size: int = 16
var last_time_ms: float = 0.0

var map_data: MapData = null
var player: Player = null
var npc: NPC = null

func _ready() -> void:
	# Hubungkan sinyal pemilihan dropdown
	algorithm_dropdown.item_selected.connect(_on_algorithm_selected)
	
	# Registrasi ke GameManager
	GameManager.register_overlay(self)
	
	# Inisialisasi node perelasi dan drawer di world space
	find_nodes()
	_setup_world_drawer()
	
	# Set tampilan awal
	update_stats(0, 0.0)

func _exit_tree() -> void:
	if is_instance_valid(world_drawer):
		world_drawer.queue_free()

func _setup_world_drawer() -> void:
	world_drawer = Node2D.new()
	world_drawer.name = "PathDebugDrawer"
	# Render di atas TileMap (z_index 0), tetapi di bawah Karakter (z_index 5)
	world_drawer.z_index = 1
	world_drawer.draw.connect(_on_world_draw)
	
	call_deferred("_add_world_drawer_to_scene")

func _add_world_drawer_to_scene() -> void:
	var root = get_tree().current_scene
	if root:
		root.add_child(world_drawer)
	else:
		add_child(world_drawer)

func find_map_data() -> void:
	if get_parent():
		map_data = get_parent().get_node_or_null("Map") as MapData
		if not map_data:
			map_data = get_parent().get_node_or_null("MapData") as MapData
	if not map_data and get_tree().current_scene:
		map_data = get_tree().current_scene.get_node_or_null("Map") as MapData
	if map_data and map_data.CELL_SIZE > 0:
		tile_size = map_data.CELL_SIZE

func find_nodes() -> void:
	find_map_data()
	var root = get_tree().current_scene
	if root:
		if not player or not is_instance_valid(player):
			player = root.get_node_or_null("player") as Player
			if not player:
				player = root.get_node_or_null("Player") as Player
		if not npc or not is_instance_valid(npc):
			npc = root.get_node_or_null("npc") as NPC
			if not npc:
				npc = root.get_node_or_null("NPC") as NPC

	# Pastikan karakter selalu dirender di atas garis debug (z_index 5)
	if is_instance_valid(player) and player.z_index < 5:
		player.z_index = 5
	if is_instance_valid(npc) and npc.z_index < 5:
		npc.z_index = 5

func _process(_delta: float) -> void:
	find_nodes()
	if is_instance_valid(world_drawer) and (expanded_nodes.size() > 0 or path_nodes.size() > 0):
		world_drawer.queue_redraw()

func _on_world_draw() -> void:
	if not is_inside_tree() or not is_instance_valid(world_drawer):
		return

	if not map_data or not is_instance_valid(map_data):
		find_map_data()
	find_nodes()

	if not map_data:
		return

	var half_size = Vector2(tile_size / 2.0, tile_size / 2.0)

	# 1. Gambar node yang diekspansi (Visited Nodes) - Kotak biru transparan di atas ubin
	for node_pos in expanded_nodes:
		var grid_vec: Vector2i = Vector2i(node_pos)
		var world_center: Vector2 = map_data.map_to_world(grid_vec)
		var rect = Rect2(world_center - half_size, Vector2(tile_size, tile_size))
		world_drawer.draw_rect(rect, Color(0.2, 0.6, 1.0, 0.35))
		world_drawer.draw_rect(rect, Color(0.2, 0.6, 1.0, 0.7), false, 1.0)

	# 2. Gambar garis rute terpendek (Final Path) - Menyambung halus di belakang karakter
	if path_nodes.size() > 0:
		var points: Array[Vector2] = []

		# Titik awal (Posisi real-time NPC)
		if is_instance_valid(npc):
			points.append(npc.global_position)
		elif path_nodes.size() > 0:
			points.append(map_data.map_to_world(Vector2i(path_nodes[0])))

		# Node-node perantara sepanjang jalur
		if path_nodes.size() > 2:
			for i in range(1, path_nodes.size() - 1):
				var pos: Vector2i = Vector2i(path_nodes[i])
				points.append(map_data.map_to_world(pos))

		# Titik akhir (Posisi real-time Player)
		if is_instance_valid(player):
			points.append(player.global_position)
		elif path_nodes.size() > 1:
			points.append(map_data.map_to_world(Vector2i(path_nodes[-1])))

		# Gambar garis tipis dan penanda titik kecil
		if points.size() > 1:
			for i in range(points.size() - 1):
				world_drawer.draw_line(points[i], points[i + 1], Color(1.0, 0.85, 0.1, 0.8), 1.0)
				world_drawer.draw_circle(points[i], 1.0, Color(1.0, 0.9, 0.3, 0.85))
			world_drawer.draw_circle(points[-1], 1.0, Color(1.0, 0.9, 0.3, 0.85))

func update_stats(count: int, time_ms: float) -> void:
	last_time_ms = time_ms
	var selected_text = algorithm_dropdown.get_item_text(algorithm_dropdown.selected)
	var steps_count = max(0, path_nodes.size() - 1)
	stats_label.text = "Algoritma: %s\nNode Diekspansi: %d\nPanjang Langkah: %d\nWaktu: %.3f ms\n(Tekan [Spasi] untuk Toggle Kejar NPC)" % [
		selected_text, count, steps_count, time_ms
	]

func _on_algorithm_selected(index: int) -> void:
	var algo_name: String = "A_STAR_MANHATTAN"
	match index:
		0:
			algo_name = "UCS"
		1:
			algo_name = "A_STAR_MANHATTAN"
		2:
			algo_name = "A_STAR_EUCLIDEAN"
		3:
			algo_name = "A_STAR_CHEBYSHEV"

	GameManager.algorithm_changed.emit(algo_name)
	update_stats(expanded_nodes.size(), last_time_ms)

func update_debug_data(new_expanded: Array, new_path: Array, time_ms: float) -> void:
	expanded_nodes = new_expanded
	path_nodes = new_path
	if map_data and map_data.CELL_SIZE > 0:
		tile_size = map_data.CELL_SIZE
	update_stats(expanded_nodes.size(), time_ms)
	if is_instance_valid(world_drawer):
		world_drawer.queue_redraw()
