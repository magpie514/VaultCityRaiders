extends Control
var panel = load("res://nodes/UI/battle/ActionQueueItem.tscn")

func init(Q:Array) -> void: #Q:Action Queue, array of extra actions.
	for i in get_children():
		if not i is Label: i.queue_free()
	var pos = 0
	for i in Q:
		addEntry(i, pos)
		pos += 1

func addEntry(A:BattleState.Action, pos:int) -> void:
	var P = panel.instance()
	P.init(A, pos+1)
	add_child(P)
	P.set_position(Vector2(0, pos * P.get_size().y + 5))
