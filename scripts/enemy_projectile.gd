extends Area2D

@export var speed: float = 260.0
@export var lifetime: float = 3.0
@export var damage: int = 1

var direction: Vector2 = Vector2.RIGHT
var has_hit: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_timeout)

	queue_redraw()

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	rotation = direction.angle()
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if has_hit:
		return

	has_hit = true

	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()

func stop() -> void:
	set_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 7.0, Color(1.0, 0.45, 0.1))
	draw_arc(
		Vector2.ZERO,
		9.0,
		0.0,
		TAU,
		24,
		Color(1.0, 0.9, 0.3),
		2.0
	)
