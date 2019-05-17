extends Panel
signal selection(x)

var skillNode = load("res://nodes/UI/skill.tscn") #Skill buttons.
var overNode =  load("res://nodes/UI/battle/over_skill_2.tscn") #Over display list buttons.

var buttons:Array =  [] #Stores skill list
var buttons2:Array = [] #Stores selected Over skill displays
var actions:Array =  [] #Holds the formed actions to return.
var currentChar = null
var target =      null
var controls =    null #Set externally from battle_controls. It should never change. ...right?
var targetPanel = null #Node for the target selector. Set externally as well.

onready var buttonWidth = $ScrollContainer.rect_size.x * 0.8

func init(C):
	clear()
	if currentChar != C: #Only clean up if the character has changed.
		while buttons2.size() > 0: #Clear over gauge buttons
			var button = buttons2.pop_back()
			button.queue_free()
			actions.clear()
	currentChar = C
	$Panel/Bar.value = C.getOverN()
	$Panel/Bar/Label.text = str("%03d%%" % C.battle.over)
	var TID = null
	$ColorRect/Label.text = str("%s's Over skills" % C.name)
	for i in C.equip.weps: #Get weapon-provided Over skills.
		if i != null:
			if i.lib.wclass != core.skill.WPCLASS_NONE:
				var S = core.getSkillPtr(i.lib.over)
				var button = skillNode.instance()
				button.init(S, 1, button.COST_OV)
				$ScrollContainer/VBoxContainer.set("custom_constants/separation", button.rect_size.y + 1)
				$ScrollContainer/VBoxContainer.add_child(button)
				button.get_node("Button").connect("pressed", self, "addSkill", [ [i.lib.over, 1] ])
				button.connect("display_info", controls.infoPanel, "showInfo")
				button.connect("hide_info", controls.infoPanel, "hideInfo")
				buttons.push_back(button)
	for i in C.skills: #Get race/class Over skills.
		TID = C.getSkillTID(i)
		var S = core.getSkillPtr(TID)
		if S.type == 0:
			var button = skillNode.instance()
			button.init(S, i[1], button.COST_OV)
			$ScrollContainer/VBoxContainer.set("custom_constants/separation", button.rect_size.y + 1)
			$ScrollContainer/VBoxContainer.add_child(button)
			button.get_node("Button").connect("pressed", self, "addSkill", [ [TID, i[1]] ])
			button.connect("display_info", controls.infoPanel, "showInfo")
			button.connect("hide_info", controls.infoPanel, "hideInfo")
			buttons.push_back(button)
		show()

func clear() -> void:
	modulate.a = 1.0
	while buttons.size() > 0:  #Clear skill buttons
		var button = buttons.pop_back()
		button.queue_free()

func updateList() -> void:
	var l:float = 0
	var remainingOver:int = currentChar.battle.over
	while buttons2.size() > 0:
		var button = buttons2.pop_back()
		button.queue_free()
	if not actions.empty():
		$Panel/Cancel.disabled = false
		$Panel/Accept.disabled = false
		for i in actions:
			var button = overNode.instance()
			button.init(i.skill)
			$Panel/Bar.add_child(button)
			button.rect_position.x = l
			button.rect_size = Vector2($Panel/Bar.rect_size.x * core.percent(i.skill.costOV), $Panel/Bar.rect_size.y)
			l += button.rect_size.x
			remainingOver -= i.skill.costOV
			buttons2.push_back(button)
	else:
		$Panel/Cancel.disabled = true
		#$Panel/Accept.disabled = true
	for i in buttons:
		i.get_node("Button").disabled = (i.S.costOV > remainingOver)


func finish() -> void:
	clear()
	controls.infoPanel.hideInfo()
	hide()

func addSkill(x): #[TID skill, int level]
	var result = controls.state.Action.new(controls.state.ACT_OVER)
	result.WP = currentChar.currentWeapon
	var S = core.getSkillPtr(x[0]) #Get pointer to skill.
	result.skill = S; result.skillTid = x[0]; result.level = x[1]
	target = core.skill.selectTargetAuto(S, x[1], currentChar, controls.state)
	if target != null: #Check if the target was resolved automagically.
		result.target = target
		actions.push_back(result)
		updateList()
	else: #If not, show the target select dialog.
		modulate.a = 0.2			#Fade menu out a bit.
		targetPanel.init(S, self, x[1])
		yield(targetPanel, "selection") #Wait for getTarget() to get called from target menu.
		targetPanel.disconnect("selection", self, "getTarget") #TODO: Disconnect from the menu itself.
		modulate.a = 1.0
		if target != null:
			result.target = target
			actions.push_back(result)
			updateList()

func getTarget(x):
	target = x

func _on_Back_pressed() -> void:
	emit_signal("selection", null)
	finish()

func _on_Cancel_pressed() -> void:
	while buttons2.size() > 0:
		var button = buttons2.pop_back()
		button.queue_free()
	actions.clear()
	updateList()

func _on_Accept_pressed() -> void:
	currentChar.battle.overAction.clear()
	for i in actions:
		currentChar.battle.overAction.push_back(i)
	print("[MENU_OVER][Accept] Actions for %s:\n%s" % [currentChar.name, currentChar.battle.overAction])
	emit_signal("selection", null)
	finish()
