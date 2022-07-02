#Animation puppet character logic. Passes parameters and positions to a linked sprite.
extends "res://classes/FX/animation_char.gd"

export(bool) var approach:bool       = false
export(bool) var capture:bool        = false

func _process(delta: float) -> void:
	if sprite != null:
		if capture:
			if approach:
				sprite.global_position = parent.global_position + (position * parent.scale)
			else:
				sprite.global_position = sprite.get_parent().global_position + (position - a_offset) * parent.scale
		._process(delta)

