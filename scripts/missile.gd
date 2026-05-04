extends Area2D

@export var speed: float = 340.0
@export var turn_speed: float = 6.0
@export var damage: int = 3
@export var lifetime: float = 4.0
@export var explosion_radius: float = 70.0
@export var explosion_visual_duration: float = 0.30
@export var direct_hit_knockback_force: float = 230.0
@export var explosion_knockback_force: float = 260.0
@export var is_napalm_launcher: bool = false

@export var burn_duration: float = 2.5
@export var burn_tick_damage: int = 1
@export var burn_tick_interval: float = 0.5

var direction: Vector2 = Vector2.RIGHT
var target: Area2D = null
var exploded: bool = false
var crit_chance: float = 0.0
var crit_effects_owner: Node = null

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

	if is_napalm_launcher:
		explosion_radius *= 1.35
		explosion_visual_duration = 0.42
		direct_hit_knockback_force *= 1.15
		explosion_knockback_force *= 1.20

	exploded = true
	explosion_timer = 0.0

	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	var collision_shape: CollisionShape2D = $CollisionShape2D
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

	var damaged_targets: Array[Node] = []

	var areas: Array[Area2D] = get_overlapping_areas()
	for area in areas:
		if area == self:
			continue

		if area.has_method("take_damage"):
			var direct_direction: Vector2 = (area.global_position - global_position).normalized()
			if direct_direction == Vector2.ZERO:
				direct_direction = direction.normalized()

			var direct_damage_result: Dictionary = _roll_damage_result(damage)
			var direct_damage: int = int(direct_damage_result["damage"])
			var direct_is_crit: bool = bool(direct_damage_result["is_crit"])

			area.take_damage(direct_damage, direct_direction, direct_hit_knockback_force)
			_apply_burn_to_target(area)

			if direct_is_crit and crit_effects_owner != null and crit_effects_owner.has_method("trigger_player_crit_effects"):
				crit_effects_owner.trigger_player_crit_effects(area, global_position, direct_damage, direct_direction)

			damaged_targets.append(area)

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

		if collider in damaged_targets:
			continue

		if collider != null and collider.has_method("take_damage"):
			var explosion_direction: Vector2 = (collider.global_position - global_position).normalized()
			if explosion_direction == Vector2.ZERO:
				explosion_direction = direction.normalized()

			var explosion_damage_result: Dictionary = _roll_damage_result(damage)
			var final_explosion_damage: int = int(explosion_damage_result["damage"])
			var explosion_is_crit: bool = bool(explosion_damage_result["is_crit"])

			collider.take_damage(final_explosion_damage, explosion_direction, explosion_knockback_force)
			_apply_burn_to_target(collider)

			if explosion_is_crit and crit_effects_owner != null and crit_effects_owner.has_method("trigger_player_crit_effects"):
				crit_effects_owner.trigger_player_crit_effects(collider, collider.global_position, final_explosion_damage, explosion_direction)

	if is_napalm_launcher:
		_apply_napalm_burn_wave()

	current_explosion_draw_radius = explosion_radius
	queue_redraw()

func _apply_burn_to_target(target_node: Node) -> void:
	if target_node == null:
		return

	if target_node.has_method("apply_burn"):
		target_node.apply_burn(burn_duration, burn_tick_damage, burn_tick_interval)

func _apply_napalm_burn_wave() -> void:
	var state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = explosion_radius * 1.25

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

		if collider != null and collider.has_method("apply_burn"):
			collider.apply_burn(burn_duration * 1.25, burn_tick_damage, burn_tick_interval)

func _roll_damage_result(base_damage: int) -> Dictionary:
	var is_crit: bool = randf() < crit_chance
	var final_damage: int = base_damage

	if is_crit:
		final_damage = base_damage * 2

	return {
		"damage": final_damage,
		"is_crit": is_crit
	}

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

		if is_napalm_launcher:
			draw_circle(Vector2.ZERO, current_explosion_draw_radius * 1.12, Color(1.0, 0.10, 0.0, 0.22 * alpha_progress))
			draw_circle(Vector2.ZERO, current_explosion_draw_radius * 0.70, Color(1.0, 0.48, 0.0, 0.24 * alpha_progress))
			draw_arc(Vector2.ZERO, current_explosion_draw_radius, 0.0, TAU, 64, Color(1.0, 0.82, 0.18, 0.95 * alpha_progress), 5.0)
			draw_arc(Vector2.ZERO, current_explosion_draw_radius * 1.25, 0.0, TAU, 64, Color(1.0, 0.25, 0.0, 0.70 * alpha_progress), 3.0)
			draw_circle(Vector2.ZERO, 7.0, Color(1.0, 0.85, 0.20, 1.0 * alpha_progress))
		else:
			draw_circle(Vector2.ZERO, current_explosion_draw_radius, Color(1.0, 0.22, 0.0, 0.24 * alpha_progress))
			draw_arc(Vector2.ZERO, current_explosion_draw_radius, 0.0, TAU, 64, Color(1.0, 0.35, 0.0, 0.95 * alpha_progress), 3.0)
			draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.55, 0.0, 1.0 * alpha_progress))
		return

	var points: PackedVector2Array = PackedVector2Array([
		Vector2(14, 0),
		Vector2(-10, 8),
		Vector2(-4, 0),
		Vector2(-10, -8)
	])

	draw_colored_polygon(points, Color(1.0, 0.55, 0.2))
