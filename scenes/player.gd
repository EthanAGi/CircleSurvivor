extends CharacterBody2D

signal died
signal shoot_requested(position: Vector2)

@export var speed: float = 250.0

@onready var fire_timer: Timer = $FireTimer

var is_dead: bool = false

func _ready() -> void:
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

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
	var color := Color(0.3, 0.7, 1.0) if not is_dead else Color(0.4, 0.4, 0.4)
	draw_circle(Vector2.ZERO, 20.0, color)
