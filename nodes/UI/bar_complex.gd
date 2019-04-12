extends Control

export(Gradient) var gradient
export(Color) var bgcolor = Color("10101022")
export(float) var value = 1.0 setget set_value

onready var tween = $Tween

var animValue = 1.0

func set_value(v):
	if tween == null: return
	if tween.is_active():
		tween.stop(self)

	v = clamp(v, 0.0, 1.0)
	tween.interpolate_property(self, "animValue", animValue, v, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	animValue = value
	value = v

	tween.start()
	update()

func _process(delta):
	update()

func _ready():
	set_process(true)
	tween.stop_all()

func _draw():
	var f
	var c
	if animValue > 0.01: f = animValue
	elif animValue > 0.00001: f = 0.01
	else: f = 0
	if f < 0.1:
		c = gradient.interpolate(f if OS.get_ticks_msec() % 2 else 1.0)
	else: c = gradient.interpolate(f)
	draw_rect(Rect2(Vector2(), rect_size * Vector2(f, 1.0)), c)
	draw_rect(Rect2(rect_size * Vector2(f, 0.0), rect_size * Vector2(1.0-f, 1.0)), bgcolor)
	draw_rect(Rect2(Vector2(), rect_size), bgcolor, false)