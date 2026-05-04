extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 2.0
@export var damage: int = 1
@export var radius: float = 8.0
@export var knockback_force: float = 170.0

var direction: Vector2 = Vector2.RIGHT
var is_crit: bool = false
var crit_effects_owner: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	var collision_shape: CollisionShape2D = $CollisionShape2D
	if collision_shape != null and collision_shape.shape is CircleShape2D:
		var circle_shape: CircleShape2D = collision_shape.shape as CircleShape2D
		circle_shape.radius = radius

	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)

	queue_redraw()

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	queue_redraw()

func _on_body_entered(_body: Node) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		var knockback_direction: Vector2 = direction.normalized()
		if knockback_direction == Vector2.ZERO:
			knockback_direction = (area.global_position - global_position).normalized()

		area.take_damage(damage, knockback_direction, knockback_force)

		if is_crit and crit_effects_owner != null and crit_effects_owner.has_method("trigger_player_crit_effects"):
			crit_effects_owner.trigger_player_crit_effects(area, global_position, damage, knockback_direction)

	queue_free()

func _draw() -> void:
	if is_crit:
		draw_circle(Vector2.ZERO, radius * 1.35, Color(1.0, 0.72, 0.15, 0.35))
		draw_arc(Vector2.ZERO, radius * 1.55, 0.0, TAU, 24, Color(1.0, 0.95, 0.25, 0.9), 2.0)

	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.9, 0.2))
