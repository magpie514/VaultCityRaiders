extends Control

var color:Color = "FFFFFF"
var Max:int     = 14
var value:int   = 5

func init(_value, _max):
	Max = _max
	value = _value
	update()

func _draw() -> void:
	var size:float = round(rect_size.x / 20.0)
	var C:Color  = "#DDDDDD"
	if Max > 20:
		draw_bar(Rect2(Vector2(0,0), rect_size), "#77888888")
		return
	for i in range(20):
		if i <= value: C = "#AAFFFFFF"
		elif i <= Max: C = "#AA888888"
		else         : C = "#22888888"
		draw_bar(Rect2(size * i, 0, size, rect_size.y), C)

func draw_bar(rect:Rect2, col:Color) -> void:
	rect = rect.grow_individual(0, 0, -1.0, 0)
	draw_rect(rect, col)
	draw_rect(rect, col.darkened(0.5), false)
