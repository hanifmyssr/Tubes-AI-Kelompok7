

class_name PathNode
extends RefCounted

# --- PROPERTI NODE ---
## Koordinat grid 2D dari node ini (contoh: Vector2i(5, 10))
var pos: Vector2i

## Cost riil (jarak akumulasi) yang ditempuh dari node Start ke node ini
var g: float = 0.0

## Cost estimasi/heuristik dari node ini menuju ke node Target
var h: float = 0.0

## Total evaluasi cost: f(n) = g(n) + h(n)
var f: float = 0.0

## Referensi ke PathNode pendahulu (dipakai untuk merekonstruksi jalur terpendek)
var parent: PathNode = null


# --- KONSTRUKTOR ---
## Menginisialisasi data node baru saat di-instansiasi oleh algoritma pencarian.
func _init(p_pos: Vector2i, p_g: float = 0.0, p_h: float = 0.0, p_parent: PathNode = null) -> void:
	pos = p_pos
	g = p_g
	h = p_h
	f = g + h  # Mengkalkulasi nilai f(n) otomatis saat inisialisasi
	parent = p_parent


# --- METHOD BANTUAN ---
## Memperbarui nilai g, h, f, dan parent jika ditemukan jalur yang lebih optimal.
func update_scores(new_g: float, new_h: float, new_parent: PathNode = null) -> void:
	g = new_g
	h = new_h
	f = g + h
	if new_parent != null:
		parent = new_parent
