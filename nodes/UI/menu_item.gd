extends Panel
signal selection(x)

var skillNode = load("res://nodes/UI/item.tscn")

var buttons = []
var target = null
var currentChar = null
var controls = null #Set externally from battle_controls. It should never change. ...right?
var targetPanel = null #Node for the target selector. Set externally as well.

onready var buttonWidth = $ScrollContainer.rect_size.x * 0.8

func init(C):
	clear()
	currentChar = C
	var S = null
	$Label.text = str("%s's items" % C.name)
	var stacks : Dictionary = {}
	var charged : Array = []
	for j in [C.inventory, C.group.inventory.general]:
		for i in j:
			if i.type == core.Inventory.Item.ITEM_CONSUMABLE:
				var tidString = core.tid.string(i.data.tid)
				if i.data.lib.charge:
					if i.data.lib.skill[i.data.level] > 0:
						charged.push_front(i)
					else:
						charged.push_back(i)
				else:
					if tidString in stacks:
						stacks[tidString].amount += 1
					else:
						stacks[tidString] = {I = i, amount = 1}
		for i in charged:
			createButton(i, 0)
		var delay = []
		for i in stacks:
			if stacks[i].I.data.lib.skill[stacks[i].I.data.level] > 0:
				createButton(stacks[i].I, stacks[i].amount)
			else: #Items that don't have an associated skill are shown below the rest.
				delay.push_back(stacks[i])
		for i in delay:
			createButton(i.I, i.amount)
		stacks = {}
		charged = []
	show()

func createButton(item, amount):
	var button = skillNode.instance()
	button.init(item, amount)
	$ScrollContainer/VBoxContainer.set("custom_constants/separation", button.rect_size.y + 1)
	$ScrollContainer/VBoxContainer.add_child(button)
	button.get_node("Button").connect("pressed", self, "chooseResult", [item])
	buttons.push_back(button)

func clear():
	var button = null
	modulate.a = 1.0
	while buttons.size() > 0:
		button = buttons.pop_back()
		button.queue_free()

func finish():
	clear()
	hide()

func chooseResult(x):
	modulate.a = 0.2			#Fade menu out a bit.
	var result = controls.state.Action.new(controls.state.ACT_ITEM)
	var I = x.data.lib
	result.IT = x
	var S = core.lib.skill.getIndex(I.skills[0])
	result.skill = S; result.skillTid = I.skills[0]; result.level = x.data.level
	target = core.skill.selectTargetAuto(S, x.data.level, currentChar, controls.state)
	if target != null: #Check if the target was resolved automagically.
		finish()
		result.target = target
		emit_signal("selection", result)
	else: #If not, show the target select dialog.
		targetPanel.init(S, self, x.data.level, I)
		yield(targetPanel, "selection") #Wait for getTarget() to get called from target menu.
		targetPanel.disconnect("selection", self, "getTarget") #TODO: Disconnect from the menu itself.
		if target == null:
			modulate.a = 1.0 #Selection was canceled so restore the window back to form.
		else:
			finish()
			result.target = target
			emit_signal("selection", result)

func getTarget(x):
	target = x

func _on_Back_pressed():
	emit_signal("selection", null)
	finish()
