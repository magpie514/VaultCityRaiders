#Slave camera controlled by skill animations.
extends Camera2D

onready var user   = get_node("../DummyUser")
onready var target = get_node("../DummyTarget")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
