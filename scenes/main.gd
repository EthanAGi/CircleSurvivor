extends Node2D

@onready var player = $Player
@onready var spawn_timer = $SpawnTimer

@onready var time_label = $UI/UIRoot/TimeLabel
@onready var level_label = $UI/UIRoot/LevelLabel
@onready var exp_label = $UI/UIRoot/ExpLabel
@onready var game_over_label = $UI/UIRoot/GameOverLabel
@onready var restart_button = $UI/UIRoot/RestartButton

@onready var level_up_panel = $UI/UIRoot/LevelUpPanel
@onready var level_up_title = $UI/UIRoot/LevelUpPanel/VBoxContainer/TitleLabel
@onready var choice_button_1 = $UI/UIRoot/LevelUpPanel/VBoxContainer/ChoiceButton1
@onready var choice_button_2 = $UI/UIRoot/LevelUpPanel/VBoxContainer/ChoiceButton2
@onready var choice_button_3 = $UI/UIRoot/LevelUpPanel/VBoxContainer/ChoiceButton3

var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var exp_pickup_scene: PackedScene = preload("res://scenes/exp_pickup.tscn")
var orbit_ball_scene: PackedScene = preload("res://scenes/orbit_ball.tscn")
var lightning_scene: PackedScene = preload("res://scenes/lightning.tscn")

var game_over: bool = false
var survival_time: float = 0.0
var rng := RandomNumberGenerator.new()

var bullet_level: int = 1
var orbit_ball_level: int = 0
var lightning_level: int = 0

var orbit_ball_cooldown: float = 99999.0
var orbit_ball_duration: float = 0.0
var orbit_ball_count: int = 0
var orbit_ball_timer: float = 0.0

var lightning_cooldown: float = 99999.0
var lightning_range: float = 0.0
var lightning_strike_count: int = 0
var lightning_damage: int = 0
var lightning_timer: float = 0.0

var level_up_choices: Array = []

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

	choice_button_1.pressed.connect(func(): _on_level_up_choice_pressed(0))
	choice_button_2.pressed.connect(func(): _on_level_up_choice_pressed(1))
	choice_button_3.pressed.connect(func(): _on_level_up_choice_pressed(2))

	game_over_label.visible = false
	restart_button.visible = false

	level_up_panel.visible = false
	level_up_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	spawn_timer.wait_time = 1.0

	_apply_bullet_upgrade_stats()
	_on_player_exp_changed(player.level, player.current_exp, player.exp_to_next)

func _process(delta: float) -> void:
	if game_over:
		queue_redraw()
		return

	if get_tree().paused:
		queue_redraw()
		return

	survival_time += delta
	time_label.text = "Time: %.1f" % survival_time

	spawn_timer.wait_time = max(0.25, 1.0 - survival_time * 0.02)

	_handle_orbit_ball_weapon(delta)
	_handle_lightning_weapon(delta)

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

func _handle_orbit_ball_weapon(delta: float) -> void:
	if orbit_ball_level <= 0:
		return

	orbit_ball_timer -= delta

	if orbit_ball_timer <= 0.0:
		orbit_ball_timer = orbit_ball_cooldown
		_spawn_orbit_balls()

func _spawn_orbit_balls() -> void:
	for i in range(orbit_ball_count):
		var orbit_ball = orbit_ball_scene.instantiate()
		add_child(orbit_ball)
		orbit_ball.player = player
		orbit_ball.lifetime = orbit_ball_duration
		orbit_ball.angle_offset = TAU * float(i) / float(orbit_ball_count)

func _handle_lightning_weapon(delta: float) -> void:
	if lightning_level <= 0:
		return

	lightning_timer -= delta

	if lightning_timer <= 0.0:
		lightning_timer = lightning_cooldown
		_fire_lightning_weapon()

func _fire_lightning_weapon() -> void:
	var nearby_enemies: Array = _get_enemies_in_range(lightning_range)

	if nearby_enemies.is_empty():
		return

	var strikes_to_fire: int = min(lightning_strike_count, nearby_enemies.size())

	for i in range(strikes_to_fire):
		var enemy: Area2D = nearby_enemies[i]

		if enemy == null or not is_instance_valid(enemy):
			continue

		var lightning = lightning_scene.instantiate()
		add_child(lightning)
		lightning.global_position = enemy.global_position

		if enemy.has_method("take_damage"):
			enemy.take_damage(lightning_damage)

func _get_enemies_in_range(range_limit: float) -> Array:
	var enemies_in_range: Array = []

	for child in get_children():
		if child is Area2D and child.scene_file_path.ends_with("enemy.tscn"):
			if not is_instance_valid(child):
				continue

			var distance: float = player.global_position.distance_to(child.global_position)
			if distance <= range_limit:
				enemies_in_range.append(child)

	enemies_in_range.sort_custom(_sort_enemies_by_distance)

	return enemies_in_range

