extends Node

# Variabel global untuk mengecek apakah simulasi AI sedang berjalan
var is_game_active: bool = false

func _ready():
	print("Sistem GameManager siap beroperasi.")
	start_simulation()

func start_simulation():
	is_game_active = true
	print("Simulasi dimulai. AI diizinkan untuk mencari rute.")
	# Nanti, skrip AStar.gd milik Anggota 2 akan mengecek variabel is_game_active ini
	# sebelum mereka mulai menggerakkan NPC.

func end_simulation():
	is_game_active = false
	print("Tujuan tercapai atau simulasi dihentikan.")
