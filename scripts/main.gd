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
var enemy_projectile_scene: PackedScene = preload("res://scenes/enemy_projectile.tscn")
var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var exp_pickup_scene: PackedScene = preload("res://scenes/exp_pickup.tscn")
var orbit_ball_scene: PackedScene = preload("res://scenes/orbit_ball.tscn")
var lightning_scene: PackedScene = preload("res://scenes/lightning.tscn")
var missile_scene := load("res://scenes/missile.tscn") as PackedScene

var game_over: bool = false
var game_won: bool = false
var survival_time: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@export var win_time: float = 180.0

const BULLET_MAX_LEVEL: int = 8
const ORBIT_BALL_MAX_LEVEL: int = 5
const LIGHTNING_MAX_LEVEL: int = 5
const MISSILE_MAX_LEVEL: int = 5

var bullet_level: int = 1
var orbit_ball_level: int = 0
var lightning_level: int = 0
var missile_level: int = 0

var orbit_ball_cooldown: float = 99999.0
var orbit_ball_duration: float = 0.0
var orbit_ball_count: int = 0
var orbit_ball_timer: float = 0.0

var lightning_cooldown: float = 99999.0
var lightning_range: float = 0.0
var lightning_strike_count: int = 0
var lightning_damage: int = 0
var lightning_timer: float = 0.0

var missile_cooldown: float = 99999.0
var missile_damage: int = 0
var missile_speed: float = 0.0
var missile_turn_speed: float = 0.0
var missile_timer: float = 0.0

var level_up_choices: Array[Dictionary] = []

const GRID_SIZE: float = 128.0
const GRID_HALF_WIDTH: float = 2200.0
const GRID_HALF_HEIGHT: float = 1400.0
const BG_COLOR: Color = Color(0.08, 0.08, 0.1)
const GRID_COLOR: Color = Color(0.18, 0.18, 0.22)

# =========================
# Difficulty / spawn pacing
# =========================
const CALM_DURATION: float = 10.0
const RAMP_DURATION: float = 8.0
const SWARM_DURATION: float = 7.0
const RECOVERY_DURATION: float = 5.0
const SPAWN_CYCLE_LENGTH: float = CALM_DURATION + RAMP_DURATION + SWARM_DURATION + RECOVERY_DURATION

const BASE_MAX_ENEMIES: int = 18
const MAX_EXTRA_ENEMIES_OVER_TIME: int = 16

var enemies_per_spawn: int = 1

func _ready() -> void:
	rng.randomize()

	_setup_camera()

	player.died.connect(_on_player_died)
	player.shoot_requested.connect(_on_player_shoot_requested)
	player.exp_changed.connect(_on_player_exp_changed)
	player.leveled_up.connect(_on_player_leveled_up)

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	restart_button.pressed.connect(_on_restart_button_pressed)

	choice_button_1.pressed.connect(func() -> void: _on_level_up_choice_pressed(0))
	choice_button_2.pressed.connect(func() -> void: _on_level_up_choice_pressed(1))
	choice_button_3.pressed.connect(func() -> void: _on_level_up_choice_pressed(2))

	game_over_label.visible = false
	restart_button.visible = false

	level_up_panel.visible = false
	level_up_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	spawn_timer.wait_time = 1.0

	_apply_bullet_upgrade_stats()
	_on_player_exp_changed(player.level, player.current_exp, player.exp_to_next)
	time_label.text = "Time: %.1f" % survival_time

func _process(delta: float) -> void:
	if game_over:
		queue_redraw()
		return

	if get_tree().paused:
		queue_redraw()
		return

	survival_time += delta

	if survival_time >= win_time:
		survival_time = win_time
		time_label.text = "Time: %.1f" % survival_time
		_on_player_won()
		queue_redraw()
		return

	time_label.text = "Time: %.1f" % survival_time

	_update_spawn_difficulty()

	_handle_orbit_ball_weapon(delta)
	_handle_lightning_weapon(delta)
	_handle_missile_weapon(delta)

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

