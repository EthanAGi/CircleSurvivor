extends Area2D

signal died(enemy_position: Vector2, exp_amount: int, enemy_type: int, enemy_modifier: int)
signal damaged(damage_position: Vector2, amount: int)

enum EnemyType {
	BASIC,
	FAST,
	TANK,
	RANGED,
	ELITE
}

enum EnemyModifier {
	NONE,
	BURNING,
	ARMORED,
	SWIFT,
	SPLITTING,
	EXPLOSIVE
}

@export var enemy_type: int = EnemyType.BASIC
@export var enemy_modifier: int = EnemyModifier.NONE
@export var projectile_scene: PackedScene

var speed: float = 120.0
var max_health: int = 3
var exp_drop_amount: int = 1
var touch_damage: int = 1
var elite_level: int = 1

var player: Node2D = null
var is_active: bool = true
var is_dead: bool = false
var current_health: int = 0

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 9.0
var knockback_stop_speed: float = 8.0

var shoot_cooldown: float = 1.8
var shoot_timer: float = 0.0
var desired_range: float = 260.0
var stop_range: float = 220.0
var retreat_range: float = 170.0

var burn_time_left: float = 0.0
var burn_tick_timer: float = 0.0
var burn_tick_interval: float = 0.5
var burn_tick_damage: int = 1

var shock_time_left: float = 0.0
var shock_tick_timer: float = 0.0
var shock_tick_interval: float = 0.45
var shock_tick_damage: int = 1
var shock_chain_radius: float = 90.0
var shock_chain_damage: int = 1
var shock_has_chained: bool = false

func _ready() -> void:
	_apply_type_stats()
	_apply_modifier_stats()
	current_health = max_health
	shoot_timer = randf_range(0.4, shoot_cooldown)
	_apply_collision_size()
	queue_redraw()

func _process(delta: float) -> void:
	if is_dead:
		return

	_process_status_effects(delta)

	if not is_active:
		queue_redraw()
		return

	if player == null or not is_instance_valid(player):
		queue_redraw()
		return

	match enemy_type:
		EnemyType.BASIC:
			_process_chase(delta)
		EnemyType.FAST:
			_process_chase(delta)
		EnemyType.TANK:
			_process_chase(delta)
		EnemyType.RANGED:
			_process_ranged(delta)
		EnemyType.ELITE:
			_process_chase(delta)

	_process_knockback(delta)
	queue_redraw()

func _process_status_effects(delta: float) -> void:
	if burn_time_left > 0.0:
		burn_time_left -= delta
		burn_tick_timer -= delta

		if burn_tick_timer <= 0.0:
			burn_tick_timer = burn_tick_interval
			take_damage(burn_tick_damage)

		if burn_time_left <= 0.0:
			burn_time_left = 0.0

	if shock_time_left > 0.0:
		shock_time_left -= delta
		shock_tick_timer -= delta

		if shock_tick_timer <= 0.0:
			shock_tick_timer = shock_tick_interval
			take_damage(shock_tick_damage)

		if not shock_has_chained:
			shock_has_chained = true
			_chain_shock_to_nearby_enemy()

		if shock_time_left <= 0.0:
			shock_time_left = 0.0

func apply_burn(duration: float, tick_damage: int, tick_interval: float = 0.5) -> void:
	if is_dead:
		return

	burn_time_left = max(burn_time_left, duration)
	burn_tick_damage = max(burn_tick_damage, tick_damage)
	burn_tick_interval = max(0.1, tick_interval)
	burn_tick_timer = min(burn_tick_timer, 0.05)
	queue_redraw()

func apply_shock(duration: float, tick_damage: int, tick_interval: float = 0.45, chain_radius: float = 90.0, chain_damage: int = 1, can_chain: bool = true) -> void:
	if is_dead:
		return

	shock_time_left = max(shock_time_left, duration)
	shock_tick_damage = max(shock_tick_damage, tick_damage)
	shock_tick_interval = max(0.1, tick_interval)
	shock_chain_radius = chain_radius
	shock_chain_damage = chain_damage
	shock_tick_timer = min(shock_tick_timer, 0.05)

	if can_chain:
		shock_has_chained = false

	queue_redraw()

