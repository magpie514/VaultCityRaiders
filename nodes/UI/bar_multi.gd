tool
extends Control

export(Color) var bgcolor = "55000000"
var colors = ["FF0000", "00FF00", "0000FF"]
var values = [0.1, 0.1, 0.1]

func init(vals, cols):
	values = vals
	colors = cols
	update()

func _draw():
	var v1 = null
	var v2 = null
	var current = 0
	var sum = 0.0
	var size = values.size()
	for i in range(size):
		draw_rect(Rect2(Vector2(sum, 0), rect_size * Vector2(values[i], 1.0)), colors[i % colors.size()])
		sum += values[i] * rect_size.x
	if sum < rect_size.x:
		draw_rect(Rect2(Vector2(sum, 0), Vector2(rect_size.x - sum, rect_size.y)), bgcolor)
