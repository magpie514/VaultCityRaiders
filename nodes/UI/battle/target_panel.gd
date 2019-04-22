extends Panel
signal selection(x)

var _targetButton = load("res://nodes/UI/target_button.tscn")

var buttons = []
var rows = [[],[]]
var controls = null
var skill = null
var state = null
var _level = 0

func makeEntry(chr, prev):
	var result = {
		chr = chr,
		button = _targetButton.instance(),
		next = null,
		prev = prev
	}
	if prev != null:
		prev.next = result
	return result

func init(S, parent, level, override = null):
	var group = null
	skill = S
	state = controls.state
	var test = connect("selection", parent, "getTarget")
	if override != null:
		$Label.text = "%s" % override.name
	else:
		$Label.text = "%s" % S.name
	var flip = false
	match(S.targetGroup):
		core.skill.TARGET_GROUP_ALLY:
			group = state.formations[state.SIDE_PLAYER]
		core.skill.TARGET_GROUP_ENEMY:
			group = state.formations[state.SIDE_ENEMY]
			flip = true
	var targets = group.formation
	var temp = null
	var temp2 = null
	var current = null
	var key = 1
	clear()
	for i in range(group.MAX_SIZE):
		current = targets[i]
		if i == group.ROW_SIZE:
			temp = null
			key = 1
		if current != null:
			temp2 = makeEntry(current, temp)
			buttons.push_back(temp2)
			temp = temp2
			add_child(temp2.button)
			buttonPosition(group, i, temp2.button, flip)
			temp2.button.init(current, str("%1s%1s" % ["S" if i < group.ROW_SIZE else "", key]))
			rows[(0 if i < group.ROW_SIZE else 1)].push_back(temp2)
			connectUISignals(temp2.button)
			if current.filter(S):
				temp2.button.disabled = false
			else:
				temp2.button.disabled = true
			if S.target[level] == core.skill.TARGET_SINGLE_NOT_SELF and current == parent.currentChar:
				temp2.button.disabled = true
			key += 1
	show()


func buttonPosition(group, i, button, flip):
	var col = i if i < group.ROW_SIZE else i - group.ROW_SIZE
	var row = 0 if i < group.ROW_SIZE else 1
	if flip:
		row = 1 if row == 0 else 0
	else:
		col += 1
	button.rect_position = Vector2(col * button.rect_size.x, 22 + row * button.rect_size.y)

func connectUISignals(obj):
	obj.connect("display_info", controls.parent, "showInfo")
	obj.connect("hide_info", controls.parent, "hideInfo")
	obj.connect("select", self, "targetSelectSignal")
	obj.connect("mouseover", self, "onHighlight")

func disconnectUISignals(obj):
	obj.disconnect("display_info", controls.parent, "showInfo")
	obj.disconnect("hide_info", controls.parent, "hideInfo")
	obj.disconnect("select", self, "targetSelectSignal")
	obj.disconnect("mouseover", self, "onHighlight")

func targetSelectSignal(x):
	hide()
	var result = null
	match skill.target[_level]:
		core.skill.TARGET_SPREAD:
			var who = null
			result = [x]
			for i in buttons:
				if i.chr == x:
					who = i
			if who.next != null:
				if who.next.chr.filter(skill):
					result.push_back(who.next.chr)
			if who.prev != null:
				if who.prev.chr.filter(skill):
					result.push_back(who.prev.chr)
		core.skill.TARGET_ROW:
			var row = x.row
			var group = x.group
			result = group.getRowTargets(row, skill)
		core.skill.TARGET_SINGLE:
			result = [x]
		_:
			result = [x]
	emit_signal("selection", result)
	hide()
	clear()

func onHighlight(chr, b):
	var who = null
	for i in buttons:
		if i.chr == chr:
			who = i
	match(skill.target[_level]):
		core.skill.TARGET_SPREAD:
			if who.next != null:
				if not who.next.button.disabled:
					who.next.button.style.highlight2(b)
			if who.prev != null:
				if not who.prev.button.disabled:
					who.prev.button.style.highlight2(b)
		core.skill.TARGET_ROW:
			for i in rows[who.chr.row]:
				if not i.button.disabled:
					i.button.style.highlight(b)
		core.skill.TARGET_ROW_RANDOM:
			for i in buttons:
				if not i.button.disabled:
					i.button.style.highlight(b)

func clear():
	for i in buttons:
		if i != null:
			disconnectUISignals(i.button)
			i.button.queue_free()
	buttons = []
	rows = [[], []]


func _on_Button_pressed():
	hide()
	clear()
	emit_signal("selection", null)
