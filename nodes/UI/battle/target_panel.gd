extends Panel
signal selection(x)

onready var buttons:Array = [
	[$AF0, $AF1, $AF2, $AB0, $AB1, $AB2],
	[$BF0, $BF1, $BF2, $BB0, $BB1, $BB2],
]

onready var rows:Array = [
	[ [$AF0, $AF1, $AF2], [$AB0, $AB1, $AB2]  ],
	[ [$BF0, $BF1, $BF2], [$BB0, $BB1, $BB2]  ]
]

var controls = null
var skill = null
var state = null
var level:int = 0

func prep(parent) -> void: #Connect info signals to parent.
	for side in buttons:
		for i in side:
			i.connect("display_info", parent, "showInfo")
			i.connect("hide_info"   , parent, "hideInfo")
			i.connect("select"      , self, "targetSelectSignal")
			i.connect("mouseover"   , self, "onHighlight")

func clear() -> void:
	for side in buttons:
		for i in side:
			i.disabled = true
			i.style.setTheme("disable")

func refresh() -> void:
	for group in [0, 1]:
		for slot in range(6):
			var C = core.battle.state.formations[group].formation[slot]
			buttons[group][slot].init(C, '')

func init(S, parent, lv:int, override = null) -> void:
	var targetGroup:int = 0
	var otherGroup:int  = 1
	skill = S
	state = controls.state
	if override != null: $Label.text = "%s" % override.name
	else               : $Label.text = "%s" % S.name
	refresh()
	clear()
	match(S.targetGroup):
		core.skill.TARGET_GROUP_ALLY : targetGroup = state.SIDE_PLAYER
		core.skill.TARGET_GROUP_ENEMY: targetGroup = state.SIDE_ENEMY
	var group = state.formations[targetGroup]
	for i in range(group.MAX_SIZE):
		var C = group.formation[i]
		var node:Node = buttons[targetGroup][i]
		if C != null:
			if C.filter(S):
				node.disabled = false
				node.style.fromStatus(C.condition)
			else:
				node.disabled = true
				node.style.setTheme('damage')
			if S.target[lv] == core.skill.TARGET_SINGLE_NOT_SELF and C == parent.currentChar:
				node.disabled = true
	if not connect("selection", parent, "getTarget"): show()

func targetSelectSignal(x):
	hide()
	var result = null
	match skill.target[level]:
		core.skill.TARGET_ROW:
			var row:int = x.row
			var group   = x.group
			result      = group.getRowTargets(row, skill)
		core.skill.TARGET_SINGLE:
			result = [ x ]
		_:
			result = [ x ]
	emit_signal("selection", result)
	clear()

func onHighlight(chr, b) -> void:
	var who = null
	for i in buttons[skill.targetGroup]:
		if i.chr == chr:
			who = i
	match(skill.target[level]):
#		core.skill.TARGET_LINE:
#			if who.next != null:
#				if not who.next.button.disabled:
#					who.next.button.style.highlight2(b)
#			if who.prev != null:
#				if not who.prev.button.disabled:
#					who.prev.button.style.highlight2(b)
		core.skill.TARGET_ROW:
			for i in rows[who.chr.side][who.chr.row]:
				if not i.disabled:
					i.style.highlight(b)

func _on_Button_pressed() -> void:
	hide()
	clear()
	emit_signal("selection", null)
