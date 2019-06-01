extends Panel
signal selection(x)

var weaponNode = load("res://nodes/UI/weapon.tscn")
var skillNode = load("res://nodes/UI/skill.tscn")

var buttons = []
var skillButtons = []
var target = null
var currentChar = null
var controls = null #Set externally from battle_controls. It should never change. ...right?
var targetPanel = null #Node for the target selector. Set externally as well.

onready var buttonWidth = $ScrollContainer.rect_size.x * 0.8

func init(C):
	clear()
	$SkillPanel.hide()
	currentChar = C
	var button = null
	var W = null
	var count = 0
	$Label.text = str("%s's gear" % C.name)
	for t in C.equip.WEAPON_SLOT:
		var i = C.equip.slot[t] #TODO: Remember this h...is this file even used?
		count += 1
		W = core.lib.weapon.getIndex(i.id)
		button = weaponNode.instance()
		button.init(i, count)
		$ScrollContainer/VBoxContainer.set("custom_constants/separation", button.rect_size.y + 1)
		$ScrollContainer/VBoxContainer.add_child(button)
		if i == C.currentWeapon: button.get_node("Current").show()
		button.get_node("Button").connect("pressed", self, "chooseSkill", [i, button])
		buttons.push_back(button)
		show()

func initSkills(WP, slot):
	skillsClear()
	$SkillPanel.show()
	self_modulate.h = 24.0
	var button = null
	var count = 0
	var S = null
	var W = core.lib.weapon.getIndex(WP.id)
	for i in W.skill:
		count += 1
		S = core.lib.skill.getIndex(i)
		button = skillNode.instance()
		button.init(S.name, 1)
		$SkillPanel/ScrollContainer/VBoxContainer.set("custom_constants/separation", button.rect_size.y + 1)
		$SkillPanel/ScrollContainer/VBoxContainer.add_child(button)
		$SkillPanel.rect_position.y = slot.rect_position.y + 60
		button.get_node("Button").connect("pressed", self, "chooseResult", [i, WP])
		skillButtons.push_back(button)
		show()

func skillsClear():
	var button = null
	$SkillPanel.modulate.a = 1.0
	while skillButtons.size() > 0:
		button = skillButtons.pop_back()
		button.queue_free()


func clear():
	var button = null
	modulate.a = 1.0
	while buttons.size() > 0:
		button = buttons.pop_back()
		button.queue_free()

func finish():
	clear()
	skillsClear()
	hide()


func chooseSkill(x, slot):
	#modulate.a = 0.2			#Fade menu out a bit.
	initSkills(x, slot)

func chooseResult(x, WP):
	modulate.s = 0.0
	modulate.a = 0.2			#Fade menu out a bit.
	var S = core.lib.skill.getIndex(x) #Get pointer to skill.
	target = core.skill.selectTargetAuto(S, x[1], currentChar, controls.state)
	if target != null: #Check if the target was resolved automagically.
		finish()
		emit_signal("selection", [controls.state.ACT_FIGHT, x, target, WP])
	else: #If not, show the target select dialog.
		targetPanel.init(S, self)
		yield(targetPanel, "selection") #Wait for getTarget() to get called from target menu.
		targetPanel.disconnect("selection", self, "getTarget") #TODO: Disconnect from the menu itself.
		if target == null:
			modulate.a = 1.0 #Selection was canceled so restore the window back to form.
		else:
			finish()
			emit_signal("selection", [controls.state.ACT_FIGHT, x, target, WP])

func getTarget(x):
	target = x

func _on_Back_pressed():
	emit_signal("selection", null)
	finish()


func _on_SkillBack_pressed():
	skillsClear()
	$SkillPanel.hide()