func _update_spawn_difficulty() -> void:
	var cycle_time: float = fmod(survival_time, SPAWN_CYCLE_LENGTH)

	# This slowly increases the overall difficulty as time goes on.
	var time_progress: float = clamp(survival_time / win_time, 0.0, 1.0)

	var current_wait_time: float = 1.0
	var current_enemies_per_spawn: int = 1

	if cycle_time < CALM_DURATION:
		# Calm phase: fewer enemies
		current_wait_time = lerp(1.10, 0.75, time_progress)
		current_enemies_per_spawn = 1

	elif cycle_time < CALM_DURATION + RAMP_DURATION:
		# Ramp phase: getting busier
		var t: float = (cycle_time - CALM_DURATION) / RAMP_DURATION
		current_wait_time = lerp(0.75, 0.40, t)
		current_wait_time = max(0.22, current_wait_time - time_progress * 0.08)

		if t < 0.5:
			current_enemies_per_spawn = 1
		else:
			current_enemies_per_spawn = 2

	elif cycle_time < CALM_DURATION + RAMP_DURATION + SWARM_DURATION:
		# Swarm phase: intense pressure
		current_wait_time = lerp(0.35, 0.20, time_progress)
		current_enemies_per_spawn = 2

		# Later in the run, swarms can occasionally hit 3 at once
		if survival_time > 75.0 and rng.randf() < 0.18:
			current_enemies_per_spawn = 3

	else:
		# Recovery phase: still dangerous, but not max pressure
		current_wait_time = lerp(0.85, 0.55, time_progress)
		current_enemies_per_spawn = 1

	spawn_timer.wait_time = current_wait_time
	enemies_per_spawn = current_enemies_per_spawn

func _handle_orbit_ball_weapon(delta: float) -> void:
	if orbit_ball_level <= 0:
		return

	orbit_ball_timer -= delta

	if orbit_ball_timer <= 0.0:
		orbit_ball_timer = orbit_ball_cooldown
		_spawn_orbit_balls()

func _spawn_orbit_balls() -> void:
	for i in range(orbit_ball_count):
		var orbit_ball: Node = orbit_ball_scene.instantiate()
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
	var nearby_enemies: Array[Area2D] = _get_enemies_in_range(lightning_range)

	if nearby_enemies.is_empty():
		return

	var strikes_to_fire: int = min(lightning_strike_count, nearby_enemies.size())

	for i in range(strikes_to_fire):
		var enemy: Area2D = nearby_enemies[i]

		if enemy == null or not is_instance_valid(enemy):
			continue

		var lightning: Node = lightning_scene.instantiate()
		add_child(lightning)
		lightning.global_position = enemy.global_position

		if enemy.has_method("take_damage"):
			enemy.take_damage(lightning_damage)

func _handle_missile_weapon(delta: float) -> void:
	if missile_level <= 0:
		return

	missile_timer -= delta

	if missile_timer <= 0.0:
		missile_timer = missile_cooldown
		_fire_missile_weapon()

func _fire_missile_weapon() -> void:
	var target: Area2D = _get_nearest_enemy()

	if target == null:
		return

	var missile = missile_scene.instantiate()
	add_child(missile)
	missile.global_position = player.global_position

	var initial_direction: Vector2 = (target.global_position - player.global_position).normalized()
	if initial_direction == Vector2.ZERO:
		initial_direction = Vector2.RIGHT

	missile.direction = initial_direction
	missile.target = target
	missile.speed = missile_speed
	missile.turn_speed = missile_turn_speed
	missile.damage = missile_damage

func _get_enemies_in_range(range_limit: float) -> Array[Area2D]:
	var enemies_in_range: Array[Area2D] = []

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

	var active_enemy_count: int = _get_active_enemy_count()
	var max_enemies: int = _get_current_max_enemies()

	if active_enemy_count >= max_enemies:
		return

	var spawn_count: int = min(enemies_per_spawn, max_enemies - active_enemy_count)

	for i in range(spawn_count):
		_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy: Area2D = enemy_scene.instantiate()
	add_child(enemy)

	enemy.player = player
	enemy.global_position = _get_spawn_position()
	enemy.projectile_scene = enemy_projectile_scene
	enemy.enemy_type = _roll_enemy_type_for_current_time()

	enemy.body_entered.connect(_on_enemy_body_entered.bind(enemy))
	enemy.died.connect(_on_enemy_died)

func _get_active_enemy_count() -> int:
	var count: int = 0

	for child in get_children():
		if child is Area2D and child.scene_file_path.ends_with("enemy.tscn"):
			if is_instance_valid(child):
				count += 1

	return count

func _get_current_max_enemies() -> int:
	var time_progress: float = clamp(survival_time / win_time, 0.0, 1.0)
	return BASE_MAX_ENEMIES + int(round(MAX_EXTRA_ENEMIES_OVER_TIME * time_progress))

func _roll_enemy_type_for_current_time() -> int:
	var roll: float = rng.randf()

	# Early game: mostly basic, a few fast
	if survival_time < 25.0:
		if roll < 0.80:
			return 0 # BASIC
		return 1 # FAST

	# Mid game: introduce tank
	if survival_time < 55.0:
		if roll < 0.50:
			return 0 # BASIC
		elif roll < 0.75:
			return 1 # FAST
		return 2 # TANK

	# Later: introduce ranged
	if survival_time < 90.0:
		if roll < 0.35:
			return 0 # BASIC
		elif roll < 0.58:
			return 1 # FAST
		elif roll < 0.82:
			return 2 # TANK
		return 3 # RANGED

	# Endgame mix
	if roll < 0.22:
		return 0 # BASIC
	elif roll < 0.46:
		return 1 # FAST
	elif roll < 0.72:
		return 2 # TANK
	return 3 # RANGED

