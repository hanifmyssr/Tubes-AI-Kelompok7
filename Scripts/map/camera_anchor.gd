extends Camera2D

func _ready() -> void:
	var map_data: MapData = _find_map_data()
	if not map_data:
		return

	# Wait one frame so MapData has finished loading tile bounds
	await get_tree().process_frame

	_update_camera_transform(map_data)
	if get_viewport():
		get_viewport().size_changed.connect(func(): _update_camera_transform(map_data))

func _update_camera_transform(map_data: MapData) -> void:
	if not map_data or not is_instance_valid(map_data):
		return

	var ground_layer: TileMapLayer = map_data.ground_layer
	if not ground_layer:
		ground_layer = map_data.get_node_or_null("GroundLayer") as TileMapLayer

	if not ground_layer:
		return

	var used_cells: Array[Vector2i] = ground_layer.get_used_cells()
	if used_cells.size() == 0:
		return

	var cell_size: float = float(map_data.CELL_SIZE)
	if cell_size <= 0:
		cell_size = 16.0

	var min_x: float = INF
	var max_x: float = -INF
	var min_y: float = INF
	var max_y: float = -INF

	for cell in used_cells:
		var wpos: Vector2 = ground_layer.to_global(ground_layer.map_to_local(cell))
		var half_cell: float = cell_size / 2.0
		min_x = min(min_x, wpos.x - half_cell)
		max_x = max(max_x, wpos.x + half_cell)
		min_y = min(min_y, wpos.y - half_cell)
		max_y = max(max_y, wpos.y + half_cell)

	var map_width: float = max_x - min_x
	var map_height: float = max_y - min_y

	# Titik pusat presisi secara simetris di tengah peta
	var world_center := Vector2((min_x + max_x) / 2.0, (min_y + max_y) / 2.0)
	global_position = world_center

	# Hitung zoom presisi agar lebar peta (map_width) mengisi 100% lebar layar (tanpa ruang kosong di kiri/kanan)
	var viewport_size: Vector2 = get_viewport_rect().size
	if map_width > 0 and viewport_size.x > 0:
		var zoom_x: float = viewport_size.x / map_width
		zoom = Vector2(zoom_x, zoom_x)

func _find_map_data() -> MapData:
	if get_parent() is MapData:
		return get_parent() as MapData
	var root := get_tree().current_scene
	if root:
		return root.get_node_or_null("Map") as MapData
	return null
