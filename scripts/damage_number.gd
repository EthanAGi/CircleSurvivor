extends Node2D

@export var lifetime: float = 0.55
@export var float_speed: float = 42.0
@export var spread_x: float = 18.0
@export var start_scale: float = 1.0
@export var end_scale: float = 1.35

var damage_amount: int = 0
var elapsed: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var label: Label = null

func _ready() -> void:
	z_index = 100

	label = Label.new()
	add_child(label)

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(-20, -20)
	label.size = Vector2(40, 24)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.35))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)

	label.text = str(damage_amount)

	scale = Vector2.ONE * start_scale

	var random_x: float = randf_range(-spread_x, spread_x)
	velocity = Vector2(random_x, -float_speed)

func setup(amount: int) -> void:
	damage_amount = amount

	if label != null:
		label.text = str(damage_amount)

func _process(delta: float) -> void:
	elapsed += delta
	global_position += velocity * delta

	var progress: float = clamp(elapsed / lifetime, 0.0, 1.0)

	velocity.y = lerp(-float_speed, -float_speed * 0.45, progress)

	var current_scale: float = lerp(start_scale, end_scale, progress)
	scale = Vector2.ONE * current_scale

	modulate.a = 1.0 - progress

	if elapsed >= lifetime:
		queue_free()
