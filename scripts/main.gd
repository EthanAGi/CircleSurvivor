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

# Pause menu nodes
@onready var pause_menu: Control = _find_first_existing_node([
	"UI/UIRoot/PauseLayer/PauseMenu"
]) as Control

@onready var pause_title_label: Label = _find_first_existing_node([
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel",
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContain/PanelContain/MarginCont/VBoxCont/TitleLab"
]) as Label

@onready var pause_resume_button: Button = _find_first_existing_node([
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton",
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Resume",
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContain/PanelContain/MarginCont/VBoxCont/Resume"
]) as Button

@onready var pause_options_button: Button = _find_first_existing_node([
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OptionsButton",
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Options",
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContain/PanelContain/MarginCont/VBoxCont/Options"
]) as Button

@onready var pause_exit_button: Button = _find_first_existing_node([
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ExitButton",
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Exit",
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContain/PanelContain/MarginCont/VBoxCont/ExitButton",
	"UI/UIRoot/PauseLayer/PauseMenu/CenterContain/PanelContain/MarginCont/VBoxCont/ExitButt"
]) as Button

var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var enemy_projectile_scene: PackedScene = preload("res://scenes/enemy_projectile.tscn")
var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var exp_pickup_scene: PackedScene = preload("res://scenes/exp_pickup.tscn")
var orbit_ball_scene: PackedScene = preload("res://scenes/orbit_ball.tscn")
var lightning_scene: PackedScene = preload("res://scenes/lightning.tscn")
var missile_scene := load("res://scenes/missile.tscn") as PackedScene
var damage_number_script := load("res://scripts/damage_number.gd") as GDScript

var game_over: bool = false
var game_won: bool = false
var pause_menu_open: bool = false
var survival_time: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@export var win_time: float = 180.0

const BULLET_MAX_LEVEL: int = 8
const ORBIT_BALL_MAX_LEVEL: int = 5
const LIGHTNING_MAX_LEVEL: int = 5
const MISSILE_MAX_LEVEL: int = 5

const MAX_HEALTH_UPGRADES: int = 8
const MAX_ARMOR_UPGRADES: int = 5
const MAX_SPEED_UPGRADES: int = 6
const MAX_FIRE_RATE_UPGRADES: int = 6
const MAX_PICKUP_RADIUS_UPGRADES: int = 6

const MAX_PROJECTILE_SPEED_UPGRADES: int = 6
const MAX_ATTACK_SIZE_UPGRADES: int = 6
const MAX_CRIT_CHANCE_UPGRADES: int = 6

const RARITY_COMMON: String = "Common"
const RARITY_RARE: String = "Rare"
const RARITY_EPIC: String = "Epic"

const ENEMY_DAMAGE_NUMBER_COLOR: Color = Color(1.0, 0.95, 0.35)
const PLAYER_DAMAGE_NUMBER_COLOR: Color = Color(0.45, 0.95, 1.0)

var bullet_level: int = 1
var orbit_ball_level: int = 0
var lightning_level: int = 0
var missile_level: int = 0

var max_health_upgrade_count: int = 0
var armor_upgrade_count: int = 0
var speed_upgrade_count: int = 0
var fire_rate_upgrade_count: int = 0
var pickup_radius_upgrade_count: int = 0
var projectile_speed_upgrade_count: int = 0
var attack_size_upgrade_count: int = 0
var crit_chance_upgrade_count: int = 0

