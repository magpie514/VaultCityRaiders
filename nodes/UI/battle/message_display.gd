extends Control

const msgNode = preload("res://nodes/UI/battle/misc_message.tscn")
var stack:Array = []

func add(msg:String, col:Color) -> void:
	if msg:
		var node = addMsg()
		node.init(msg, col)
		stack.push_back(node)
	refresh()

func refresh() -> void:
	var slot:int = 1
	for i in stack:
		i.rect_position.y = slot * -10
		slot += 1

func addMsg() -> Node:
	var node    := msgNode.instance()
	var slot:int = stack.size()
	add_child(node)
	var ok = node.connect("done", self, "_on_done")
	return node

func _on_done(what:Control) -> void:
	what.disconnect("done", self, "_on_done")
	stack.erase(what)
	what.queue_free()
	refresh()

