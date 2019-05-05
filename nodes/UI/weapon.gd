extends Control
signal select

func init(WP, key):
	var W = WP.lib
	if WP.level > 0:
		$Label.text = str("%s +%1d" % [W.name, WP.level])
	else:
		$Label.text = str("%s" % [W.name])
	$Label2.text = str("%1s" % key)
	$DUR.text = str("%02d" % WP.uses)
	if WP.uses > W.durability[WP.level] / 2:
		$DUR.self_modulate = Color(1.0, 1.0, 1.0)
	elif WP.uses > W.durability[WP.level] / 4:
		$DUR.self_modulate = Color(1.0, 1.0, 0.0)
	elif WP.uses > W.durability[WP.level] / 10:
		$DUR.self_modulate = Color(1.0, 0.0, 0.0)
	setCurrent(false)

func setCurrent(val: bool) -> void:
	$Current.visible = val
	set_process(val)

func _on_Button_pressed() -> void:
	emit_signal("select")

func _process(delta: float) -> void:
	if $Current.visible:
		var C = $Current
		C.self_modulate.a -= 1.2 * delta
		if C.self_modulate.a < 0:
			C.self_modulate.a += 1.0
		#print(C.self_modulate.a, "|", delta)