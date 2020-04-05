extends Panel
signal display_info(x)
signal hide_info

var _dmgNum = preload("res://nodes/UI/damage_numbers.tscn")
var _miscMsg = preload("res://nodes/UI/battle/misc_message.tscn")

onready var effectHook = get_node("EffectHook")
onready var LookAtMePanel = get_node("EffectHook/LookAtMePanel")

var chr = null
var origPosition = Vector2()
var lastVital = int()
var shakeTimer = 0
var blink = 0
var damageDelay = 0
var _theme = "normal"
var damageQueue = []
var action = null
var style = core._charPanel.new(self, "res://resources/tres/char_display.tres", "custom_styles/panel")

func popDamageNums():
	if damageQueue.size() > 0:
		var v = damageQueue.pop_front()
		var d = _dmgNum.instance()
		effectHook.add_child(d)
		d.init(v)
		damageDelay = 32

func damage(x):
	update()
	damageQueue.push_back(x)
	if damageDelay == 0:
		damageDelay = 1
	var n = 0
	for i in x:
		if typeof(i) == TYPE_ARRAY:
			n += i[0]
	if n > 0:
		damageShake()

func message(msg, data, color):
	$MessageDisplay.add(msg, data, color)


func init(C):
	chr = C
	$Action.hide()
	shakeTimer = 0
	resetDamageCount()
	update()

func damageShake():
	if shakeTimer == 0:
		origPosition = Vector2(rect_position.x, rect_position.y)
		shakeTimer = 20
		blink = 20
	else:
		shakeTimer = 20
		blink = 20

func _process(delta):
	if shakeTimer > 0:
		rect_position = Vector2(origPosition.x, origPosition.y + (-6 + randi() % 12))
		shakeTimer -= 1
		if shakeTimer == 0:
			rect_position = Vector2(origPosition.x, origPosition.y)
	if blink > 0 or blink == -1:
		style.setTemp("damage" if OS.get_ticks_msec() % 2 else _theme)
		if blink > 0:
			blink -= 1
		if blink == 0:
			style.setTemp(_theme)
	if damageDelay > 0 && blink == 0:
		damageDelay -= 1
		if damageDelay == 0:
			popDamageNums()

func resetDamageCount():
	lastVital = chr.HP
	$Action.hide()
	action = null

func setActionText(act):
	if act == null:
		$Action.hide()
		$Action.text = ""
		updateAD(chr.battle.AD)
		action = null
		return
	var S = null
	if act.override != null:
		S = act.override
		print("[BATTLE STATE][addAction] Using override %s" % S.name)
	else: S = act.skill
	var target = ""
	if act.target != null:
		#FIXME: When repeating actions, act.target might be empty. Check for array size for retargetting, can cause errors.
		match(S.target[act.level]):
			core.skill.TARGET_SELF:
				target = "Self"
			core.skill.TARGET_ROW:
				target = "%s row" % [ "Party" if S.targetGroup == core.skill.TARGET_GROUP_ALLY else "Enemy" ]
			core.skill.TARGET_ALL:
				target = "All %s" % [ "party" if S.targetGroup == core.skill.TARGET_GROUP_ALLY else "enemy" ]
			_:
				if act.target[0] != null:
					target = act.target[0].name
	$Action.text = "%s\n%s" % [S.name if act.IT == null else act.IT.data.lib.name, target]
	$Action.show()
	if S.chargeAnim[act.level] != 0: charge(true)
	if S.initAD[act.level] != 100: updateAD(S.initAD[act.level])
	action = true

func highlight(b) -> void: #Highlights this character to show it's acting or choosing actions.
	style.highlight(b)
	if b:
		if action != null: $Action.hide() #Hide action display.
		#Pulsing indicator for improved visual feedback.
		LookAtMePanel.show()
		LookAtMePanel.pulse()
		LookAtMePanel.set_process(true)
	else:
		if action != null: $Action.show() #Show action display.
		#Hide the pulsing indicator so it stops processing.
		LookAtMePanel.hide()
		LookAtMePanel.set_process(false)
		LookAtMePanel.get_node("Tween").stop(LookAtMePanel)

func charge(b:bool = false) -> void: #Charge effect
	$EffectHook/Charge.emitting = b
	$EffectHook/Charge.self_modulate = Color(chr.energyColor)

func updateAD(x:int) -> void: #Update Active Defense display.
	if chr.battle != null:
		$AD.value = x

func updateDEbar(x:int) -> void: #Update Damage Effect display.
	if x > 0:
		$ComplexBar.secondary = true
		var mhp:int = chr.maxHealth()
		$ComplexBar.value2 = (x as float / mhp as float)
	else:
		$ComplexBar.secondary = false

func update() -> void:
	if chr != null:
		var vital = int(chr.HP)
		var vitalN = chr.getHealthN()
		var vitalDiff = lastVital - vital
		if chr.battle != null: #Show battle-only stuff.
			updateAD(chr.battle.AD)
			updateDEbar(chr.calculateDamageEffects())
			if chr.battle.guard > 0 or chr.battle.absoluteGuard > 0: #Show Guard indicator.
				$Guard.show()
				$ComplexBar.guard = true
				if chr.battle.absoluteGuard > 0:
					$Guard.text = str(chr.battle.absoluteGuard)
				else:
					$Guard.text = str(chr.battle.guard)
			else:
				$ComplexBar.guard = false
				$ComplexBar/Guard.hide()
		else:
			$ComplexBar.guard = false
			$ComplexBar/Guard.hide()

		#Make the panel blink if health is under 15%.
		if vitalN < 0.15 and vitalN > 0.0: blink = -1
		elif blink == -1:                  blink = 0


		#Set colors from active condition.
		style.fromStatus(chr.condition)
		$Status.text = core.skill.conditionInfo[chr.condition].short

		$Name.text = chr.name
		$ComplexBar/HP.text = str("%03d" % vital)
		$ComplexBar.value = vitalN
		$ComplexBar/DMG.text = str("%03d" % chr.EP)

func _ready() -> void:
	shakeTimer = 0
	origPosition = rect_position
	set_process(true)

func selectable(f) -> void:
	if f:
		style.set("select")
		$Button.show()
		if action != null:
			$Action.hide()
	else:
		$Button.hide()
		update()
		if action != null:
			$Action.show()

func _on_Button_mouse_entered() -> void:
	highlight(true)

func _on_Button_mouse_exited() -> void:
	highlight(false)

func _on_CharDisplay_mouse_entered() -> void:
	emit_signal("display_info", chr, 0)

func _on_CharDisplay_mouse_exited() -> void:
	emit_signal("hide_info")
