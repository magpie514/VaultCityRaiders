extends Panel
signal selection(x)

var skillNode = load("res://nodes/UI/skill.tscn")

var buttons = []
var target = null
var currentChar = null
var controls = null #Set externally from battle_controls. It should never change. ...right?
var targetPanel = null #Node for the target selector. Set externally as well.
var infoPanel = null #Node for the info display panel.

onready var buttonWidth = $ScrollContainer.rect_size.x * 0.8

func init(C, slot):
	var button = null
	var WP = C.equip.weps[slot]
	var W = WP.lib
	var WS = WP.stats
	var S = null
	var count : int = 0
	var TID = null
	clear()
	currentChar = C
	print(WS)
	$Panel/Name.text = str(W.name)
	#$Panel/DUR.text = str("%02d/%02d" % [WP.uses, WS.DUR])
	var durcolor = "#FFFFFF"
	if WS.DUR > W.durability[WP.bonus]:   durcolor = "#88FF88"
	elif WS.DUR < W.durability[WP.bonus]: durcolor = "#FF8888"
	$Panel/Bar/DUR.bbcode_text = str("%02d/[color=%s]%02d[/color]" % [WP.uses, durcolor, WS.DUR])
	$Panel/Bar.value = core.normalize(WP.uses, WS.DUR)
	if WP.bonus > 0:
		$Panel/Bonus.show()
		$Panel/Bonus.text = str("+%1d" % [WP.bonus])
	else:
		$Panel/Bonus.hide()
	#ATK display. Recolor if modified by gems or effects.
	$Panel/ATK.text = str("%03d" % WS.ATK)
	if WS.ATK > W.ATK[WP.bonus]:   $Panel/ATK.self_modulate = "#FFFFCC"
	elif WS.ATK < W.ATK[WP.bonus]: $Panel/ATK.self_modulate = "#FFCCFF"
	else:                          $Panel/ATK.self_modulate = "#FFFFFF"
	#ETK display. Same as above.
	$Panel/ETK.text = str("%03d" % WS.ETK)
	if WS.ETK > W.ETK[WP.bonus]:   $Panel/ETK.self_modulate = "#FFFFCC"
	elif WS.ETK < W.ETK[WP.bonus]: $Panel/ETK.self_modulate = "#FFCCFF"
	else:                          $Panel/ETK.self_modulate = "#FFFFFF"
	$Panel/DGem.init(WP.DGem)
	$Panel/DGem.set_process(true)
	for i in ['END', 'WIS', 'AGI', 'LUC']:
		var node = $Panel/Stats.get_node(i)
		node.text = str("%s%03d" % ['+' if WS[i] >= 0 else '-', WS[i]])
		node = $Panel/Stats.get_node(str("%sB" % i))
		node.value = core.normalize(WS[i], 128)

	for i in W.skill:
		count += 1
		S = core.lib.skill.getIndex(i)
		button = skillNode.instance()
		button.init(S, WP.bonus, button.COST_WP)
		$ScrollContainer/VBoxContainer.set("custom_constants/separation", button.rect_size.y + 1)
		$ScrollContainer/VBoxContainer.add_child(button)
		button.get_node("Button").connect("pressed", self, "chooseResult", [[i, WP.bonus], WP])
		button.connect("display_info", controls.infoPanel, "showInfo")
		button.connect("hide_info", controls.infoPanel, "hideInfo")
		buttons.push_back(button)

	for i in WP.DGem.skills:
		S = core.getSkillPtr(i[0])
		button = skillNode.instance()
		var tmp = i[2] if i[2] != null else S
		button.init(tmp, i[1], button.COST_WP, true)
		$ScrollContainer/VBoxContainer.set("custom_constants/separation", button.rect_size.y + 1)
		$ScrollContainer/VBoxContainer.add_child(button)
		button.get_node("Button").connect("pressed", self, "chooseResult", [[i[0], i[1]], WP, i[2]])
		button.connect("display_info", controls.infoPanel, "showInfo")
		button.connect("hide_info", controls.infoPanel, "hideInfo")
		buttons.push_back(button)

	for i in C.skills:
		TID = C.getSkillTID(i)
		S = core.getSkillPtr(TID)
		if S.type == 1:
			button = skillNode.instance()
			button.init(S, i[1], button.COST_WP)
			$ScrollContainer/VBoxContainer.set("custom_constants/separation", button.rect_size.y + 1)
			$ScrollContainer/VBoxContainer.add_child(button)
			button.get_node("Button").connect("pressed", self, "chooseResult", [[TID, i[1]], WP])
			button.connect("display_info", controls.infoPanel, "showInfo")
			button.connect("hide_info", controls.infoPanel, "hideInfo")
			buttons.push_back(button)
	show()


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

func chooseResult(x, WP, skillOverride=null): #[TID skill, int level]
	modulate.a = 0.2			#Fade menu out a bit.
	if skillOverride != null: print("[MENU_WEAPON][chooseResult] Found override: %s" % skillOverride.name)
	var S = core.getSkillPtr(x[0]) if skillOverride == null else skillOverride #Get pointer to skill.
	target = core.skill.selectTargetAuto(S, x[1], currentChar, controls.state)
	if target != null: #Check if the target was resolved automagically.
		finish()
		emit_signal("selection", [controls.state.ACT_FIGHT, x[0], x[1], target, WP, skillOverride])
	else: #If not, show the target select dialog.
		targetPanel.init(S, self, x[1])
		yield(targetPanel, "selection") #Wait for getTarget() to get called from target menu.
		targetPanel.disconnect("selection", self, "getTarget") #TODO: Disconnect from the menu itself.
		if target == null:
			modulate.a = 1.0 #Selection was canceled so restore the window back to form.
		else:
			finish()
			emit_signal("selection", [controls.state.ACT_FIGHT, x[0], x[1], target, WP, skillOverride])

func getTarget(x):
	target = x

func _on_Back_pressed():
	emit_signal("selection", null)
	finish()
