class_name SearchContract
extends RefCounted

# --- FACTORY METHODS ---

## Membuat Dictionary hasil pencarian rute yang terstandarisasi.
## 
## @param path              Array koordinat Vector2i dari Start -> Target.
## @param visited_nodes     Array seluruh koordinat Vector2i yang sempat di-expand.
## @param total_expanded    Jumlah node yang diekspansi (dipakai untuk metrik UI).
## @param execution_time_ms Waktu eksekusi komputasi algoritma dalam milidetik (ms).
## @return Dictionary berisi data lengkap sesuai spesifikasi proyek.
static func create_result(
	path: Array[Vector2i] = [],
	visited_nodes: Array[Vector2i] = [],
	total_expanded: int = 0,
	execution_time_ms: float = 0.0
) -> Dictionary:
	return {
		"path": path,                         # Array[Vector2i]: Rute akhir dari start ke target
		"visited_nodes": visited_nodes,       # Array[Vector2i]: Node yang diekspansi selama pencarian
		"total_expanded": total_expanded,     # int: Total node yang di-expand
		"execution_time_ms": execution_time_ms # float: Waktu komputasi algoritma (ms)
	}


## Membuat Dictionary hasil kosong jika target terhalang / tidak dapat dijangkau.
## @return Dictionary kosong terstandarisasi.
static func create_empty_result() -> Dictionary:
	return create_result([], [], 0, 0.0)
