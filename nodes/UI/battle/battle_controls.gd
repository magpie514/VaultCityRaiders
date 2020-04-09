extends Control
#class_name Base, "res://resources/icons/stab.svg"
signal finished

onready var skill = core.skill

var state = null
var currentChar = null
var target = null
var action = null
var parent = null
var inputs = []
var infoPanel = null
var currentPanel = self


func init(st, info):
	state = st
	infoPanel = info

func _ready():
	$TargetPanel.controls = self
	$SkillMenu.controls = self
	$SkillMenu.targetPanel = $TargetPanel
	$WeaponMenu.controls = self
	$WeaponMenu.targetPanel = $TargetPanel
	$ItemMenu.controls = self
	$ItemMenu.targetPanel = $TargetPanel
	$OverMenu.controls = self
	$OverMenu.targetPanel = $TargetPanel

func setup(C, place:int, node) -> void:
	parent = node
	currentChar = C
	$Main/Name.text = C.name

	if place == 0: #Only show party-wide actions on the first character.
		$Main/Switch.show(); $Main/Macro.show()
		$Main/Talk.show();   $Main/Back.hide()
	else:
		$Main/Switch.hide(); $Main/Macro.hide()
		$Main/Talk.hide();   $Main/Back.show()

	#Set up Over gauge.
	$Main/OverBar.value = C.getOverN()
	$Main/Over/Label.text = str("%03d%%" % int(C.battle.over))
	#Only enable Over menu if there's enough Over for a tier 1 Over skill (33%).
	$Main/Over.disabled = (C.getOverN() > core.skill.OVER_COST_1)
	$Main/Over.disabled = false #TODO: For testing, remove when done.
	$Main/OverBar/OverDisplay.init(C.battle.overAction)

	#Inialize weapons.
	$Main/WeaponPanel.init(C)

	if C.battle.chain > 0: #Show chain counter if pertinent.
		$Main/Chain/Count.text = str(C.battle.chain)
		$Main/Chain.show()
	else:
		$Main/Chain.hide()
	show()
	$Main.show()

	if not canRepeat(C.battle.lastAction):
		$Main/Repeat.disabled = true
		$Main/Repeat.text = str("Repeat last")
	else:
		$Main/Repeat.disabled = false
		var RS = C.battle.lastAction.skill if C.battle.lastAction.IT == null else C.battle.lastAction.IT.data.lib
		$Main/Repeat.text = str("Repeat %s" % RS.name)

func _process(delta: float) -> void: #Just a quick hack for now. Do this with signals.
	if $Main.visible and currentPanel == self:
		if Input.is_key_pressed(KEY_1):
			_on_Weapon_pressed(0)
		elif Input.is_key_pressed(KEY_2):
			_on_Weapon_pressed(1)
		elif Input.is_key_pressed(KEY_3):
			_on_Weapon_pressed(2)
		elif Input.is_key_pressed(KEY_4):
			_on_Weapon_pressed(3)
		elif Input.is_key_pressed(KEY_Q):
			_on_Skill_pressed()
		elif Input.is_key_pressed(KEY_W):
			_on_Defend_pressed()
		elif Input.is_key_pressed(KEY_E):
			_on_Item_pressed()
		elif Input.is_key_pressed(KEY_R):
			_on_Over_pressed()


func exit(val) -> void:
	closeAll()
	if "user" in val: val.user = currentChar
	emit_signal("finished", val)

func closeAll() -> void:
	$WeaponMenu.finish()
	$SkillMenu.finish()
	$ItemMenu.finish()
	$OverMenu.finish()
	$TargetPanel.clear()

func _on_Weapon_pressed(slot:int) -> void:
	var display = null
	var W = null
	$Main.hide()
	currentPanel = $WeaponMenu
	$WeaponMenu.init(currentChar, slot)
	action = null
	yield($WeaponMenu, "selection") #This receives the menu's selection() signal with the skill and target.
	if action != null: exit(action)
	else: $Main.show()

