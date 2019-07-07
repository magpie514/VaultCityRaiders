tool
extends Control

export var color = Color(1.0, 1.0, 1.0, 1.0)
export var value = float(1.0) setget set_value

func set_value(v):
	value = clamp(v, 0.0, 1.0)
	update()

func _draw():
	var f
	if value > 0.01: f = value
	elif value > 0.00001: f = 0.01
	else: f = 0
	draw_rect(Rect2(Vector2(), rect_size * Vector2(f, 1.0)), color)
