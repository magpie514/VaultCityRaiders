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

func setup(C, place, node):
	parent = node
	$Main/OverBar.value = C.getOverN()
	$Main/WeaponPanel.init(C)
	currentChar = C
	$Main/Name.text = C.name
	if C.battle.chain > 0: #Show chain counter if pertinent.
		$Main/Chain/Label.text = str(C.battle.chain)
		$Main/Chain.show()
	else:
		$Main/Chain.hide()
	show()
	$Main.show()
	if place == 0:
		$Main/Switch.show()
		$Main/Macro.show()
		$Main/Talk.show()
		$Main/Back.hide()
	else:
		$Main/Switch.hide()
		$Main/Macro.hide()
		$Main/Talk.hide()
		$Main/Back.show()
	if C.battle.lastAction == null:
		$Main/Repeat.disabled = true
	else:
		$Main/Repeat.disabled = false
		var RS = C.battle.lastAction.skill if C.battle.lastAction.IT == null else C.battle.lastAction.IT
		$Main/Repeat.text = str("Repeat %s" % RS.name)

func _process(delta: float) -> void: #Just a quick hack for now
	if $Main.visible:
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


func exit(val):
	closeAll()
	emit_signal("finished", val)

func closeAll():
	$WeaponMenu.finish()
	$SkillMenu.finish()
	$ItemMenu.finish()
	$TargetPanel.clear()

func _on_Weapon_pressed(slot:int) -> void:
	var display = null
	var W = null
	$Main.hide()
	$WeaponMenu.init(currentChar, slot)
	action = null
	yield($WeaponMenu, "selection") #This receives the menu's selection() signal with the skill and target.
	if action != null: exit(action)
	else: $Main.show()

func _on_Skill_pressed():
	var display = null
	var S = null
	$Main.hide()
	$SkillMenu.init(currentChar)
	action = null
	yield($SkillMenu, "selection") #This receives the menu's selection() signal with the skill and target.
	if action != null: exit(action)
	else: $Main.show()

func _on_Defend_pressed():#
	var result = state.Action.new(state.ACT_DEFEND)
	result.skillTid = ["core", "defend"]
	result.skill = core.lib.skill.getIndex(result.skillTid)
	result.level = 1
	result.user = currentChar
	result.target = [currentChar]
	result.WP = currentChar.currentWeapon
	exit(result)

func _on_Item_pressed():
	var display = null
	var S = null
	$Main.hide()
	$ItemMenu.init(currentChar)
	action = null
	yield($ItemMenu, "selection") #This receives the menu's selection() signal with the skill and target.
	if action != null:
		exit(action)
	else:
		$Main.show()

func _on_Over_pressed():
	exit([state.ACT_OVER])

func _on_Run_pressed():#
	exit([state.ACT_RUN])

func _on_Macro_pressed():
	pass # replace with function body

func _on_Back_pressed():
	exit([-1])

func _on_Switch_pressed():
	pass # replace with function body

func _on_Repeat_pressed() -> void:
	var lastAct = currentChar.battle.lastAction
	if lastAct.skill.targetGroup == skill.TARGET_GROUP_ENEMY:
		var p = currentChar.group.versus.getAllTargets(lastAct.skill)
		for i in lastAct.target:
			if not i in p:
				print("[BATTLECONTROLS][_on_Repeat_pressed] targetting inactive target.")
				lastAct.target.erase(i)
	exit(currentChar.battle.lastAction)

func _on_WeaponMenu_selection(x) -> void:
	print("[BATTLECONTROLS][_on_WeaponMenu_selection]\n\t%s" % str(x))
	action = x

func _on_SkillMenu_selection(x) -> void:
	print("[BATTLECONTROLS][_on_SkillMenu_selection]\n\t%s" % str(x))
	action = x

func _on_ItemMenu_selection(x) -> void:
	print("[BATTLECONTROLS][_on_ItemMenu_selection]\n\t%s" % str(x))
	action = x
