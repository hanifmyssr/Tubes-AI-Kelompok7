class_name AStarAlgorithm
extends RefCounted

## Enum pilihan fungsi heuristik
enum HeuristicType {
	MANHATTAN,
	EUCLIDEAN,
	CHEBYSHEV
}


# --- FUNGSI HEURISTIK ---

## Memperhitungkan estimasi jarak (h-cost) dari titik A ke titik B.
##
## @param a      Koordinat grid awal.
## @param b      Koordinat grid target.
## @param type   Tipe heuristik (MANHATTAN, EUCLIDEAN, CHEBYSHEV).
## @return float Nilai estimasi jarak heuristik h(n).
static func calculate_heuristic(a: Vector2i, b: Vector2i, type: HeuristicType) -> float:
	match type:
		HeuristicType.MANHATTAN:
			# Jarak Manhattan (Grid/Taxicab Movement): |dx| + |dy|
			return float(abs(a.x - b.x) + abs(a.y - b.y))
			
		HeuristicType.EUCLIDEAN:
			# Jarak Euclidean (Garis Lurus / Vector Distance): sqrt(dx^2 + dy^2)
			return Vector2(a).distance_to(Vector2(b))
			
		HeuristicType.CHEBYSHEV:
			# Jarak Chebyshev (Diagonal / Chess King Movement): max(|dx|, |dy|)
			return float(max(abs(a.x - b.x), abs(a.y - b.y)))
			
	return 0.0


# --- ALGORITMA UTAMA A* ---

## Menjalankan pencarian rute terpendek menggunakan Algoritma A*.
##
## @param start        Koordinat grid awal (posisi Kucing Bolu).
## @param target       Koordinat grid tujuan (posisi Player).
## @param grid_manager Referensi ke modul GridManager untuk validasi tile/rintangan.
## @param h_type       Tipe fungsi heuristik yang digunakan.
## @return Dictionary  Hasil pencarian terstruktur sesuai SearchContract.
static func search(start: Vector2i, target: Vector2i, grid_manager, h_type: HeuristicType) -> Dictionary:
	# 1. Catat waktu mulai komputasi (microsecond)
	var start_time: float = Time.get_ticks_usec()
	
	var final_path: Array[Vector2i] = []
	var visited_nodes: Array[Vector2i] = []
	
	# Validasi Awal: Batalkan jika target adalah rintangan / non-walkable
	if not grid_manager.is_walkable(target):
		return SearchContract.create_empty_result()

	# 2. Inisialisasi Struktur Data Pencarian
	# Open List disimulasikan menggunakan Array dari PathNode
	var open_list: Array[PathNode] = []
	
	# Closed List (Lookup Table O(1)) untuk koordinat yang telah di-expand
	var closed_list: Dictionary = {}
	
	# Lookup Table untuk menyimpan instance PathNode berdasarkan koordinat (pos -> PathNode)
	var all_nodes: Dictionary = {}

	# 3. Inisialisasi Node Awal (Start Node)
	var initial_h: float = calculate_heuristic(start, target, h_type)
	var start_node = PathNode.new(start, 0.0, initial_h, null)
	open_list.append(start_node)
	all_nodes[start] = start_node

	# 4. Main Search Loop (Iterasi Algoritma)
	while open_list.size() > 0:
		# A. Priority Queue Extraction:
		# Urutkan open_list berdasarkan total cost f(n) = g(n) + h(n) terkecil.
		# Jika f(n) sama, prioritaskan node dengan nilai h(n) lebih kecil (Tie-breaking).
		open_list.sort_custom(
			func(a: PathNode, b: PathNode):
				if is_equal_approx(a.f, b.f):
					return a.h < b.h
				return a.f < b.f
		)
		
		# Ambil node dengan f_score terkecil
		var current: PathNode = open_list.pop_front()

		# Jika node ini sudah berada di Closed List, lewati
		if closed_list.has(current.pos):
			continue

		# B. Masukkan node ke Closed List & catat ke visited_nodes (Metrik Debug Overlay)
		closed_list[current.pos] = true
		visited_nodes.append(current.pos)

		# C. Goal Test: Jika telah mencapai target, rekrustruksi jalur terpendek
		if current.pos == target:
			var curr_path_node: PathNode = current
			while curr_path_node != null:
				final_path.push_front(curr_path_node.pos)
				curr_path_node = curr_path_node.parent
			break

		# D. Ekspansi Tetangga (Neighbors Expansion)
		var neighbors: Array[Vector2i] = grid_manager.get_neighbors(current.pos)
		for neighbor_pos in neighbors:
			# Abaikan jika tetangga sudah diproses di Closed List
			if closed_list.has(neighbor_pos):
				continue

			# Hitung cost per langkah (default: 1.0 atau sesuai get_step_cost)
			var step_cost: float = grid_manager.get_step_cost(neighbor_pos) if grid_manager.has_method("get_step_cost") else 1.0
			var tentative_g: float = current.g + step_cost
			var neighbor_h: float = calculate_heuristic(neighbor_pos, target, h_type)

			if not all_nodes.has(neighbor_pos):
				# Buat PathNode baru jika tetangga belum pernah didaftarkan
				var neighbor_node = PathNode.new(neighbor_pos, tentative_g, neighbor_h, current)
				all_nodes[neighbor_pos] = neighbor_node
				open_list.append(neighbor_node)
			else:
				# Jika tetangga sudah pernah terdaftar, cek apakah jalur baru lebih murah
				var existing_node: PathNode = all_nodes[neighbor_pos]
				if tentative_g < existing_node.g:
					existing_node.update_scores(tentative_g, neighbor_h, current)

	# 5. Selesai: Hitung total waktu komputasi dalam milidetik (ms)
	var end_time: float = Time.get_ticks_usec()
	var execution_time_ms: float = (end_time - start_time) / 1000.0

	# 6. Mengembalikan data terstruktur menggunakan SearchContract (TSK-04)
	return SearchContract.create_result(
		final_path,
		visited_nodes,
		visited_nodes.size(),
		execution_time_ms
	)
