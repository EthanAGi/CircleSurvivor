extends Area2D

@export var orbit_radius: float = 80.0
@export var orbit_speed: float = 4.0
@export var damage: int = 1
@export var lifetime: float = 2.0
@export var hit_cooldown: float = 0.35

var player: Node2D = null
var angle: float = 0.0
var angle_offset: float = 0.0

var hit_timers := {}

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	queue_redraw()

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		queue_free()
		return

	angle += orbit_speed * delta
	global_position = player.global_position + Vector2.RIGHT.rotated(angle + angle_offset) * orbit_radius

	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return

	var expired_keys: Array = []
	for key in hit_timers.keys():
		hit_timers[key] -= delta
		if hit_timers[key] <= 0.0:
			expired_keys.append(key)

	for key in expired_keys:
		hit_timers.erase(key)

	queue_redraw()

func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("take_damage"):
		return

	var id = area.get_instance_id()
	if hit_timers.has(id):
		return

	area.take_damage(damage)
	hit_timers[id] = hit_cooldown

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color(0.9, 0.95, 1.0))