func _chain_shock_to_nearby_enemy() -> void:
	var parent_node := get_parent()
	if parent_node == null:
		return

	var best_enemy: Area2D = null
	var best_distance: float = shock_chain_radius

	for child in parent_node.get_children():
		if child == self:
			continue

		if child is Area2D and child.has_method("apply_shock"):
			if not is_instance_valid(child):
				continue

			var distance: float = global_position.distance_to(child.global_position)
			if distance <= best_distance:
				best_distance = distance
				best_enemy = child

	if best_enemy != null:
		best_enemy.apply_shock(
			shock_time_left * 0.65,
			shock_chain_damage,
			shock_tick_interval,
			shock_chain_radius,
			shock_chain_damage,
			false
		)

func _apply_type_stats() -> void:
	match enemy_type:
		EnemyType.BASIC:
			speed = 120.0
			max_health = 3
			exp_drop_amount = 1
			touch_damage = 1
		EnemyType.FAST:
			speed = 190.0
			max_health = 2
			exp_drop_amount = 1
			touch_damage = 1
		EnemyType.TANK:
			speed = 75.0
			max_health = 8
			exp_drop_amount = 3
			touch_damage = 2
		EnemyType.RANGED:
			speed = 105.0
			max_health = 3
			exp_drop_amount = 2
			touch_damage = 1
			shoot_cooldown = 1.8
			desired_range = 260.0
			stop_range = 220.0
			retreat_range = 170.0
		EnemyType.ELITE:
			speed = 92.0 + float(elite_level - 1) * 4.0
			max_health = 18 + (elite_level - 1) * 8
			exp_drop_amount = 9 + (elite_level - 1) * 3
			touch_damage = 2 + int(floor(float(elite_level - 1) / 2.0))

func _apply_modifier_stats() -> void:
	match enemy_modifier:
		EnemyModifier.ARMORED:
			max_health += 2
			exp_drop_amount += 1
		EnemyModifier.SWIFT:
			speed *= 1.45
			max_health = max(1, max_health - 1)
		EnemyModifier.SPLITTING:
			max_health += 1
			exp_drop_amount += 1
		EnemyModifier.EXPLOSIVE:
			speed *= 0.95
			exp_drop_amount += 1
		EnemyModifier.BURNING:
			touch_damage += 1
			exp_drop_amount += 1

func _apply_collision_size() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return

	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape == null:
		return

	match enemy_type:
		EnemyType.FAST:
			circle_shape.radius = 13.0
		EnemyType.TANK:
			circle_shape.radius = 26.0
		EnemyType.RANGED:
			circle_shape.radius = 18.0
		EnemyType.ELITE:
			circle_shape.radius = 36.0
		_:
			circle_shape.radius = 17.0

	if enemy_modifier == EnemyModifier.SWIFT:
		circle_shape.radius *= 0.85
	elif enemy_modifier == EnemyModifier.ARMORED:
		circle_shape.radius *= 1.08

func _process_chase(delta: float) -> void:
	var direction := (player.global_position - global_position).normalized()
	global_position += direction * speed * delta

func _process_ranged(delta: float) -> void:
	var to_player: Vector2 = player.global_position - global_position
	var distance: float = to_player.length()
	var direction: Vector2 = Vector2.ZERO

	if distance > stop_range:
		direction = to_player.normalized()
	elif distance < retreat_range:
		direction = (-to_player).normalized()

	global_position += direction * speed * delta

	shoot_timer -= delta
	if shoot_timer <= 0.0 and distance <= desired_range:
		_fire_projectile()
		shoot_timer = shoot_cooldown