var projectile_speed_multiplier: float = 1.0
var attack_size_multiplier: float = 1.0
var crit_chance: float = 0.0

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

	process_mode = Node.PROCESS_MODE_ALWAYS

	_setup_camera()

	player.died.connect(_on_player_died)
	player.shoot_requested.connect(_on_player_shoot_requested)
	player.exp_changed.connect(_on_player_exp_changed)
	player.leveled_up.connect(_on_player_leveled_up)
	player.damaged.connect(_on_player_damaged)

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	restart_button.pressed.connect(_on_restart_button_pressed)

	choice_button_1.pressed.connect(func() -> void: _on_level_up_choice_pressed(0))
	choice_button_2.pressed.connect(func() -> void: _on_level_up_choice_pressed(1))
	choice_button_3.pressed.connect(func() -> void: _on_level_up_choice_pressed(2))

	game_over_label.visible = false
	restart_button.visible = false

	level_up_panel.visible = false
	level_up_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	if pause_menu != null:
		pause_menu.visible = false
		pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	if pause_resume_button != null:
		pause_resume_button.pressed.connect(_on_pause_resume_pressed)

	if pause_options_button != null:
		pause_options_button.pressed.connect(_on_pause_options_pressed)

	if pause_exit_button != null:
		pause_exit_button.pressed.connect(_on_pause_exit_pressed)

	_setup_pause_menu_focus()

	spawn_timer.wait_time = 1.0

	_apply_bullet_upgrade_stats()
	_on_player_exp_changed(player.level, player.current_exp, player.exp_to_next)
	time_label.text = "Time: %.1f" % survival_time

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return

	if game_over:
		return

	if level_up_panel.visible:
		return

	if pause_menu == null:
		return

	if pause_menu_open:
		_close_pause_menu()
	else:
		_open_pause_menu()

	get_viewport().set_input_as_handled()

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
	var time_progress: float = clamp(survival_time / win_time, 0.0, 1.0)

	var current_wait_time: float = 1.0
	var current_enemies_per_spawn: int = 1

	if cycle_time < CALM_DURATION:
		current_wait_time = lerp(1.10, 0.75, time_progress)
		current_enemies_per_spawn = 1

	elif cycle_time < CALM_DURATION + RAMP_DURATION:
		var t: float = (cycle_time - CALM_DURATION) / RAMP_DURATION
		current_wait_time = lerp(0.75, 0.40, t)
		current_wait_time = max(0.22, current_wait_time - time_progress * 0.08)

		if t < 0.5:
			current_enemies_per_spawn = 1
		else:
			current_enemies_per_spawn = 2

	elif cycle_time < CALM_DURATION + RAMP_DURATION + SWARM_DURATION:
		current_wait_time = lerp(0.35, 0.20, time_progress)
		current_enemies_per_spawn = 2

		if survival_time > 75.0 and rng.randf() < 0.18:
			current_enemies_per_spawn = 3

	else:
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
		orbit_ball.ball_radius = 10.0 * attack_size_multiplier
		orbit_ball.damage = 1
		orbit_ball.crit_chance = crit_chance

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
		lightning.strike_radius = 26.0 * attack_size_multiplier

		if enemy.has_method("take_damage"):
			enemy.take_damage(_roll_damage(lightning_damage))

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
	missile.speed = missile_speed * projectile_speed_multiplier
	missile.turn_speed = missile_turn_speed
	missile.damage = _roll_damage(missile_damage)
	missile.explosion_radius = 70.0 * attack_size_multiplier

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
	enemy.damaged.connect(_on_enemy_damaged)

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

	if survival_time < 25.0:
		if roll < 0.80:
			return 0
		return 1

	if survival_time < 55.0:
		if roll < 0.50:
			return 0
		elif roll < 0.75:
			return 1
		return 2

	if survival_time < 90.0:
		if roll < 0.35:
			return 0
		elif roll < 0.58:
			return 1
		elif roll < 0.82:
			return 2
		return 3

	if roll < 0.22:
		return 0
	elif roll < 0.46:
		return 1
	elif roll < 0.72:
		return 2
	return 3

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
	bullet.speed = 500.0 * projectile_speed_multiplier
	bullet.damage = _roll_damage(1)
	bullet.radius = 8.0 * attack_size_multiplier

func _on_enemy_damaged(damage_position: Vector2, amount: int) -> void:
	if game_over:
		return

	_spawn_damage_number(damage_position, amount, ENEMY_DAMAGE_NUMBER_COLOR)

func _on_player_damaged(damage_position: Vector2, amount: int) -> void:
	if game_over:
		return

	_spawn_damage_number(damage_position, amount, PLAYER_DAMAGE_NUMBER_COLOR)

func _spawn_damage_number(world_position: Vector2, amount: int, color: Color) -> void:
	if damage_number_script == null:
		return

	var damage_number: Node2D = damage_number_script.new()
	damage_number.setup(amount, color)
	add_child(damage_number)
	damage_number.global_position = world_position

