tool
extends Control

export(Color) var bgcolor = "55000000"
export(Color) var color : Color = "00BBBB"
export(Color) var outline : Color = "008888"
export(Color) var border : Color = "004444"
export(Color) var charge_color : Color = "f57715"
export(int) var segments : int = 10 setget set_segments
export(int) var value :int = 5 setget set_value
export var value2 : float = 0.5 setget set_value2

func init(val:int, val2:float, segs:int) -> void:
	value = val
	value2 = val2
	segments = segs
	update()

func _draw():
	var sum : float = 0.0
	draw_rect(Rect2(Vector2(sum, 0), Vector2(rect_size.x - sum, rect_size.y)), bgcolor)
	var t = rect_size.x / (segments+1)
	var poly1 : PoolVector2Array = PoolVector2Array( [Vector2(0, 0), Vector2((t)*0.9, 0), Vector2(0, rect_size.y*.9)] )
	var poly2 : PoolVector2Array = PoolVector2Array( [ Vector2(rect_size.x, rect_size.y*0.1),Vector2(rect_size.x, rect_size.y),Vector2(t*segments+(t*0.1), rect_size.y) ] )
	draw_colored_polygon(poly1, border)
	draw_colored_polygon(poly2, border)
	for i in range(segments):
		sum = (float(t) * float(i))
		var co = color if i < value else Color("66000000")
		var pv : PoolVector2Array = poly(sum, t)
		var pv2 : PoolVector2Array = poly(sum, t)
		pv2.push_back(pv2[0])
		draw_colored_polygon(pv, co, pv, null, null, true)
		draw_polyline(pv2, outline, 1.0, true)
	if value < segments and value2 > 0:
		sum = float(t) * float(value)
		var tmp : float = (1.0 - value2)
		var tmp2 : float= t * tmp
		var pv : PoolVector2Array = PoolVector2Array([	Vector2(int(sum), int(rect_size.y)), 	Vector2(int(sum + t) - 2, 									int(rect_size.y)),			Vector2(int(sum + t * 2 - tmp2) - 2,	int(rect_size.y * tmp)),			Vector2(int(sum + t  - tmp2),						int(rect_size.y * tmp)),		])
		var pv2 = poly(sum, t); pv2.push_back(pv2[0])
		var c : Color = charge_color
		c.v = value2 + 0.1; c.h = charge_color.h - ((1.0 - value2) * 0.12)
		draw_colored_polygon(pv, c, pv, null, null, true)
		draw_polyline(pv2, outline, 1.0, true)

func poly(sum:float, t:float) -> PoolVector2Array:
	var result = PoolVector2Array()
	var pointsx = [int(sum + t), int(sum+t*2)-2, int(sum+t)-2, int(sum)]
	var pointsy = [int(0), int(0), rect_size.y, rect_size.y]
	for i in range(pointsx.size()):
		result.push_back(Vector2(pointsx[i], pointsy[i]))
	return result

func set_value(x:int) -> void:
	value = x
	update()

func set_value2(x:float) -> void:
	value2 = x
	update()

func set_segments(x:int) -> void:
	segments = x
	update()