func _fire_projectile() -> void:
	if projectile_scene == null:
		return

	if player == null or not is_instance_valid(player):
		return

	var projectile: Area2D = projectile_scene.instantiate()
	projectile.process_mode = Node.PROCESS_MODE_PAUSABLE
	get_parent().add_child(projectile)
	projectile.global_position = global_position

	var direction := (player.global_position - global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	projectile.direction = direction
	projectile.damage = 1

func stop() -> void:
	is_active = false

func take_damage(amount: int = 1, knockback_direction: Vector2 = Vector2.ZERO, knockback_force: float = 0.0) -> void:
	if is_dead:
		return

	if knockback_direction != Vector2.ZERO and knockback_force > 0.0:
		apply_knockback(knockback_direction, knockback_force)

	var final_damage: int = amount

	if enemy_modifier == EnemyModifier.ARMORED:
		final_damage = max(1, amount - 1)

	current_health -= final_damage
	damaged.emit(global_position + Vector2(0, -18), final_damage)

	if current_health <= 0:
		die()
	else:
		queue_redraw()

func apply_knockback(direction: Vector2, force: float) -> void:
	if is_dead:
		return

	if direction == Vector2.ZERO:
		return

	knockback_velocity += direction.normalized() * force
	knockback_velocity = knockback_velocity.limit_length(520.0)

func _process_knockback(delta: float) -> void:
	if knockback_velocity.length() <= knockback_stop_speed:
		knockback_velocity = Vector2.ZERO
		return

	global_position += knockback_velocity * delta
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		knockback_friction * knockback_velocity.length() * delta
	)

func get_touch_damage() -> int:
	return touch_damage

func die() -> void:
	if is_dead:
		return

	is_dead = true
	died.emit(global_position, exp_drop_amount, enemy_type, enemy_modifier)
	queue_free()

func _draw() -> void:
	match enemy_type:
		EnemyType.BASIC:
			_draw_basic()
		EnemyType.FAST:
			_draw_fast()
		EnemyType.TANK:
			_draw_tank()
		EnemyType.RANGED:
			_draw_ranged()
		EnemyType.ELITE:
			_draw_elite()

	_draw_modifier_visual()
	_draw_status_effects()

func _draw_modifier_visual() -> void:
	match enemy_modifier:
		EnemyModifier.BURNING:
			var pulse: float = 0.35 + sin(Time.get_ticks_msec() / 90.0) * 0.12
			draw_circle(Vector2.ZERO, 25.0, Color(1.0, 0.28, 0.0, pulse))
			draw_arc(Vector2.ZERO, 29.0, 0.0, TAU, 32, Color(1.0, 0.55, 0.0, 0.9), 2.0)

		EnemyModifier.ARMORED:
			draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 40, Color(0.75, 0.85, 1.0, 0.95), 3.0)
			draw_arc(Vector2.ZERO, 36.0, 0.0, TAU, 40, Color(0.35, 0.45, 0.8, 0.6), 2.0)

		EnemyModifier.SWIFT:
			draw_line(Vector2(-24, -10), Vector2(-38, -10), Color(1.0, 1.0, 1.0, 0.75), 2.0)
			draw_line(Vector2(-22, 0), Vector2(-42, 0), Color(1.0, 1.0, 1.0, 0.55), 2.0)
			draw_line(Vector2(-24, 10), Vector2(-36, 10), Color(1.0, 1.0, 1.0, 0.75), 2.0)

		EnemyModifier.SPLITTING:
			draw_circle(Vector2(-9, -24), 5.0, Color(0.8, 1.0, 0.35, 0.9))
			draw_circle(Vector2(9, -24), 5.0, Color(0.8, 1.0, 0.35, 0.9))

		EnemyModifier.EXPLOSIVE:
			var warning_alpha: float = 0.5 + sin(Time.get_ticks_msec() / 70.0) * 0.25
			draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 36, Color(1.0, 0.1, 0.05, warning_alpha), 4.0)
			draw_circle(Vector2.ZERO, 6.0, Color(1.0, 0.1, 0.0, 0.85))

