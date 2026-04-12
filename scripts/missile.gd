extends Area2D

@export var speed: float = 340.0
@export var turn_speed: float = 6.0
@export var damage: int = 3
@export var lifetime: float = 4.0
@export var explosion_radius: float = 70.0

var direction: Vector2 = Vector2.RIGHT
var target: Area2D = null
var exploded: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

	var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_explode)

	queue_redraw()

func _process(delta: float) -> void:
	if exploded:
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

	var areas: Array[Area2D] = get_overlapping_areas()
	for area in areas:
		if area == self:
			continue
		if area.has_method("take_damage"):
			area.take_damage(damage)

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
			collider.take_damage(damage)

	queue_free()

func _draw() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(14, 0),
		Vector2(-10, 8),
		Vector2(-4, 0),
		Vector2(-10, -8)
	])

	draw_colored_polygon(points, Color(1.0, 0.55, 0.2))
