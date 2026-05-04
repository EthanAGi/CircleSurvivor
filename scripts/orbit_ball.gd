extends Area2D

var player: Node2D
var angle: float = 0.0
var angle_offset: float = 0.0
var radius: float = 60.0

var rotation_speed: float = 3.5
var lifetime: float = 2.0
var timer: float = 0.0

var damage: int = 1
var crit_chance: float = 0.0
var knockback_force: float = 120.0

var ball_radius: float = 10.0
var is_blade_ring: bool = false

# 🔥 NEW: Reference to main for crit effects
var main: Node = null

func _ready() -> void:
	timer = lifetime

	# Try to find main automatically if not set
	if main == null:
		main = get_tree().get_root().get_node_or_null("Main")

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		queue_free()
		return

	timer -= delta
	if timer <= 0.0:
		queue_free()
		return

	angle += rotation_speed * delta
	var final_angle: float = angle + angle_offset

	var offset: Vector2 = Vector2.RIGHT.rotated(final_angle) * radius
	global_position = player.global_position + offset

func _on_body_entered(body: Node) -> void:
	if body == player:
		return

	if not body.has_method("take_damage"):
		return

	# Roll damage + crit
	var is_crit: bool = randf() < crit_chance
	var final_damage: int = damage

	if is_crit:
		final_damage *= 2

	body.take_damage(final_damage)

	# Apply knockback if available
	if body.has_method("apply_knockback"):
		var direction: Vector2 = (body.global_position - global_position).normalized()
		body.apply_knockback(direction * knockback_force)

	# 🔥 NEW: Trigger global crit effects
	if is_crit and main != null and main.has_method("trigger_crit_effect"):
		main.trigger_crit_effect(body)

func _on_area_entered(area: Area2D) -> void:
	_on_body_entered(area) 
	
	# Not sure why git not working
