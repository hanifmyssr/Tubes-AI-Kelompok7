extends CanvasLayer

# Mendapatkan referensi dari teks Label yang sudah Anda buat
@onready var stats_label = $StatsLabel

# Membuat kanvas kosong untuk menggambar
var drawing_canvas: Control

# Variabel untuk menampung data
var expanded_nodes: Array = []
var path_nodes: Array = []
var tile_size: int = 32 # Ukuran grid standar, nanti bisa disesuaikan dengan Anggota 1

func _ready():
	# 1. Menyiapkan kanvas gambar saat game baru dimulai
	drawing_canvas = Control.new()
	add_child(drawing_canvas)
	drawing_canvas.draw.connect(_on_canvas_draw)
	
	# 2. DATA TIRUAN (Hanya untuk pengujian Anda saat ini)
	expanded_nodes = [Vector2(1, 1), Vector2(2, 1), Vector2(3, 1), Vector2(3, 2)]
	path_nodes = [Vector2(1, 1), Vector2(2, 1), Vector2(3, 2)]
	
	update_stats(expanded_nodes.size())

func _on_canvas_draw():
	# 3. Menggambar kotak biru transparan untuk node yang diekspansi algoritma
	for node in expanded_nodes:
		var rect = Rect2(node * tile_size, Vector2(tile_size, tile_size))
		drawing_canvas.draw_rect(rect, Color(0.2, 0.6, 1.0, 0.5))

	# 4. Menggambar garis rute hijau dari titik ke titik
	if path_nodes.size() > 1:
		for i in range(path_nodes.size() - 1):
			var start_pos = (path_nodes[i] * tile_size) + Vector2(tile_size / 2.0, tile_size / 2.0)
			var end_pos = (path_nodes[i+1] * tile_size) + Vector2(tile_size / 2.0, tile_size / 2.0)
			drawing_canvas.draw_line(start_pos, end_pos, Color(0.0, 1.0, 0.0), 3.0)

func update_stats(count: int):
	# 5. Memperbarui teks pada StatsLabel
	stats_label.text = "Total Node Diekspansi: " + str(count)

func update_debug_data(new_expanded: Array, new_path: Array):
	# 6. Fungsi "Jembatan" yang nantinya dipanggil oleh Anggota 2
	expanded_nodes = new_expanded
	path_nodes = new_path
	update_stats(expanded_nodes.size())
	drawing_canvas.queue_redraw() # Perintah wajib untuk memperbarui gambar layar
