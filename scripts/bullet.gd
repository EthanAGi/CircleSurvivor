extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	queue_redraw()

func _on_body_entered(_body: Node) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(1)
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 8.0, Color(1.0, 0.9, 0.2))