func _on_enemy_died(enemy_position: Vector2, exp_amount: int, enemy_type: int) -> void:
	if game_over:
		return

	call_deferred("_spawn_exp_pickup", enemy_position, exp_amount, enemy_type)

func _spawn_exp_pickup(enemy_position: Vector2, exp_amount: int, enemy_type: int) -> void:
	if game_over:
		return

	var exp_type: int = _get_exp_type_from_enemy_type(enemy_type, exp_amount)

	var exp_pickup: Node = exp_pickup_scene.instantiate()
	add_child(exp_pickup)
	exp_pickup.global_position = enemy_position
	exp_pickup.setup(player, exp_type)
	exp_pickup.collected.connect(_on_exp_collected)

func _get_exp_type_from_enemy_type(enemy_type: int, exp_amount: int) -> int:
	match enemy_type:
		0:
			return 0
		1:
			return 1
		2:
			return 2
		3:
			return 1

	if exp_amount >= 3:
		return 2
	elif exp_amount == 2:
		return 1
	return 0

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
	if pause_menu != null:
		pause_menu_open = false
		pause_menu.visible = false

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

	if max_health_upgrade_count < MAX_HEALTH_UPGRADES:
		pool.append({
			"id": "max_health_upgrade",
			"text": "Max Health Up\n+1 max HP and heal 1"
		})

	if armor_upgrade_count < MAX_ARMOR_UPGRADES:
		pool.append({
			"id": "armor_upgrade",
			"text": "Armor Up\nTake 1 less damage"
		})

	if speed_upgrade_count < MAX_SPEED_UPGRADES:
		pool.append(_make_rarity_choice(
			"speed_upgrade",
			"Move Speed Up",
			"Move faster",
			25.0
		))

	if fire_rate_upgrade_count < MAX_FIRE_RATE_UPGRADES:
		pool.append({
			"id": "fire_rate_upgrade",
			"text": "Attack Speed Up\nShoot faster"
		})

	if pickup_radius_upgrade_count < MAX_PICKUP_RADIUS_UPGRADES:
		pool.append({
			"id": "pickup_radius_upgrade",
			"text": "Pickup Radius Up\nCollect EXP from farther away"
		})

	if projectile_speed_upgrade_count < MAX_PROJECTILE_SPEED_UPGRADES:
		pool.append(_make_rarity_choice(
			"projectile_speed_upgrade",
			"Projectile Speed Up",
			"Bullets and missiles travel faster",
			0.15
		))

	if attack_size_upgrade_count < MAX_ATTACK_SIZE_UPGRADES:
		pool.append(_make_rarity_choice(
			"attack_size_upgrade",
			"Attack Size Up",
			"Bigger bullets, lightning, missiles, and orbit balls",
			0.12
		))

	if crit_chance_upgrade_count < MAX_CRIT_CHANCE_UPGRADES:
		pool.append(_make_rarity_choice(
			"crit_chance_upgrade",
			"Crit Chance Up",
			"Chance for attacks to deal double damage",
			0.08
		))

	pool.shuffle()

	var result: Array[Dictionary] = []
	var max_choices: int = min(3, pool.size())

	for i in range(max_choices):
		result.append(pool[i])

	return result

func _make_rarity_choice(choice_id: String, title: String, description: String, amount: float) -> Dictionary:
	var rarity: String = _roll_rarity()
	return {
		"id": choice_id,
		"text": "%s %s\n%s" % [rarity, title, description],
		"rarity": rarity,
		"amount": amount * _get_rarity_multiplier(rarity)
	}

func _roll_rarity() -> String:
	var roll: float = rng.randf()

	if roll < 0.60:
		return RARITY_COMMON
	elif roll < 0.90:
		return RARITY_RARE
	return RARITY_EPIC

func _get_rarity_multiplier(rarity: String) -> float:
	match rarity:
		RARITY_COMMON:
			return 1.0
		RARITY_RARE:
			return 1.5
		RARITY_EPIC:
			return 2.0
		_:
			return 1.0

func _get_rarity_color(rarity: String) -> Color:
	match rarity:
		RARITY_RARE:
			return Color(0.70, 0.82, 1.0)
		RARITY_EPIC:
			return Color(0.88, 0.66, 1.0)
		_:
			return Color(1.0, 1.0, 1.0)