func _sort_enemies_by_distance(a: Area2D, b: Area2D) -> bool:
	var da: float = player.global_position.distance_to(a.global_position)
	var db: float = player.global_position.distance_to(b.global_position)
	return da < db

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
	_open_level_up_menu()

func _open_level_up_menu() -> void:
	level_up_choices = _build_level_up_choices()

	if level_up_choices.is_empty():
		return

	level_up_title.text = "Choose an Upgrade"
	level_up_panel.visible = true

	_set_choice_button(choice_button_1, 0)
	_set_choice_button(choice_button_2, 1)
	_set_choice_button(choice_button_3, 2)

	get_tree().paused = true

func _close_level_up_menu() -> void:
	level_up_panel.visible = false
	get_tree().paused = false

func _build_level_up_choices() -> Array:
	var choices: Array = []

	choices.append({
		"id": "bullet_upgrade",
		"text": "Upgrade Bullet\nFire faster"
	})

	if orbit_ball_level == 0:
		choices.append({
			"id": "unlock_orbit_ball",
			"text": "Unlock Orbit Ball\nA spinning projectile circles you"
		})
	else:
		choices.append({
			"id": "orbit_upgrade",
			"text": "Upgrade Orbit Ball\nSpawn more often and later add another ball"
		})

	if lightning_level == 0:
		choices.append({
			"id": "unlock_lightning",
			"text": "Unlock Lightning\nStrikes nearby enemies automatically"
		})
	else:
		choices.append({
			"id": "lightning_upgrade",
			"text": "Upgrade Lightning\nMore strikes, more range, more damage"
		})

	return choices

func _set_choice_button(button: Button, index: int) -> void:
	if index >= level_up_choices.size():
		button.visible = false
		button.disabled = true
		return

	button.visible = true
	button.disabled = false
	button.text = level_up_choices[index]["text"]

func _on_level_up_choice_pressed(index: int) -> void:
	if index >= level_up_choices.size():
		return

	var choice_id: String = level_up_choices[index]["id"]

	match choice_id:
		"bullet_upgrade":
			bullet_level += 1
			_apply_bullet_upgrade_stats()
		"unlock_orbit_ball":
			orbit_ball_level = 1
			_apply_orbit_ball_upgrade_stats()
			orbit_ball_timer = 0.1
		"orbit_upgrade":
			orbit_ball_level += 1
			_apply_orbit_ball_upgrade_stats()
		"unlock_lightning":
			lightning_level = 1
			_apply_lightning_upgrade_stats()
			lightning_timer = 0.1
		"lightning_upgrade":
			lightning_level += 1
			_apply_lightning_upgrade_stats()

	_close_level_up_menu()

func _apply_bullet_upgrade_stats() -> void:
	var new_wait_time: float = 0.5

	match bullet_level:
		1:
			new_wait_time = 0.50
		2:
			new_wait_time = 0.42
		3:
			new_wait_time = 0.35
		4:
			new_wait_time = 0.29
		5:
			new_wait_time = 0.24
		_:
			new_wait_time = max(0.12, 0.24 - float(bullet_level - 5) * 0.02)

	player.set_fire_rate(new_wait_time)

func _apply_orbit_ball_upgrade_stats() -> void:
	match orbit_ball_level:
		1:
			orbit_ball_cooldown = 4.0
			orbit_ball_duration = 2.0
			orbit_ball_count = 1
		2:
			orbit_ball_cooldown = 3.2
			orbit_ball_duration = 2.3
			orbit_ball_count = 1
		3:
			orbit_ball_cooldown = 2.5
			orbit_ball_duration = 2.6
			orbit_ball_count = 1
		4:
			orbit_ball_cooldown = 2.0
			orbit_ball_duration = 3.0
			orbit_ball_count = 2
		_:
			orbit_ball_cooldown = 1.6
			orbit_ball_duration = 3.2
			orbit_ball_count = 2

func _apply_lightning_upgrade_stats() -> void:
	match lightning_level:
		1:
			lightning_cooldown = 3.2
			lightning_range = 260.0
			lightning_strike_count = 1
			lightning_damage = 2
		2:
			lightning_cooldown = 2.8
			lightning_range = 300.0
			lightning_strike_count = 1
			lightning_damage = 3
		3:
			lightning_cooldown = 2.4
			lightning_range = 340.0
			lightning_strike_count = 2
			lightning_damage = 3
		4:
			lightning_cooldown = 2.0
			lightning_range = 380.0
			lightning_strike_count = 2
			lightning_damage = 4
		_:
			lightning_cooldown = 1.7
			lightning_range = 430.0
			lightning_strike_count = 3
			lightning_damage = 4

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
	get_tree().paused = false
	get_tree().reload_current_scene()
