# ==============================================================================
# File        : UCS.gd
# Path        : res://Scripts/Pathfinding/UCS.gd
# Modul       : TSK-05 (Algoritma UCS Engine)
# Tim         : Anggota 2 (AI & Pathfinding Logic)
# Deskripsi   : Mengimplementasikan algoritma Uniform Cost Search (UCS) dengan 
#               nilai heuristik h(n) = 0. Algoritma ini menjamin jalur terpendek
#               dengan mengekspansi node berdasarkan akumulasi cost g(n) terkecil.
# ==============================================================================

class_name UCS
extends RefCounted

## Menjalankan pencarian rute terpendek menggunakan Uniform Cost Search (UCS).
## 
## @param start        Koordinat grid awal (posisi Kucing Bolu).
## @param target       Koordinat grid tujuan (posisi Player).
## @param grid_manager Referensi ke modul GridManager untuk validasi tile/rintangan.
## @return Dictionary  Hasil pencarian sesuai format SearchContract.
static func search(start: Vector2i, target: Vector2i, grid_manager) -> Dictionary:
	# 1. Catat waktu mulai komputasi (microsecond)
	var start_time: float = Time.get_ticks_usec()
	
	# Variabel penampung hasil
	var final_path: Array[Vector2i] = []
	var visited_nodes: Array[Vector2i] = []
	
	# Validasi Awal: Jika target berada di area rintangan/non-walkable, batalkan pencarian
	if not grid_manager.is_walkable(target):
		return SearchContract.create_empty_result()

	# 2. Inisialisasi Struktur Data Pencarian
	# Priority Queue (Open List) disimulasikan menggunakan Array dari PathNode
	var open_list: Array[PathNode] = []
	
	# Closed List (Set) menggunakan Dictionary untuk lookup O(1) koordinat yang sudah di-expand
	var closed_list: Dictionary = {}
	
	# Lookup Table untuk menyimpan node aktif berdasarkan koordinat (pos -> PathNode)
	var all_nodes: Dictionary = {}

	# 3. Inisialisasi Node Awal (Start Node)
	# Pada UCS, h(n) = 0 sehingga f(n) = g(n) = 0.0
	var start_node = PathNode.new(start, 0.0, 0.0, null)
	open_list.append(start_node)
	all_nodes[start] = start_node

	# 4. Main Search Loop (Iterasi Algoritma)
	while open_list.size() > 0:
		# A. Priority Queue Extraction:
		# Urutkan open_list berdasarkan g(n) terkecil (karena h(n) = 0)
		open_list.sort_custom(func(a: PathNode, b: PathNode): return a.g < b.g)
		
		# Ambil node dengan g_score terkecil dari open_list
		var current: PathNode = open_list.pop_front()

		# Jika node ini sudah diproses di Closed List, lewati
		if closed_list.has(current.pos):
			continue

		# B. Masukkan node ke Closed List & catat ke visited_nodes (Metrik Debug Overlay)
		closed_list[current.pos] = true
		visited_nodes.append(current.pos)

		# C. Goal Test: Jika node saat ini adalah target, rekrustruksi jalur terpendek
		if current.pos == target:
			var curr_path_node: PathNode = current
			while curr_path_node != null:
				final_path.push_front(curr_path_node.pos)
				curr_path_node = curr_path_node.parent
			break

		# D. Ekspansi Tetangga (Neighbors Expansion)
		var neighbors: Array[Vector2i] = grid_manager.get_neighbors(current.pos)
		for neighbor_pos in neighbors:
			# Jangan evaluasi node yang sudah berada di Closed List
			if closed_list.has(neighbor_pos):
				continue

			# Hitung tentative g_score (Setiap langkah antar grid bernilai cost 1.0)
			var tentative_g: float = current.g + 1.0

			if not all_nodes.has(neighbor_pos):
				# Jika tetangga belum pernah didaftarkan, buat PathNode baru (h = 0.0)
				var neighbor_node = PathNode.new(neighbor_pos, tentative_g, 0.0, current)
				all_nodes[neighbor_pos] = neighbor_node
				open_list.append(neighbor_node)
			else:
				# Jika tetangga sudah ada di open_list, periksa apakah ditemukan jalur yang lebih murah
				var existing_node: PathNode = all_nodes[neighbor_pos]
				if tentative_g < existing_node.g:
					existing_node.update_scores(tentative_g, 0.0, current)

	# 5. Selesai: Hitung total waktu eksekusi dalam milidetik (ms)
	var end_time: float = Time.get_ticks_usec()
	var execution_time_ms: float = (end_time - start_time) / 1000.0

	# 6. Mengembalikan data terstruktur menggunakan SearchContract (TSK-04)
	return SearchContract.create_result(
		final_path,
		visited_nodes,
		visited_nodes.size(),
		execution_time_ms
	)