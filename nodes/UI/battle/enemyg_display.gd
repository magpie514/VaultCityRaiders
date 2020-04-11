extends Control

var _bar = preload("res://nodes/UI/battle/enemy_display.tscn")
var group = null
onready var grid:Array = [ $F0, $F1, $F2, $B0, $B1, $B2 ]

func init(_group) -> void:
	group = _group
	var node
	group.display = self
	for i in range(6):
		if group.formation[i] != null:
			grid[i].init(group.formation[i])
			group.formation[i].display = grid[i]

func update():
	pass

func revive(C, slot:int) -> void:
	#grid[slot] = createDisplay(slot)
#	if group.formation[slot].sprite != null:
#		group.formation[slot].sprite.queue_free()
	C.display = grid[slot]
	group.formation[slot].sprite = core.battle.displayManager.initSprite(group.formation[slot], slot)

func createDisplay(slot:int):
	var node:Node = grid[slot]
	var C         = group.formation[slot]
	node.get_node("ComplexBar").value = C.getHealthN()
	node.init(C)
	C.display = node
	C.sprite  = core.battle.displayManager.initSprite(C, slot)
	var anchor:Node = core.battle.displayManager.getAnchorNode(C, slot)
	return node

func battleTurnUpdate():
	pass

func connectSignals(node, obj):
	node.connect("display_info", obj, "showInfo")
	node.connect("hide_info", obj, "hideInfo")

func connectUISignals(obj):
	for i in grid:
		connectSignals(i, obj)

func disconnectUISignals(obj):
	for i in grid:
		i.disconnect("display_info", obj, "showInfo")
		i.disconnect("hide_info", obj, "hideInfo")
