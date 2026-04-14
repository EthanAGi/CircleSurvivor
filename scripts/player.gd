extends CharacterBody2D

signal died
signal shoot_requested(position: Vector2)
signal exp_changed(level: int, current_exp: int, exp_to_next: int)
signal leveled_up(level: int)
signal health_changed(current_health: int, max_health: int)

@export var speed: float = 250.0
@export var starting_level: int = 1
@export var starting_exp_to_next: int = 5
@export var exp_growth_per_level: int = 3

@export var max_health: int = 5
@export var contact_invulnerability_time: float = 0.75

@onready var fire_timer: Timer = $FireTimer

var is_dead: bool = false

var level: int = 1
var current_exp: int = 0
var exp_to_next: int = 5

var current_health: int = 0
var can_take_damage: bool = true
var damage_invulnerability_timer: float = 0.0

func _ready() -> void:
	level = starting_level
	current_exp = 0
	exp_to_next = starting_exp_to_next

	current_health = max_health
	can_take_damage = true
	damage_invulnerability_timer = 0.0

	fire_timer.timeout.connect(_on_fire_timer_timeout)

	exp_changed.emit(level, current_exp, exp_to_next)
	health_changed.emit(current_health, max_health)

	queue_redraw()

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not can_take_damage:
		damage_invulnerability_timer -= delta
		if damage_invulnerability_timer <= 0.0:
			can_take_damage = true
			damage_invulnerability_timer = 0.0

	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

	queue_redraw()

func gain_experience(amount: int) -> void:
	if is_dead:
		return

	current_exp += amount

	while current_exp >= exp_to_next:
		current_exp -= exp_to_next
		level += 1
		exp_to_next += exp_growth_per_level
		leveled_up.emit(level)

	exp_changed.emit(level, current_exp, exp_to_next)

func set_fire_rate(new_wait_time: float) -> void:
	fire_timer.wait_time = new_wait_time

	if not is_dead:
		fire_timer.start()

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return

	if not can_take_damage:
		return

	current_health -= amount
	current_health = max(current_health, 0)

	can_take_damage = false
	damage_invulnerability_timer = contact_invulnerability_time

	health_changed.emit(current_health, max_health)
	queue_redraw()

	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	if is_dead:
		return

	current_health += amount
	current_health = min(current_health, max_health)

	health_changed.emit(current_health, max_health)
	queue_redraw()

func increase_max_health(amount: int) -> void:
	max_health += amount
	current_health += amount
	health_changed.emit(current_health, max_health)
	queue_redraw()

func die() -> void:
	if is_dead:
		return

	is_dead = true
	fire_timer.stop()
	died.emit()
	queue_redraw()

func _on_fire_timer_timeout() -> void:
	if is_dead:
		return

	shoot_requested.emit(global_position)

func _draw() -> void:
	var body_color := Color(0.3, 0.7, 1.0)

	if is_dead:
		body_color = Color(0.4, 0.4, 0.4)
	elif not can_take_damage:
		body_color = Color(1.0, 0.75, 0.75)

	draw_circle(Vector2.ZERO, 20.0, body_color)

	_draw_health_bar()

func _draw_health_bar() -> void:
	if current_health >= max_health:
		return

	var bar_width: float = 44.0
	var bar_height: float = 6.0
	var bar_y: float = -34.0

	var health_ratio: float = float(current_health) / float(max_health)
	health_ratio = clamp(health_ratio, 0.0, 1.0)

	var bar_position := Vector2(-bar_width / 2.0, bar_y)

	# Background
	draw_rect(
		Rect2(bar_position, Vector2(bar_width, bar_height)),
		Color(0.18, 0.18, 0.18, 0.95),
		true
	)

	# Red health fill
	draw_rect(
		Rect2(bar_position, Vector2(bar_width * health_ratio, bar_height)),
		Color(0.9, 0.1, 0.1, 1.0),
		true
	)

	# Border
	draw_rect(
		Rect2(bar_position, Vector2(bar_width, bar_height)),
		Color(0.0, 0.0, 0.0, 1.0),
		false,
		1.0
	)
