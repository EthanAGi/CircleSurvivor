extends Area2D

signal collected(amount: int)

@export var exp_amount: int = 1
@export var attract_radius: float = 120.0
@export var collect_radius: float = 18.0
@export var move_speed: float = 220.0
@export var acceleration: float = 500.0

var player: Node2D = null
var velocity: Vector2 = Vector2.ZERO
var is_collecting: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func setup(target_player: Node2D, amount: int) -> void:
	player = target_player
	exp_amount = amount

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var to_player: Vector2 = player.global_position - global_position
	var distance: float = to_player.length()

	if not is_collecting and distance <= attract_radius:
		is_collecting = true

	if is_collecting:
		if distance <= collect_radius:
			_collect()
			return

		var direction := to_player.normalized()
		velocity = velocity.move_toward(direction * move_speed, acceleration * delta)
		global_position += velocity * delta

	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body == player:
		_collect()

func _collect() -> void:
	collected.emit(exp_amount)
	queue_free()

func _draw() -> void:
	var points := PackedVector2Array([
		Vector2(0, -10),
		Vector2(9, 7),
		Vector2(-9, 7)
	])

	draw_colored_polygon(points, Color(0.2, 1.0, 0.35))