func _draw_status_effects() -> void:
	if burn_time_left > 0.0:
		var burn_alpha: float = 0.35 + sin(Time.get_ticks_msec() / 85.0) * 0.12
		draw_circle(Vector2.ZERO, 24.0, Color(1.0, 0.25, 0.0, burn_alpha))
		draw_arc(Vector2.ZERO, 28.0, 0.0, TAU, 32, Color(1.0, 0.55, 0.0, 0.95), 2.0)

	if shock_time_left > 0.0:
		var shock_alpha: float = 0.35 + sin(Time.get_ticks_msec() / 55.0) * 0.18
		draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 32, Color(0.45, 0.9, 1.0, shock_alpha), 3.0)
		draw_line(Vector2(-20, -20), Vector2(18, 18), Color(0.65, 0.95, 1.0, 0.9), 2.0)
		draw_line(Vector2(20, -18), Vector2(-18, 18), Color(0.65, 0.95, 1.0, 0.9), 2.0)

func _draw_basic() -> void:
	var color := Color(1.0, 0.2, 0.2)

	if current_health == 2:
		color = Color(1.0, 0.45, 0.2)
	elif current_health == 1:
		color = Color(1.0, 0.8, 0.2)

	draw_rect(Rect2(Vector2(-15, -15), Vector2(30, 30)), color)

func _draw_fast() -> void:
	var color := Color(1.0, 0.35, 0.75)
	if current_health == 1:
		color = Color(1.0, 0.7, 0.9)

	draw_circle(Vector2.ZERO, 12.0, color)
	draw_circle(Vector2(0, -18), 4.0, Color(1.0, 1.0, 1.0, 0.9))

func _draw_tank() -> void:
	var color := Color(0.55, 0.25, 1.0)

	if current_health <= 5:
		color = Color(0.7, 0.45, 1.0)
	if current_health <= 2:
		color = Color(0.9, 0.75, 1.0)

	draw_rect(Rect2(Vector2(-22, -22), Vector2(44, 44)), color)
	draw_rect(Rect2(Vector2(-26, -26), Vector2(52, 52)), Color(0.15, 0.0, 0.25, 1.0), false, 3.0)

func _draw_ranged() -> void:
	var points := PackedVector2Array([
		Vector2(0, -18),
		Vector2(16, 10),
		Vector2(-16, 10)
	])

	var color := Color(0.2, 1.0, 0.6)
	if current_health == 2:
		color = Color(0.5, 1.0, 0.7)
	elif current_health == 1:
		color = Color(0.8, 1.0, 0.85)

	draw_colored_polygon(points, color)
	draw_circle(Vector2.ZERO, 4.0, Color(0.0, 0.35, 0.15))

func _draw_elite() -> void:
	var health_percent: float = 1.0
	if max_health > 0:
		health_percent = float(current_health) / float(max_health)

	var color := Color(1.0, 0.78, 0.15)
	if health_percent <= 0.66:
		color = Color(1.0, 0.48, 0.12)
	if health_percent <= 0.33:
		color = Color(1.0, 0.18, 0.08)

	var pulse: float = 1.0 + sin(Time.get_ticks_msec() / 120.0) * 0.06
	var body_radius: float = 30.0 * pulse

	draw_circle(Vector2.ZERO, body_radius + 7.0, Color(1.0, 0.95, 0.25, 0.22))
	draw_circle(Vector2.ZERO, body_radius, color)
	draw_circle(Vector2.ZERO, body_radius, Color(0.35, 0.12, 0.0, 1.0), false, 4.0)
	draw_circle(Vector2(0, -8), 7.0, Color(1.0, 1.0, 1.0, 0.28))

	var bar_width: float = 54.0
	var bar_height: float = 6.0
	var bar_pos := Vector2(-bar_width / 2.0, -44.0)

	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(0.08, 0.02, 0.02, 0.9), true)
	draw_rect(Rect2(bar_pos, Vector2(bar_width * health_percent, bar_height)), Color(1.0, 0.15, 0.08), true)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(1.0, 0.9, 0.35), false, 1.5)