func _on_Skill_pressed() -> void:
	var display = null
	var S = null
	$Main.hide()
	$SkillMenu.init(currentChar)
	currentPanel = $SkillMenu
	action = null
	yield($SkillMenu, "selection") #This receives the menu's selection() signal with the skill and target.
	if action != null: exit(action)
	else: $Main.show()

func _on_Defend_pressed() -> void:
	var result = state.Action.new(state.ACT_DEFEND)
	result.skillTid = ["core", "defend"]
	result.skill = core.lib.skill.getIndex(result.skillTid)
	result.level = 1
	result.user = currentChar
	result.target = [currentChar]
	result.WP = currentChar.currentWeapon
	exit(result)

func _on_Item_pressed() -> void:
	var display = null
	var S = null
	$Main.hide()
	$ItemMenu.init(currentChar)
	currentPanel = $ItemMenu
	action = null
	yield($ItemMenu, "selection") #This receives the menu's selection() signal with the skill and target.
	if action != null:
		exit(action)
	else:
		$Main.show()

func _on_Over_pressed() -> void:
	var display = null
	var S = null
	$Main.hide()
	$OverMenu.init(currentChar)
	currentPanel = $OverMenu
	action = null
	yield($OverMenu, "selection") #This receives the menu's selection() signal with the skill and target.
	if action != null: exit(action)
	else:
		$Main.show()
		if currentChar.battle.overAction.size() > 0:
			$Main/OverBar/OverDisplay.init(currentChar.battle.overAction)

func _on_Run_pressed() -> void: #TODO: Run.
	exit([state.ACT_RUN])

func _on_Macro_pressed() -> void:
	pass # replace with function body

func _on_Back_pressed() -> void:
	exit([-1])

func _on_Switch_pressed() -> void:
	pass # replace with function body

func canRepeat(act) -> bool:
	if act == null:
		return false
	if act.IT != null:
		var temp:bool = currentChar.group.inventory.canReuseConsumable(act.IT)
		if temp:
			return true
		else:
			act.IT = null
			return false
	return true

func _on_Repeat_pressed() -> void:
	var lastAct = currentChar.battle.lastAction
	if lastAct.skill.targetGroup == skill.TARGET_GROUP_ENEMY:
		var p = currentChar.group.versus.getAllTargets(lastAct.skill)
		for i in lastAct.target:
			if not i in p:
				print("[BATTLECONTROLS][_on_Repeat_pressed] targetting inactive target.")
				lastAct.target.erase(i)
	if lastAct.IT != null:
		if not lastAct.IT.data.lib.charge:
			for i in currentChar.group.inventory.general:
				if lastAct.IT.data.lib == i.data.lib and lastAct.IT.data.level == i.data.level:
					print("[BATTLECONTROLS][_on_Repeat_pressed] Found another %s on stack, using." % lastAct.IT.lib.name)
					lastAct.IT = i
					break
		if not lastAct.IT.data.lib.charge:
			currentChar.group.inventory.takeConsumable(lastAct.IT)
		else:
			lastAct.IT.charge -= lastAct.IT.data.lib.chargeUse[lastAct.IT.level]
	exit(currentChar.battle.lastAction)

func _on_WeaponMenu_selection(x) -> void:
	print("[BATTLECONTROLS][_on_WeaponMenu_selection]\n\t%s" % str(x))
	currentPanel = self
	action = x

func _on_SkillMenu_selection(x) -> void:
	print("[BATTLECONTROLS][_on_SkillMenu_selection]\n\t%s" % str(x))
	currentPanel = self
	action = x

func _on_ItemMenu_selection(x) -> void:
	print("[BATTLECONTROLS][_on_ItemMenu_selection]\n\t%s" % str(x))
	currentPanel = self
	if x != null: # Consume item here.
		if not x.IT.data.lib.charge:
			currentChar.group.inventory.takeConsumable(x.IT)
		else:
			x.IT.data.charge -= x.IT.data.lib.chargeUse[x.IT.data.level]
	action = x

func _on_OverMenu_selection(x) -> void:
	print("[BATTLECONTROLS][_on_OverMenu_selection]\n\t%s" % str(x))
	currentPanel = self
	action = x
