extends Area2D

@export var speed: float = 120.0
@export var max_health: int = 3

var player: Node2D = null
var is_active: bool = true
var is_dead: bool = false
var current_health: int = 0

func _ready() -> void:
	current_health = max_health
	queue_redraw()

func _process(delta: float) -> void:
	if not is_active or is_dead:
		return

	if player == null or not is_instance_valid(player):
		return

	var direction := (player.global_position - global_position).normalized()
	global_position += direction * speed * delta
	queue_redraw()

func stop() -> void:
	is_active = false

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return

	current_health -= amount

	if current_health <= 0:
		die()
	else:
		queue_redraw()

func die() -> void:
	if is_dead:
		return

	is_dead = true
	queue_free()

func _draw() -> void:
	var color := Color(1.0, 0.2, 0.2)

	# Slightly change color as enemy gets damaged.
	if current_health == 2:
		color = Color(1.0, 0.45, 0.2)
	elif current_health == 1:
		color = Color(1.0, 0.8, 0.2)

	draw_rect(Rect2(Vector2(-15, -15), Vector2(30, 30)), color)
