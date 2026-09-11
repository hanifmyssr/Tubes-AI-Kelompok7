class_name Player
extends Node2D

## Sinyal yang dipancarkan saat Player berpindah ubin
signal player_moved(new_grid_position: Vector2i)

@export var map_data: MapData
@export var move_duration: float = 0.12

var grid_position: Vector2i = Vector2i(0, 0)
var is_moving: bool = false
var active_tween: Tween = null
var call_bubble_tween: Tween = null

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var call_bubble: Label = get_node_or_null("CallBubble")

func _ready() -> void:
	# Sesuaikan skala visual karakter agar proporsional dengan ubin 16x16
	if sprite:
		sprite.scale = Vector2(0.5, 0.5)

	# Auto-detect MapData jika belum diisi di Inspector
	if not map_data:
		find_map_data()

	# Jika MapData sudah siap, sinkronkan posisi spawn awal
	if map_data:
		if not map_data.is_node_ready():
			await map_data.ready
		# Spawn at map center so the player is visible on screen
		var preferred_spawn := map_data.get_map_center()
		grid_position = map_data.get_valid_spawn_point(preferred_spawn)
		update_world_position_instant()
		# Beritahu sistem bahwa player berada di posisi spawn
		player_moved.emit(grid_position)

func show_call_bubble() -> void:
	if not call_bubble:
		return

	call_bubble.visible = true
	if call_bubble_tween and call_bubble_tween.is_valid():
		call_bubble_tween.kill()

	call_bubble_tween = create_tween()
	call_bubble_tween.tween_interval(1.5)
	call_bubble_tween.tween_callback(call_bubble.hide)

func find_map_data() -> void:
	map_data = get_node_or_null("../Map") as MapData
	if not map_data:
		map_data = get_node_or_null("../MapData") as MapData
	if not map_data and get_parent() is MapData:
		map_data = get_parent() as MapData

func _process(_delta: float) -> void:
	if is_moving:
		return

	var direction: Vector2i = Vector2i.ZERO
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction = Vector2i.UP
	elif Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction = Vector2i.DOWN
	elif Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction = Vector2i.LEFT
	elif Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction = Vector2i.RIGHT

	if direction != Vector2i.ZERO:
		try_move(direction)

func try_move(direction: Vector2i) -> void:
	if is_moving:
		return

	if not map_data:
		find_map_data()
		if not map_data:
			return

	var target_pos: Vector2i = grid_position + direction

	# Validasi apakah koordinat tujuan dapat dilalui (walkable)
	if map_data.is_walkable(target_pos):
		grid_position = target_pos
		player_moved.emit(grid_position)
		move_to_grid(target_pos)

func move_to_grid(target_grid: Vector2i) -> void:
	is_moving = true
	var target_world_pos = map_data.map_to_world(target_grid)

	if active_tween and active_tween.is_running():
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_QUAD)
	active_tween.set_ease(Tween.EASE_OUT)
	# Use global_position because map_to_world returns a global world coordinate
	active_tween.tween_property(self, "global_position", target_world_pos, move_duration)

	await active_tween.finished
	is_moving = false
	player_moved.emit(grid_position)

func update_world_position_instant() -> void:
	if map_data:
		# map_to_world returns a global world position; use global_position to assign it
		global_position = map_data.map_to_world(grid_position)
