# res://scripts/camera_shake.gd
extends Camera2D

var shake_strength: float = 0.0
var shake_fade: float = 18.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	enabled = true
	make_current()

	position = Vector2.ZERO
	offset = Vector2.ZERO
	zoom = Vector2.ONE
	rotation = 0.0

	limit_enabled = false
	limit_left = -10000000
	limit_top = -10000000
	limit_right = 10000000
	limit_bottom = 10000000

	drag_horizontal_enabled = false
	drag_vertical_enabled = false
	drag_horizontal_offset = 0.0
	drag_vertical_offset = 0.0
	drag_left_margin = 0.0
	drag_top_margin = 0.0
	drag_right_margin = 0.0
	drag_bottom_margin = 0.0

	position_smoothing_enabled = false
	rotation_smoothing_enabled = false

func _process(delta: float) -> void:
	position = Vector2.ZERO

	if shake_strength > 0.05:
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		shake_strength = move_toward(
			shake_strength,
			0.0,
			shake_fade * delta
		)
	else:
		shake_strength = 0.0
		offset = Vector2.ZERO

func shake(amount: float) -> void:
	shake_strength = max(shake_strength, amount)
