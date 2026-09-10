extends CanvasLayer

@onready var stats_label = $StatsLabel
@onready var algorithm_dropdown = $AlgorithmDropdown

var drawing_canvas: Control
var expanded_nodes: Array = []
var path_nodes: Array = []
var tile_size: int = 48

func _ready():
	drawing_canvas = Control.new()
	add_child(drawing_canvas)
	drawing_canvas.draw.connect(_on_canvas_draw)
	
	# Menghubungkan sinyal dropdown saat pilihan diubah oleh pengguna
	algorithm_dropdown.item_selected.connect(_on_algorithm_selected)
	
	# DATA TIRUAN (Mock Data untuk pengujian)
	expanded_nodes = [Vector2(1, 1), Vector2(2, 1), Vector2(3, 1)]
	path_nodes = [Vector2(1, 1), Vector2(3, 1)]
	
	update_stats(expanded_nodes.size(), 1.5) # Contoh: 1.5 milidetik
	GameManager.register_overlay(self)

func _on_canvas_draw():
	for node in expanded_nodes:
		var rect = Rect2(node * tile_size, Vector2(tile_size, tile_size))
		drawing_canvas.draw_rect(rect, Color(0.2, 0.6, 1.0, 0.5))

	if path_nodes.size() > 1:
		for i in range(path_nodes.size() - 1):
			var start_pos = (path_nodes[i] * tile_size) + Vector2(tile_size / 2.0, tile_size / 2.0)
			var end_pos = (path_nodes[i+1] * tile_size) + Vector2(tile_size / 2.0, tile_size / 2.0)
			drawing_canvas.draw_line(start_pos, end_pos, Color(0.0, 1.0, 0.0), 3.0)

func update_stats(count: int, time_ms: float):
	var selected_algo = algorithm_dropdown.get_item_text(algorithm_dropdown.selected)
	stats_label.text = "Algoritma: " + selected_algo + "\nTotal Node: " + str(count) + "\nWaktu: " + str(time_ms).pad_decimals(3) + " ms"
	
func _on_algorithm_selected(index: int):
	# Fungsi ini terpanggil otomatis saat Anda mengubah pilihan di dropdown
	print("Algoritma diubah ke indeks: ", index)
	# Nanti bagian ini akan memberi sinyal ke Anggota 2 untuk mengganti metode pencarian AI

func update_debug_data(new_expanded: Array, new_path: Array, time_ms: float):
	expanded_nodes = new_expanded
	path_nodes = new_path
	update_stats(expanded_nodes.size(), time_ms)
	drawing_canvas.queue_redraw()
