extends Node2D

var count = 0
var dir = false

func _ready():
	$Viewport.size = get_viewport().size
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

