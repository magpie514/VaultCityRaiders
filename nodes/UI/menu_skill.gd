extends Panel
signal selection(x)

var skillNode = load("res://nodes/UI/skill.tscn")


var buttons = []
var target = null
var currentChar = null
var controls = null #Set externally from battle_controls. It should never change. ...right?
var targetPanel = null #Node for the target selector. Set externally as well.
var validSkills = [
	core.skill.CAT_ATTACK,
	core.skill.CAT_SUPPORT,
]

onready var buttonWidth = $ScrollContainer.rect_size.x * 0.8
onready var container = $ScrollContainer/VBoxContainer

func init(C):
	clear()
	currentChar = C
	$ColorRect/Label.text = str("%s's skills" % C.name)
	$DGem.init(C.DGem)
	$DGem.set_process(true)
	for i in C.skills:
		var TID = C.getSkillTID(i)
		var S = core.getSkillPtr(TID)
		if S.type == 0 and (S.category in validSkills):
			var button = skillNode.instance()
			button.init(S, i[1], button.COST_EP)
			addButton(button, [TID, i[1]])
	if not C.extraSkills.empty():
		for i in C.extraSkills:
			var S = core.getSkillPtr(i[0])
			if S.type == 0 and (S.category in validSkills):
				var button = skillNode.instance()
				button.init(S, i[1], button.COST_EP, true)
				addButton(button, [i[0], i[1]])
	show()

func addButton(button, data:Array):
	container.add_child(button)
	button.get_node("Button").connect("pressed", self, "chooseResult", data)
	button.connect("display_info", controls.infoPanel, "showInfo")
	button.connect("hide_info"   , controls.infoPanel, "hideInfo")
	buttons.push_back(button)

func clear() -> void:
	var button = null
	modulate.a = 1.0
	while buttons.size() > 0:
		button = buttons.pop_back()
		button.queue_free()

func finish() -> void:
	clear()
	controls.infoPanel.hideInfo()
	hide()

func chooseResult(TID, level): #[TID skill, int level]
	modulate.a = 0.2			#Fade menu out a bit.
	var result = controls.state.Action.new(controls.state.ACT_SKILL)
	result.WP = currentChar.currentWeapon
	var S = core.getSkillPtr(TID) #Get pointer to skill.
	result.skill = S; result.skillTid = TID; result.level = level
	target = core.skill.selectTargetAuto(S, level, currentChar, controls.state)
	if target != null: #Check if the target was resolved automagically.
		finish()
		result.target = target
		emit_signal("selection", result)
	else: #If not, show the target select dialog.
		targetPanel.init(S, self, level)
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
