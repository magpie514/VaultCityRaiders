extends Panel

signal display_info(x)
signal select(x)
signal hide_info
signal mouseover(x, y)

var chr = null
var style = core._charPanel.new(self, "res://resources/tres/target_button.tres", "custom_styles/panel")
var disabled = false
var info:int = 1

func init(C, key = null):
	chr = C
	if chr is core.Player:
		info = 0
	$Name.text = C.name
	$Bar.value = C.getHealthN()
	if key != null:
		$Key.text = key
		$Key.show()
	else:
		$Key.hide()
	style.fromStatus(C.condition)

func _on_Button_pressed():
	if not disabled:
		emit_signal("hide_info")
		emit_signal("select", chr)

func _on_Button_mouse_entered():
	style.highlight(true if not disabled else false)
	emit_signal("mouseover", chr, true)
	emit_signal("display_info", chr, info)

func _on_Button_mouse_exited():
	style.highlight(false)
	emit_signal("mouseover", chr, false)
	emit_signal("hide_info")
