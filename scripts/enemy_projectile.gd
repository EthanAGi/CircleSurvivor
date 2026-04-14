extends Area2D

@export var speed: float = 260.0
@export var lifetime: float = 3.0
@export var damage: int = 1

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	area_entered.connect(_on_area_entered)

	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

	queue_redraw()

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	rotation = direction.angle()
	queue_redraw()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
	queue_free()

func stop() -> void:
	set_process(false)

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
