extends Node2D

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	var viewport = get_viewport()
	$Sprite.show()
	var tex = $Viewport.get_texture()
	$Sprite.texture = tex
	#$Viewport.size = viewport.size
