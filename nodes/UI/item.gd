extends Control
signal display_info(x)
signal hide_info

var I = null
var level = 1

func init(_I, _level):
	I = _I
	level = _level
	var elem = null
	$Label.text = I.name
	$Button.hint_tooltip = I.description

func _on_Button_mouse_entered() -> void:
	emit_signal("display_info", I, 2, level)

func _on_Button_mouse_exited() -> void:
	emit_signal("hide_info")
