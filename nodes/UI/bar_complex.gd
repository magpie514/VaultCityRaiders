extends Control
const BLACK = Color(0,0,0)

export(Gradient) var gradient:Gradient
export(Color) var bgcolor:Color  = Color("77101022")
export(Color) var color2:Color   = Color("AE00FF")
export(Color) var color3:Color   = Color("AA4BB3F5")
export(float) var value:float    = 1.0 setget set_value
export(bool)  var secondary:bool = false
export(float) var value2:float   = 0.0 setget set_value2
export(bool)  var guard:bool     = false
onready var tween:Tween = $Tween
var animValue:float = 1.0

func set_value(v:float) -> void:
	if tween == null: return
	if tween.is_active():
		if not tween.stop(self): print("[ComplexBar][set_value] ???? trying to stop.")
	v = clamp(v, 0.0, 1.0)
	if not tween.interpolate_property(self, "animValue", animValue, v, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN):
		print("[ComplexBar][set_value] ???? trying to interpolate.")
	animValue = value
	value = v
	if not tween.start(): print("[ComplexBar][set_value] ???? trying to start.")
	update()

func set_value2(v:float) -> void:
	value2 = v
	update()

func _process(delta:float) -> void:
	update()

func _ready() -> void:
	set_process(true)
	if not tween.stop_all(): print("[ComplexBar][_ready] ???? trying to stop all.")
	#set_value(0.24)

func _draw() -> void:
	var f:float
	var T:int = OS.get_ticks_msec()
	if   animValue > 0.01   : f = animValue
	elif animValue > 0.00001: f = 0.01 #Try to show a single pixel.
	else                    : f = 0.0
	var F:float = rect_size.x * f
	var c:Color = gradient.interpolate(f)
	if f < 0.25:
		c = c.linear_interpolate(BLACK, clamp(cos(T * 0.1), 0, 1))
	draw_rect(Rect2(0,0, F, rect_size.y), c)
	if secondary:
		var col:Color = color2.linear_interpolate(color2.darkened(0.5), clamp(cos(T * 0.003), 0, 1))
		var D:float = clamp(value2 * rect_size.x, 0, F)
		draw_rect(Rect2(F-D, 0, D, rect_size.y), col)
	draw_rect(Rect2(rect_size * Vector2(f, 0.0), rect_size * Vector2(1.0-f, 1.0)), bgcolor)
	if guard:
		draw_rect(Rect2(Vector2(), rect_size), color3.linear_interpolate(color3.lightened(0.5), clamp(cos((T+60) * 0.003), 0, 1)))
	draw_rect(Rect2(Vector2(), rect_size), bgcolor, false)