func _set_choice_button(button: Button, index: int) -> void:
	if index >= level_up_choices.size():
		button.visible = false
		button.disabled = true
		return

	button.visible = true
	button.disabled = false
	button.text = str(level_up_choices[index]["text"])

	var rarity: String = str(level_up_choices[index].get("rarity", ""))
	button.modulate = _get_rarity_color(rarity)

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

		"max_health_upgrade":
			max_health_upgrade_count += 1
			player.increase_max_health(1)

		"armor_upgrade":
			armor_upgrade_count += 1
			player.increase_armor(1)

		"speed_upgrade":
			speed_upgrade_count += 1
			player.increase_speed(float(choice.get("amount", 25.0)))

		"fire_rate_upgrade":
			fire_rate_upgrade_count += 1
			player.improve_fire_rate(0.10)

		"pickup_radius_upgrade":
			pickup_radius_upgrade_count += 1
			player.increase_pickup_radius(0.20)

		"projectile_speed_upgrade":
			projectile_speed_upgrade_count += 1
			projectile_speed_multiplier += float(choice.get("amount", 0.15))

		"attack_size_upgrade":
			attack_size_upgrade_count += 1
			attack_size_multiplier += float(choice.get("amount", 0.12))

		"crit_chance_upgrade":
			crit_chance_upgrade_count += 1
			crit_chance += float(choice.get("amount", 0.08))
			crit_chance = min(crit_chance, 0.60)

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
	pause_menu_open = false

	if pause_menu != null:
		pause_menu.visible = false

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
	pause_menu_open = false

	if pause_menu != null:
		pause_menu.visible = false

	game_over_label.text = "YOU WIN"
	game_over_label.visible = true
	restart_button.visible = true

	spawn_timer.stop()

	for child in get_children():
		if child is Area2D and child.has_method("stop"):
			child.stop()

func _on_restart_button_pressed() -> void:
	pause_menu_open = false

	if pause_menu != null:
		pause_menu.visible = false

	get_tree().paused = false
	get_tree().reload_current_scene()

func _open_pause_menu() -> void:
	if pause_menu == null:
		return

	pause_menu_open = true
	pause_menu.visible = true

	if pause_title_label != null:
		pause_title_label.text = "Paused"

	get_tree().paused = true

	if pause_resume_button != null:
		pause_resume_button.grab_focus()

func _close_pause_menu() -> void:
	pause_menu_open = false

	if pause_menu != null:
		pause_menu.visible = false

	get_tree().paused = false

func _on_pause_resume_pressed() -> void:
	_close_pause_menu()

func _on_pause_options_pressed() -> void:
	print("Pause options pressed.")
	# Placeholder for now.
	# If you want, next I can wire this to your actual options menu.

func _on_pause_exit_pressed() -> void:
	pause_menu_open = false

	if pause_menu != null:
		pause_menu.visible = false

	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _setup_pause_menu_focus() -> void:
	if pause_resume_button == null or pause_options_button == null or pause_exit_button == null:
		return

	pause_resume_button.focus_mode = Control.FOCUS_ALL
	pause_options_button.focus_mode = Control.FOCUS_ALL
	pause_exit_button.focus_mode = Control.FOCUS_ALL

	pause_resume_button.focus_neighbor_top = pause_exit_button.get_path()
	pause_resume_button.focus_neighbor_bottom = pause_options_button.get_path()

	pause_options_button.focus_neighbor_top = pause_resume_button.get_path()
	pause_options_button.focus_neighbor_bottom = pause_exit_button.get_path()

	pause_exit_button.focus_neighbor_top = pause_options_button.get_path()
	pause_exit_button.focus_neighbor_bottom = pause_resume_button.get_path()

	pause_resume_button.mouse_entered.connect(func() -> void: pause_resume_button.grab_focus())
	pause_options_button.mouse_entered.connect(func() -> void: pause_options_button.grab_focus())
	pause_exit_button.mouse_entered.connect(func() -> void: pause_exit_button.grab_focus())

func _find_first_existing_node(paths: Array[String]) -> Node:
	for node_path in paths:
		var node: Node = get_node_or_null(node_path)
		if node != null:
			return node
	return null

func _roll_damage(base_damage: int) -> int:
	if rng.randf() < crit_chance:
		return base_damage * 2
	return base_damage
