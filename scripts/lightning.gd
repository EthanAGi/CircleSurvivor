extends Node2D

@export var lifetime: float = 0.28
@export var strike_radius: float = 70.0

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

	var top := Vector2(0, -100)
	var p1 := Vector2(-10, -60)
	var p2 := Vector2(12, -25)
	var p3 := Vector2(-8, 8)
	var p4 := Vector2(9, 42)
	var bottom := Vector2.ZERO

	var bolt_color := Color(1.0, 1.0, 0.6, alpha)
	var glow_color := Color(0.35, 0.85, 1.0, alpha * 0.55)
	var aoe_fill_color := Color(0.35, 0.8, 1.0, alpha * 0.18)
	var aoe_ring_color := Color(0.75, 0.95, 1.0, alpha * 0.95)
	var ground_color := Color(1.0, 0.95, 0.6, alpha * 0.75)

	var pulse: float = sin(t * PI)
	var visual_radius: float = strike_radius * (0.75 + pulse * 0.35)

	draw_circle(Vector2.ZERO, visual_radius, aoe_fill_color)
	draw_arc(Vector2.ZERO, visual_radius, 0.0, TAU, 64, aoe_ring_color, 3.0)

	draw_line(top, p1, glow_color, 12.0)
	draw_line(p1, p2, glow_color, 12.0)
	draw_line(p2, p3, glow_color, 12.0)
	draw_line(p3, p4, glow_color, 12.0)
	draw_line(p4, bottom, glow_color, 12.0)

	draw_line(top, p1, bolt_color, 4.0)
	draw_line(p1, p2, bolt_color, 4.0)
	draw_line(p2, p3, bolt_color, 4.0)
	draw_line(p3, p4, bolt_color, 4.0)
	draw_line(p4, bottom, bolt_color, 4.0)

	draw_circle(Vector2.ZERO, 8.0, ground_color)
