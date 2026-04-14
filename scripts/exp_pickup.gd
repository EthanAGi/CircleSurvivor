extends Area2D

signal collected(amount: int)

enum ExpType {
	GREEN,
	BLUE,
	PURPLE
}

const EXP_DATA := {
	ExpType.GREEN: {
		"amount": 1,
		"color": Color(0.2, 1.0, 0.35),
		"outline": Color(0.05, 0.45, 0.12),
		"scale": 1.0
	},
	ExpType.BLUE: {
		"amount": 2,
		"color": Color(0.25, 0.7, 1.0),
		"outline": Color(0.08, 0.2, 0.5),
		"scale": 1.15
	},
	ExpType.PURPLE: {
		"amount": 3,
		"color": Color(0.75, 0.35, 1.0),
		"outline": Color(0.32, 0.08, 0.5),
		"scale": 1.3
	}
}

@export var exp_type: ExpType = ExpType.GREEN
@export var attract_radius: float = 120.0
@export var collect_radius: float = 18.0
@export var move_speed: float = 220.0
@export var acceleration: float = 500.0

var exp_amount: int = 1
var player: Node2D = null
var velocity: Vector2 = Vector2.ZERO
var is_collecting: bool = false

var gem_color: Color = Color(0.2, 1.0, 0.35)
var outline_color: Color = Color(0.05, 0.45, 0.12)
var gem_scale: float = 1.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_exp_type_data()
	queue_redraw()

func setup(target_player: Node2D, pickup_type: int) -> void:
	player = target_player
	exp_type = pickup_type
	_apply_exp_type_data()

func _apply_exp_type_data() -> void:
	var data: Dictionary = EXP_DATA.get(exp_type, EXP_DATA[ExpType.GREEN])

	exp_amount = int(data["amount"])
	gem_color = data["color"]
	outline_color = data["outline"]
	gem_scale = float(data["scale"])

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
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

	for i in range(points.size()):
		points[i] *= gem_scale

	draw_colored_polygon(points, gem_color)

	var outline_points := PackedVector2Array(points)
	outline_points.append(points[0])
	draw_polyline(outline_points, outline_color, 2.0)

	draw_circle(Vector2(0, -2) * gem_scale, 2.2 * gem_scale, Color(1, 1, 1, 0.25))
