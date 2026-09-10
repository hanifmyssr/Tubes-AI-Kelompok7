# ==============================================================================
# File        : NPC.gd
# Path        : res://Scripts/Characters/NPC.gd
# Modul       : TSK-07 (Logika Movement NPC Kucing "Bolu")
# Tim         : Anggota 2 (AI & Pathfinding Logic)
# Deskripsi   : Mengatur logika pergerakan NPC Kucing Bolu. Menerima array `path`
#               (koordinat grid Vector2i) dan menggerakkan node secara halus 
#               antar sel menggunakan Godot Tween.
# ==============================================================================

class_name NPC
extends Node2D

## Sinyal yang dipancarkan saat Bolu selesai berjalan menyusuri seluruh rute
signal movement_finished

@export_group("Grid Settings")
## Ukuran satu ubin/grid dalam piksel (default: 32x32)
@export var cell_size: int = 32

@export_group("Movement Settings")
## Kecepatan pergerakan Bolu antar tile (detik per tile)
@export var step_duration: float = 0.18

## Posisi grid saat ini dari Kucing Bolu
var grid_pos: Vector2i = Vector2i(0, 0)

## Referensi Tween aktif untuk mengontrol interupsi pergerakan
var active_tween: Tween = null


func _ready() -> void:
	# Sinkronisasi posisi dunia (world position) dengan posisi grid awal
	snap_to_grid(grid_pos)


## Menyesuaikan posisi visual Sprite agar berada tepat di tengah-tengah tile grid.
func snap_to_grid(p_grid_pos: Vector2i) -> void:
	grid_pos = p_grid_pos
	position = (Vector2(grid_pos) * cell_size) + Vector2(cell_size / 2.0, cell_size / 2.0)


## Menggerakkan Kucing Bolu menyusuri urutan titik koordinat grid (`path`).
##
## @param path Array[Vector2i] koordinat rute dari titik start hingga target.
func move_along_path(path: Array[Vector2i]) -> void:
	# Validasi: Batalkan jika rute kosong atau hanya berisi posisi awal saja
	if path.size() <= 1:
		movement_finished.emit()
		return

	# Hentikan pergerakan/Tween sebelumnya jika Bolu masih dalam perjalanan
	if active_tween and active_tween.is_running():
		active_tween.kill()

	# Buat instance Tween baru dari scene tree
	active_tween = create_tween()
	# Set transisi animasi agar gerakan terlihat alami dan halus
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.set_ease(Tween.EASE_IN_OUT)

	# Iterasi dimulai dari indeks 1 (karena indeks 0 adalah posisi awal Bolu saat ini)
	for i in range(1, path.size()):
		var target_grid: Vector2i = path[i]
		
		# Kalkulasi titik tengah dunia (world coordinates) untuk tile tujuan
		var target_world_pos: Vector2 = (Vector2(target_grid) * cell_size) + Vector2(cell_size / 2.0, cell_size / 2.0)
		
		# Animasikan properti "position" menyusuri tiap titik secara berurutan
		active_tween.tween_property(self, "position", target_world_pos, step_duration)

	# Tunggu hingga seluruh rantai pergerakan Tween selesai dieksekusi
	await active_tween.finished
	
	# Perbarui posisi grid akhir Bolu setelah sampai di tujuan
	grid_pos = path[-1]
	
	# Pancarkan sinyal bahwa Bolu telah sampai di tujuan
	movement_finished.emit()