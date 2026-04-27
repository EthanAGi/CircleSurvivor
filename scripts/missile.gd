extends Area2D

@export var speed: float = 340.0
@export var turn_speed: float = 6.0
@export var damage: int = 3
@export var lifetime: float = 4.0
@export var explosion_radius: float = 70.0
@export var explosion_visual_duration: float = 0.30
@export var direct_hit_knockback_force: float = 230.0
@export var explosion_knockback_force: float = 260.0

var direction: Vector2 = Vector2.RIGHT
var target: Area2D = null
var exploded: bool = false

var explosion_timer: float = 0.0
var current_explosion_draw_radius: float = 0.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

	var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_explode)

	queue_redraw()

func _process(delta: float) -> void:
	if exploded:
		_update_explosion_visual(delta)
		return

	if target != null and is_instance_valid(target):
		var desired_direction: Vector2 = (target.global_position - global_position).normalized()
		if desired_direction != Vector2.ZERO:
			direction = direction.slerp(desired_direction, min(1.0, turn_speed * delta)).normalized()

	global_position += direction * speed * delta
	rotation = direction.angle()
	queue_redraw()

func _on_area_entered(area: Area2D) -> void:
	if exploded:
		return

	if area.has_method("take_damage"):
		_explode()

func _explode() -> void:
	if exploded:
		return

	exploded = true
	explosion_timer = 0.0

	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	var collision_shape: CollisionShape2D = $CollisionShape2D
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

	var areas: Array[Area2D] = get_overlapping_areas()
	for area in areas:
		if area == self:
			continue

		if area.has_method("take_damage"):
			var direct_direction: Vector2 = (area.global_position - global_position).normalized()
			if direct_direction == Vector2.ZERO:
				direct_direction = direction.normalized()

			area.take_damage(damage, direct_direction, direct_hit_knockback_force)

	var state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = explosion_radius

	params.shape = shape
	params.transform = Transform2D(0.0, global_position)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	params.collision_mask = 2

	var results: Array[Dictionary] = state.intersect_shape(params)

	for result in results:
		var collider: Variant = result.get("collider")
		if collider == self:
			continue

		if collider != null and collider.has_method("take_damage"):
			var explosion_direction: Vector2 = (collider.global_position - global_position).normalized()
			if explosion_direction == Vector2.ZERO:
				explosion_direction = direction.normalized()

			collider.take_damage(damage, explosion_direction, explosion_knockback_force)

	current_explosion_draw_radius = explosion_radius
	queue_redraw()

func _update_explosion_visual(delta: float) -> void:
	explosion_timer += delta

	var progress: float = explosion_timer / explosion_visual_duration
	progress = clamp(progress, 0.0, 1.0)

	var pulse: float = sin(progress * PI * 2.0)
	var scale_amount: float = 1.0 + (pulse * 0.18)

	current_explosion_draw_radius = explosion_radius * scale_amount

	queue_redraw()

	if explosion_timer >= explosion_visual_duration:
		queue_free()

func _draw() -> void:
	if exploded:
		var alpha_progress: float = 1.0 - clamp(explosion_timer / explosion_visual_duration, 0.0, 1.0)

		draw_circle(Vector2.ZERO, current_explosion_draw_radius, Color(1.0, 0.1, 0.1, 0.22 * alpha_progress))
		draw_arc(Vector2.ZERO, current_explosion_draw_radius, 0.0, TAU, 64, Color(1.0, 0.0, 0.0, 0.95 * alpha_progress), 3.0)
		draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.0, 0.0, 1.0 * alpha_progress))
		return

	var points: PackedVector2Array = PackedVector2Array([
		Vector2(14, 0),
		Vector2(-10, 8),
		Vector2(-4, 0),
		Vector2(-10, -8)
	])

	draw_colored_polygon(points, Color(1.0, 0.55, 0.2))
