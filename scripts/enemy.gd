extends Area2D

signal died(enemy_position: Vector2, exp_amount: int, enemy_type: int)
signal damaged(damage_position: Vector2, amount: int)

enum EnemyType {
	BASIC,
	FAST,
	TANK,
	RANGED
}

@export var enemy_type: int = EnemyType.BASIC
@export var projectile_scene: PackedScene

var speed: float = 120.0
var max_health: int = 3
var exp_drop_amount: int = 1
var touch_damage: int = 1

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

func _ready() -> void:
	_apply_type_stats()
	current_health = max_health
	shoot_timer = randf_range(0.4, shoot_cooldown)
	queue_redraw()

func _process(delta: float) -> void:
	if not is_active or is_dead:
		return

	if player == null or not is_instance_valid(player):
		return

	match enemy_type:
		EnemyType.BASIC:
			_process_basic(delta)
		EnemyType.FAST:
			_process_fast(delta)
		EnemyType.TANK:
			_process_tank(delta)
		EnemyType.RANGED:
			_process_ranged(delta)

	_process_knockback(delta)
	queue_redraw()

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

func _process_basic(delta: float) -> void:
	var direction := (player.global_position - global_position).normalized()
	global_position += direction * speed * delta

func _process_fast(delta: float) -> void:
	var direction := (player.global_position - global_position).normalized()
	global_position += direction * speed * delta

func _process_tank(delta: float) -> void:
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

	current_health -= amount
	damaged.emit(global_position + Vector2(0, -18), amount)

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
	died.emit(global_position, exp_drop_amount, enemy_type)
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
