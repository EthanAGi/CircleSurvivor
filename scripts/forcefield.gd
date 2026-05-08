extends Node2D

var player: Node2D = null
var main: Node = null

var radius: float = 95.0
var duration: float = 2.0
var tick_interval: float = 0.35
var damage: int = 1
var knockback_force: float = 100.0
var is_permanent: bool = false

var life_timer: float = 0.0
var damage_tick_timer: float = 0.0
var pulse_time: float = 0.0

func _ready() -> void:
	life_timer = duration
	damage_tick_timer = 0.05
	z_index = 8
	queue_redraw()

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		queue_free()
		return

	global_position = player.global_position
	pulse_time += delta

	if not is_permanent:
		life_timer -= delta
		if life_timer <= 0.0:
			queue_free()
			return

	damage_tick_timer -= delta
	if damage_tick_timer <= 0.0:
		damage_tick_timer = tick_interval
		_damage_nearby_enemies()

	queue_redraw()

func _damage_nearby_enemies() -> void:
	if main == null or not is_instance_valid(main):
		return

	if main.has_method("damage_forcefield_enemies"):
		main.damage_forcefield_enemies(global_position, radius, damage, knockback_force)

func _draw() -> void:
	var remaining_ratio: float = 1.0
	if not is_permanent and duration > 0.0:
		remaining_ratio = clamp(life_timer / duration, 0.0, 1.0)

	var pulse: float = 0.5 + 0.5 * sin(pulse_time * 9.0)
	var outer_alpha: float = 0.26 + pulse * 0.08
	var ring_alpha: float = 0.70 + pulse * 0.20

	if not is_permanent:
		outer_alpha *= remaining_ratio
		ring_alpha *= remaining_ratio

	draw_circle(Vector2.ZERO, radius, Color(0.25, 0.85, 1.0, outer_alpha))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 96, Color(0.60, 0.95, 1.0, ring_alpha), 4.0)
	draw_arc(Vector2.ZERO, radius * 0.72, 0.0, TAU, 96, Color(0.35, 0.75, 1.0, ring_alpha * 0.55), 2.0)

	if is_permanent:
		draw_arc(Vector2.ZERO, radius * 1.08, pulse_time * 1.8, pulse_time * 1.8 + PI * 1.25, 64, Color(0.80, 1.0, 1.0, 0.95), 3.0)
		draw_arc(Vector2.ZERO, radius * 1.08, pulse_time * 1.8 + PI, pulse_time * 1.8 + PI * 2.25, 64, Color(0.80, 1.0, 1.0, 0.95), 3.0)
