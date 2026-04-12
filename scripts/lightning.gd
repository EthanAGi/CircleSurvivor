extends Node2D

@export var lifetime: float = 0.18
@export var strike_radius: float = 26.0

var elapsed: float = 0.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

	if elapsed >= lifetime:
		queue_free()

func _draw() -> void:
	var t: float = clamp(elapsed / lifetime, 0.0, 1.0)
	var alpha: float = 1.0 - t

	var top := Vector2(0, -90)
	var p1 := Vector2(-8, -55)
	var p2 := Vector2(10, -20)
	var p3 := Vector2(-6, 10)
	var p4 := Vector2(7, 40)
	var bottom := Vector2(0, 0)

	var bolt_color := Color(1.0, 1.0, 0.6, alpha)
	var glow_color := Color(0.6, 0.9, 1.0, alpha * 0.55)
	var ground_color := Color(1.0, 0.95, 0.6, alpha * 0.7)

	draw_line(top, p1, glow_color, 10.0)
	draw_line(p1, p2, glow_color, 10.0)
	draw_line(p2, p3, glow_color, 10.0)
	draw_line(p3, p4, glow_color, 10.0)
	draw_line(p4, bottom, glow_color, 10.0)

	draw_line(top, p1, bolt_color, 4.0)
	draw_line(p1, p2, bolt_color, 4.0)
	draw_line(p2, p3, bolt_color, 4.0)
	draw_line(p3, p4, bolt_color, 4.0)
	draw_line(p4, bottom, bolt_color, 4.0)

	draw_circle(Vector2.ZERO, strike_radius, ground_color)