func _on_player_shoot_requested(spawn_position: Vector2) -> void:
	if game_over:
		return

	var target: Area2D = _get_nearest_enemy()
	if target == null:
		return

	var bullet: Node = bullet_scene.instantiate()
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

	var exp_pickup: Node = exp_pickup_scene.instantiate()
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

func _build_level_up_choices() -> Array[Dictionary]:
	var pool: Array[Dictionary] = []

	if bullet_level < BULLET_MAX_LEVEL:
		pool.append({
			"id": "bullet_upgrade",
			"text": "Upgrade Bullet\nFire faster"
		})

	if orbit_ball_level == 0:
		pool.append({
			"id": "unlock_orbit_ball",
			"text": "Unlock Orbit Ball\nA spinning projectile circles you"
		})
	elif orbit_ball_level < ORBIT_BALL_MAX_LEVEL:
		pool.append({
			"id": "orbit_upgrade",
			"text": "Upgrade Orbit Ball\nSpawn more often and last longer"
		})

	if lightning_level == 0:
		pool.append({
			"id": "unlock_lightning",
			"text": "Unlock Lightning\nStrikes nearby enemies automatically"
		})
	elif lightning_level < LIGHTNING_MAX_LEVEL:
		pool.append({
			"id": "lightning_upgrade",
			"text": "Upgrade Lightning\nMore strikes, range, and damage"
		})

	if missile_level == 0:
		pool.append({
			"id": "unlock_missile",
			"text": "Unlock Homing Missile\nTracks enemies and hits hard"
		})
	elif missile_level < MISSILE_MAX_LEVEL:
		pool.append({
			"id": "missile_upgrade",
			"text": "Upgrade Homing Missile\nFaster reload, more damage, better tracking"
		})

	pool.shuffle()

	var result: Array[Dictionary] = []
	var max_choices: int = min(3, pool.size())

	for i in range(max_choices):
		result.append(pool[i])

	return result

func _set_choice_button(button: Button, index: int) -> void:
	if index >= level_up_choices.size():
		button.visible = false
		button.disabled = true
		return

	button.visible = true
	button.disabled = false
	button.text = str(level_up_choices[index]["text"])

func _on_level_up_choice_pressed(index: int) -> void:
	if index >= level_up_choices.size():
		return

	var choice: Dictionary = level_up_choices[index]
	var choice_id: String = str(choice["id"])

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
		"unlock_missile":
			missile_level = 1
			_apply_missile_upgrade_stats()
			missile_timer = 0.1
		"missile_upgrade":
			missile_level += 1
			_apply_missile_upgrade_stats()

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

func _apply_missile_upgrade_stats() -> void:
	match missile_level:
		1:
			missile_cooldown = 2.4
			missile_damage = 3
			missile_speed = 320.0
			missile_turn_speed = 5.0
		2:
			missile_cooldown = 2.0
			missile_damage = 4
			missile_speed = 340.0
			missile_turn_speed = 5.8
		3:
			missile_cooldown = 1.7
			missile_damage = 5
			missile_speed = 360.0
			missile_turn_speed = 6.5
		4:
			missile_cooldown = 1.45
			missile_damage = 6
			missile_speed = 390.0
			missile_turn_speed = 7.2
		_:
			missile_cooldown = 1.2
			missile_damage = 7
			missile_speed = 420.0
			missile_turn_speed = 8.0

func _get_nearest_enemy() -> Area2D:
	var nearest: Area2D = null
	var nearest_distance: float = INF

	for child in get_children():
		if child is Area2D and child.scene_file_path.ends_with("enemy.tscn"):
			if not is_instance_valid(child):
				continue

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

func _on_enemy_body_entered(body: Node, enemy: Area2D) -> void:
	if game_over:
		return

	if body != player:
		return

	if enemy != null and is_instance_valid(enemy) and enemy.has_method("get_touch_damage"):
		player.take_damage(enemy.get_touch_damage())
	else:
		player.take_damage(1)

func _on_player_died() -> void:
	game_over = true
	game_won = false
	game_over_label.text = "GAME OVER"
	game_over_label.visible = true
	restart_button.visible = true
	spawn_timer.stop()

	for child in get_children():
		if child is Area2D and child.has_method("stop"):
			child.stop()

func _on_player_won() -> void:
	if game_over:
		return

	game_over = true
	game_won = true

	game_over_label.text = "YOU WIN"
	game_over_label.visible = true
	restart_button.visible = true

	spawn_timer.stop()

	for child in get_children():
		if child is Area2D and child.has_method("stop"):
			child.stop()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
