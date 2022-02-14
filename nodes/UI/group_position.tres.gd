tool
extends Control

export(Color) var bgcolor       = "55000000"
export(Color) var color:Color   = "00BBBB"
export(Color) var outline:Color = "008888"
export(Color) var hilight:Color = "f57715"
export(int)   var value:int     = 0 setget updateValue
export(bool)  var flip          = false

func init(x:int, side:int) -> void:
	flip = true if side == 1 else false
	#rect_rotation = 180 if side == 1 else 90
	value = x
	update()

func _draw():
	var col1:float = floor(rect_size.x * 0.45)
	var col2:float = floor(rect_size.x * 0.55)
	var rects = floor(rect_size.y * 0.3)
	var rects2 = [0.00, 0.35, 0.70]
	draw_rect(Rect2(Vector2(0.1   , 0.1), Vector2(col1, rect_size.y)), bgcolor, true)
	draw_rect(Rect2(Vector2(col2  , 0.1), Vector2(col1, rect_size.y)), bgcolor, true)
	for i in range(6):
		var px = (0.1 if i > 2 else col2) if flip else (col2 if i > 2 else 0.1)
		draw_rect(Rect2( px, rect_size.y * rects2[(i if i < 3 else i-3)], col1, rects), hilight if i == value else color, true)
	draw_rect(Rect2(Vector2(0.1   , 0.1), Vector2(col1, rect_size.y)), outline, false)
	draw_rect(Rect2(Vector2(col2  , 0.1), Vector2(col1, rect_size.y)), outline, false)

func updateValue(x:int) -> void:
	value = x
	update()

