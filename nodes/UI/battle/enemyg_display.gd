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
#	grid[slot] = createDisplay(slot)
#	if group.formation[slot].sprite != null:
#		group.formation[slot].sprite.queue_free()
	C.display = grid[slot].get_node("CharDisplay")
	group.formation[slot].sprite = core.battle.displayManager.initSprite(group.formation[slot], slot)

func createDisplay(slot:int):
	var node:Node = grid[slot]
	var C         = group.formation[slot]
	node.get_node("ComplexBar").value = C.getHealthN()
	node.init(C)
	C.UIdisplay = node
	C.sprite  = core.battle.displayManager.initSprite(C, slot)
	return node

func battleTurnUpdate():
	pass
