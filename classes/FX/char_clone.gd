extends "res://classes/FX/animation_char.gd"

func _process(delta: float) -> void:
	if sprite != null:
		if visible:
			sprite.global_position = (position * parent.scale)
		._process(delta)
