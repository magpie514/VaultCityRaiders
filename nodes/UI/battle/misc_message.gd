extends Label
signal done

var count:float = 0.0

func init(n:String, color:Color) -> void:
	count = 1.0
	text = str(">%s" % n)
	percent_visible = 0.0
	set("custom_colors/font_color", color)
	count = 0.0
	set_process(true)

func _process(delta: float) -> void:
	count += delta
	percent_visible = count * 4
	if count > 1.8:
		count = 0.0
		set_process(false)
		emit_signal("done", self)

