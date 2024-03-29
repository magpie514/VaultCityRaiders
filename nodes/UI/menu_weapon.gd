extends Panel
signal selection(x)

var skillNode = load("res://nodes/UI/skill.tscn")
var separator = load("res://nodes/UI/skill_category_separator.tscn")

var buttons = [] #Logical list of added buttons so they can be removed on refresh.
var target = null
var currentChar = null
var controls = null #Set externally from battle_controls. It should never change. ...right?
var targetPanel = null #Node for the target selector. Set externally as well.
var infoPanel = null #Node for the info display panel.

onready var buttonWidth = $ScrollContainer.rect_size.x * 0.8
onready var container = $ScrollContainer/VBoxContainer

func init(C, slot):
	var button = null
	var WP = C.equip.slot[slot]
	var W = WP.lib
	var WS = WP.stats
	var S = null
	var count:int = 0
	var TID = null
	clear()
	currentChar = C
	# Set up panel info #########################################################
	$Panel/Name.text = str(W.name)
	var durcolor = "#FFFFFF"
	if WS.DUR > W.durability[WP.level]:   durcolor = "#88FF88"
	elif WS.DUR < W.durability[WP.level]: durcolor = "#FF8888"
	$Panel/Bar/DUR.bbcode_text = str("%02d/[color=%s]%02d[/color]" % [WP.uses, durcolor, WS.DUR])
	$Panel/Bar.value = core.normalize(WP.uses, WS.DUR)
	if WP.level > 0:
		$Panel/Bonus.show()
		$Panel/Bonus.text = str("+%1d" % [WP.level])
	else:
		$Panel/Bonus.hide()
	#ATK display. Recolor if modified by gems or effects.
	$Panel/ATK.text = str("%03d" % WS.ATK)
	if WS.ATK > W.ATK[WP.level]:   $Panel/ATK.self_modulate = "#FFFFCC"
	elif WS.ATK < W.ATK[WP.level]: $Panel/ATK.self_modulate = "#FFCCFF"
	else:                          $Panel/ATK.self_modulate = "#FFFFFF"
	#ETK display. Same as above.
	$Panel/ETK.text = str("%03d" % WS.ETK)
	if WS.ETK > W.ETK[WP.level]:   $Panel/ETK.self_modulate = "#FFFFCC"
	elif WS.ETK < W.ETK[WP.level]: $Panel/ETK.self_modulate = "#FFCCFF"
	else:                          $Panel/ETK.self_modulate = "#FFFFFF"
	$Panel/DGem.init(WP.DGem)
	$Panel/DGem.set_process(true)
	for i in ['DEF', 'EDF', 'AGI', 'LUC']:
		var node = $Panel/Stats.get_node(i)
		node.text = str("%s%03d" % ['+' if WS[i] >= 0 else '-', WS[i]])
		node = $Panel/Stats.get_node(str("%sB" % i))
		node.value = core.normalize(WS[i], 128)

	# Fill the skills list with skill buttons ###################################
	for i in W.skill:
		# count += 1 #Keep a count of list elements to assign hotkeys.
		button = skillNode.instance()
		S = core.lib.skill.getIndex(i)
		button.init(S, WP.level, self, button.COST_WP)
		addButton(button, [[i, WP.level], WP])

	addSeparator("Dragon gem skills")

	for i in WP.DGem.skills:
		#TODO: i[0]: TID??, i[1]: level, i[2]: ???
		button = skillNode.instance()
		S = core.getSkillPtr(i[0])
		var tmp = i[2] if i[2] != null else S
		button.init(tmp, i[1], self, button.COST_WP, true)
		addButton(button, [[i[0], i[1]], WP, i[2]])

	addSeparator("Weapon skills")

	for i in C.skills:
		TID = C.getSkillTID(i)
		S = core.getSkillPtr(TID)
		if S.requiresWeapon == WP.lib.wclass and S.category in [core.skill.CAT_ATTACK, core.skill.CAT_SUPPORT]:
			button = skillNode.instance()
			button.init(S, i[1], self, button.COST_WP)
			addButton(button, [[TID, i[1]], WP])
	show()

func addButton(button, data:Array):
	container.add_child(button)
	button.get_node("Button").connect("pressed", self, "chooseResult", data)
	button.connect("display_info", controls.infoPanel, "showInfo")
	button.connect("hide_info"   , controls.infoPanel, "hideInfo")
	buttons.push_back(button)

func addSeparator(text:String):
	var sep = separator.instance()
	container.add_child(sep)
	sep.get_node("Label").text = text
	buttons.push_back(sep)

func clear():
	$Panel/DGem.set_process(false)
	var button = null
	modulate.a = 1.0
	while buttons.size() > 0:
		button = buttons.pop_back()
		button.queue_free()

func finish():
	clear()
	controls.infoPanel.hideInfo()
	hide()


func setAction(TID, level:int, skillOverride = null) -> BattleState.Action:
	var result:BattleState.Action = BattleState.Action.new(BattleState.ACT_FIGHT)
	result.user     = currentChar
	result.skill    = core.getSkillPtr(TID) if skillOverride == null else skillOverride
	result.override = skillOverride
	result.skillTid = TID
	result.level    = level
	result.spd      = currentChar.calcSPD(result.skill.spdMod[level])
	result.spdMod   = result.skill.spdMod[level]
	return result


func chooseResult(x, WP, skillOverride=null): #[TID skill, int level]
	var result:BattleState.Action = setAction(x[0], x[1])
	modulate.a = 0.2 #Fade menu out a bit.
	result.WP = WP
	if skillOverride != null: print("[MENU_WEAPON][chooseResult] Found override: %s" % skillOverride.name)
	var S = result.skill
	target = core.skill.selectTargetAuto(S, x[1], currentChar, controls.state)
	if target != null: #Check if the target was resolved automagically.
		finish()
		result.target = target
		emit_signal("selection", result)
	else: #If not, show the target select dialog.
		targetPanel.init(S, self, x[1])
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
