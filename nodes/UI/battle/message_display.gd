extends Control

var msgNode = load("res://nodes/UI/battle/misc_message.tscn")
var queue = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func add(n, crit, color):
	var node = msgNode.instance()
	node.init(n, crit, color)
	add_child(node)
	queue.push_front(node)
	if queue.size() > 2:
		var old = queue.pop_back()
		old.queue_free()
	redraw()
	set_process(true)

func redraw() -> void:
	if queue.size() == 0:
		set_process(false)
	for i in range(queue.size()):
		queue[i].set_position(Vector2(0, queue[i].get_size().y * i))

func _process(delta: float) -> void:
	for i in queue:
		i.self_modulate.a -= 0.3 * delta
		if i.self_modulate.a < 0.4:
			queue.erase(i)
			i.queue_free()
	redraw()
