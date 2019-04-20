extends Control

var bars = core.newArray(10)
var _bar = preload("res://nodes/UI/battle/enemy_display.tscn")
var group = null
onready var width = int(rect_size.x / 5)

func init(_group):
	group = _group
	var node
	group.display = self
	for i in range(10):
		if group.formation[i] != null:
			bars[i] = createDisplay(i)
			bars[i].fadeTo(0.1, 5.0)

func update():
	for i in range(10):
		if group.formation[i] == null:
			if bars[i] != null:
				bars[i].stop()
				bars[i] = null
		else:
			group.formation[i].display.update()

func revive(C, slot) -> void:
	bars[slot] = createDisplay(slot)
	group.formation[slot].sprDisplay = group.initSprite(group.formation[slot], slot)

func createDisplay(slot):
	var node = _bar.instance()
	node.rect_position = Vector2(slot * width, 60) if slot < 5 else Vector2((slot - 5) * width, 30)
	node.resize(Vector2(width - 2, 8))
	node.get_node("ComplexBar").value = group.formation[slot].getHealthN()
	node.init(group.formation[slot])
	group.formation[slot].display = node
	group.formation[slot].sprDisplay = group.initSprite(group.formation[slot], slot)
	add_child(node)
	return node


func showBars(time):
	for i in bars:
		if i != null: i.fadeTo(0.9, time)

func fadeBars(time):
	for i in bars:
		if i != null: i.fadeTo(0.1, time)

func battleTurnUpdate():
	pass

func connectSignals(node, obj):
	node.connect("display_info", obj, "showInfo")
	node.connect("hide_info", obj, "hideInfo")

func connectUISignals(obj):
	for i in range(10):
		if group.formation[i] != null:
			connectSignals(bars[i], obj)

func disconnectUISignals(obj):
	for i in range(10):
		if group.formation[i] != null:
			bars[i].disconnect("display_info", obj, "showInfo")
			bars[i].disconnect("hide_info", obj, "hideInfo")
