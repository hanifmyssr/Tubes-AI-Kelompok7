extends Node

# Sinyal pusat yang akan dipancarkan oleh Player/NPC dan didengarkan oleh UI
signal path_calculated(path: Array, visited: Array, time_ms: float)
signal algorithm_changed(algo_name: String)

# Referensi ke UI agar GameManager bisa menyuruh UI menggambar ulang
var debug_overlay = null

func _ready() -> void:
	# Menghubungkan sinyal pusat ke fungsi pembaruan UI
	path_calculated.connect(_on_path_calculated)

func register_overlay(overlay_node: CanvasLayer) -> void:
	debug_overlay = overlay_node
	print("GameManager: Debug Overlay berhasil diregistrasi.")

func _on_path_calculated(path: Array, visited: Array, time_ms: float) -> void:
	if debug_overlay:
		# Meneruskan data dari AI ke UI DebugOverlay Anda
		debug_overlay.update_debug_data(visited, path, time_ms)
