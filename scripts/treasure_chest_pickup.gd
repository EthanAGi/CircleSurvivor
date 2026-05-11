extends Area2D

signal collected(chest_position: Vector2)

@export var attract_radius: float = 110.0
@export var collect_radius: float = 24.0
@export var move_speed: float = 180.0
@export var acceleration: float = 420.0

var player: Node2D = null
var velocity: Vector2 = Vector2.ZERO
var is_collecting: bool = false
var pulse_time: float = 0.0
var has_been_collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	queue_redraw()

func setup(target_player: Node2D) -> void:
	player = target_player

func _process(delta: float) -> void:
	pulse_time += delta

	if has_been_collected:
		return

	if player == null or not is_instance_valid(player):
		queue_redraw()
		return

	var to_player: Vector2 = player.global_position - global_position
	var distance: float = to_player.length()

	var effective_attract_radius: float = attract_radius
	if player.get("pickup_radius_multiplier") != null:
		effective_attract_radius *= player.pickup_radius_multiplier

	if not is_collecting and distance <= effective_attract_radius:
		is_collecting = true

	if is_collecting:
		if distance <= collect_radius:
			_collect()
			return

		var direction: Vector2 = to_player.normalized()
		velocity = velocity.move_toward(direction * move_speed, acceleration * delta)
		global_position += velocity * delta

	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body == player:
		_collect()

func _on_area_entered(area: Area2D) -> void:
	if area == player:
		_collect()

func _collect() -> void:
	if has_been_collected:
		return

	has_been_collected = true
	collected.emit(global_position)
	queue_free()

func _draw() -> void:
	var pulse: float = 1.0 + sin(pulse_time * 5.0) * 0.06
	var base_scale := Vector2(pulse, pulse)

	# Glow
	draw_circle(Vector2(0, 2), 28.0 * pulse, Color(1.0, 0.78, 0.18, 0.18))

	# Chest body
	var body_rect := Rect2(Vector2(-20, -6) * base_scale, Vector2(40, 24) * base_scale)
	draw_rect(body_rect, Color(0.58, 0.28, 0.08), true)
	draw_rect(body_rect, Color(0.18, 0.08, 0.02), false, 2.0)

	# Chest lid
	var lid_points := PackedVector2Array([
		Vector2(-22, -6) * base_scale,
		Vector2(-15, -20) * base_scale,
		Vector2(15, -20) * base_scale,
		Vector2(22, -6) * base_scale
	])
	draw_colored_polygon(lid_points, Color(0.72, 0.36, 0.10))
	var lid_outline := PackedVector2Array(lid_points)
	lid_outline.append(lid_points[0])
	draw_polyline(lid_outline, Color(0.18, 0.08, 0.02), 2.0)

	# Gold bands
	draw_rect(Rect2(Vector2(-23, -2) * base_scale, Vector2(46, 5) * base_scale), Color(1.0, 0.75, 0.18), true)
	draw_rect(Rect2(Vector2(-4, -20) * base_scale, Vector2(8, 38) * base_scale), Color(1.0, 0.75, 0.18), true)

	# Lock
	draw_rect(Rect2(Vector2(-5, 0) * base_scale, Vector2(10, 10) * base_scale), Color(1.0, 0.88, 0.32), true)
	draw_rect(Rect2(Vector2(-5, 0) * base_scale, Vector2(10, 10) * base_scale), Color(0.28, 0.16, 0.02), false, 1.5)

	# Sparkle
	var sparkle_offset := Vector2(18, -24) * base_scale
	draw_line(sparkle_offset + Vector2(-5, 0), sparkle_offset + Vector2(5, 0), Color(1.0, 0.95, 0.55), 2.0)
	draw_line(sparkle_offset + Vector2(0, -5), sparkle_offset + Vector2(0, 5), Color(1.0, 0.95, 0.55), 2.0)
