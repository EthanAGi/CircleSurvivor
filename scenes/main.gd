extends Node2D

@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
@onready var time_label = $UI/TimeLabel
@onready var level_label = $UI/LevelLabel
@onready var exp_label = $UI/ExpLabel
@onready var game_over_label = $UI/GameOverLabel
@onready var restart_button = $UI/RestartButton

var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var exp_pickup_scene: PackedScene = preload("res://scenes/exp_pickup.tscn")

var game_over: bool = false
var survival_time: float = 0.0
var rng := RandomNumberGenerator.new()

const GRID_SIZE: float = 128.0
const GRID_HALF_WIDTH: float = 2200.0
const GRID_HALF_HEIGHT: float = 1400.0
const BG_COLOR: Color = Color(0.08, 0.08, 0.1)
const GRID_COLOR: Color = Color(0.18, 0.18, 0.22)

func _ready() -> void:
	rng.randomize()

	_setup_camera()

	player.died.connect(_on_player_died)
	player.shoot_requested.connect(_on_player_shoot_requested)
	player.exp_changed.connect(_on_player_exp_changed)
	player.leveled_up.connect(_on_player_leveled_up)

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	restart_button.pressed.connect(_on_restart_button_pressed)

	game_over_label.visible = false
	restart_button.visible = false

	spawn_timer.wait_time = 1.0

	_on_player_exp_changed(player.level, player.current_exp, player.exp_to_next)

func _process(delta: float) -> void:
	if game_over:
		queue_redraw()
		return

	survival_time += delta
	time_label.text = "Time: %.1f" % survival_time

	spawn_timer.wait_time = max(0.25, 1.0 - survival_time * 0.02)

	queue_redraw()

func _draw() -> void:
	if player == null or not is_instance_valid(player):
		return

	var center: Vector2 = player.global_position

	var left: float = center.x - GRID_HALF_WIDTH
	var right: float = center.x + GRID_HALF_WIDTH
	var top: float = center.y - GRID_HALF_HEIGHT
	var bottom: float = center.y + GRID_HALF_HEIGHT

	draw_rect(
		Rect2(
			Vector2(left, top),
			Vector2(GRID_HALF_WIDTH * 2.0, GRID_HALF_HEIGHT * 2.0)
		),
		BG_COLOR,
		true
	)

	var start_x: float = floor(left / GRID_SIZE) * GRID_SIZE
	var x: float = start_x
	while x <= right:
		draw_line(Vector2(x, top), Vector2(x, bottom), GRID_COLOR, 2.0)
		x += GRID_SIZE

	var start_y: float = floor(top / GRID_SIZE) * GRID_SIZE
	var y: float = start_y
	while y <= bottom:
		draw_line(Vector2(left, y), Vector2(right, y), GRID_COLOR, 2.0)
		y += GRID_SIZE

func _setup_camera() -> void:
	var camera: Camera2D = Camera2D.new()
	camera.enabled = true
	camera.position = Vector2.ZERO
	player.add_child(camera)

func _on_spawn_timer_timeout() -> void:
	if game_over:
		return

	var enemy = enemy_scene.instantiate()
	add_child(enemy)

	enemy.player = player
	enemy.global_position = _get_spawn_position()
	enemy.body_entered.connect(_on_enemy_body_entered)
	enemy.died.connect(_on_enemy_died)

func _on_player_shoot_requested(spawn_position: Vector2) -> void:
	if game_over:
		return

	var target = _get_nearest_enemy()
	if target == null:
		return

	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = spawn_position
	bullet.direction = (target.global_position - spawn_position).normalized()

func _on_enemy_died(enemy_position: Vector2, exp_amount: int) -> void:
	if game_over:
		return

	call_deferred("_spawn_exp_pickup", enemy_position, exp_amount)

func _spawn_exp_pickup(enemy_position: Vector2, exp_amount: int) -> void:
	if game_over:
		return

	var exp_pickup = exp_pickup_scene.instantiate()
	add_child(exp_pickup)
	exp_pickup.global_position = enemy_position
	exp_pickup.setup(player, exp_amount)
	exp_pickup.collected.connect(_on_exp_collected)

func _on_exp_collected(amount: int) -> void:
	if game_over:
		return

	player.gain_experience(amount)

func _on_player_exp_changed(level: int, current_exp: int, exp_to_next: int) -> void:
	level_label.text = "Level: %d" % level
	exp_label.text = "EXP: %d / %d" % [current_exp, exp_to_next]

func _on_player_leveled_up(new_level: int) -> void:
	print("Level up! New level: ", new_level)

func _get_nearest_enemy() -> Area2D:
	var nearest: Area2D = null
	var nearest_distance: float = INF

	for child in get_children():
		if child is Area2D and child.scene_file_path.ends_with("enemy.tscn"):
			var distance: float = player.global_position.distance_to(child.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = child

	return nearest

func _get_spawn_position() -> Vector2:
	var angle: float = rng.randf_range(0.0, TAU)
	var distance: float = rng.randf_range(500.0, 700.0)
	var offset: Vector2 = Vector2.RIGHT.rotated(angle) * distance
	return player.global_position + offset

func _on_enemy_body_entered(body: Node) -> void:
	if game_over:
		return

	if body == player:
		player.die()

func _on_player_died() -> void:
	game_over = true
	game_over_label.visible = true
	restart_button.visible = true
	spawn_timer.stop()

	for child in get_children():
		if child is Area2D and child.has_method("stop"):
			child.stop()

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
