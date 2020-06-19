extends Panel

signal display_info(x)
signal select(x)
signal hide_info
signal mouseover(x, y)

var chr = null
var style = core._charPanel.new(self, "res://resources/tres/target_button.tres", "custom_styles/panel")
var disabled:bool = false
var info:int = 1

func init(C, key = '') -> void:
	if C == null:
		disabled = true
		$Name.text = ''
		$Key.hide()
		$Bar.value = 0.0
		return
	else:
		visible = true
	self.chr = C
	if C is core.Player: info = 0
	$Name.text = C.name
	$Bar.value = C.getHealthN()
	if not key.empty():
		$Key.text = key
		$Key.show()
	else:
		$Key.hide()
	style.fromStatus(C.condition)

func _on_Button_pressed() -> void:
	if not disabled:
		emit_signal("hide_info")
		emit_signal("select", chr)

func _on_Button_mouse_entered() -> void:
	if not disabled:
		style.highlight(true)
		emit_signal("mouseover", chr, true)
		emit_signal("display_info", chr, info)

func _on_Button_mouse_exited():
	if not disabled:
		style.highlight(false)
		emit_signal("mouseover", chr, false)
		emit_signal("hide_info")
