extends Panel

func _on_Button_pressed():
	$CharDisplay.damage(9999, randi()%2, randi()%3)

func _on_Button2_pressed():
	$CharDisplay.damage(-9999)

func _on_Button3_pressed():
	$CharDisplay.message("TEST", "FFFF00")

func _on_Button4_pressed() -> void:
	var test:Array = [randi() % core.CONDITIONDEFS_DEFAULT.size(), -2]
	$CharDisplay.condition(test, 15, 17)
