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
	var button = null
	var S = null
	$Label.text = str("%s's items" % C.name)
	for i in C.group.inventory:
		S = core.lib.item.getIndex(i[0])
		button = skillNode.instance()
		button.init(S, i[1])
		$ScrollContainer/VBoxContainer.set("custom_constants/separation", button.rect_size.y + 1)
		$ScrollContainer/VBoxContainer.add_child(button)
		button.get_node("Button").connect("pressed", self, "chooseResult", [i])
		buttons.push_back(button)
		show()

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
	var I = core.lib.item.getIndex(x[0]) #Get pointer to skill.
	result.IT = I
	var S = core.lib.skill.getIndex(I.skills[0])
	result.skill = S; result.skillTid = I.skills[0]; result.level = x[1]
	target = core.skill.selectTargetAuto(S, x[1], currentChar, controls.state)
	if target != null: #Check if the target was resolved automagically.
		finish()
		result.target = target
		emit_signal("selection", result)
	else: #If not, show the target select dialog.
		targetPanel.init(S, self, x[1], I)
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
