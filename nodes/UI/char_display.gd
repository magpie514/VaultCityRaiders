extends Panel
signal select(x)
signal display_info(x)
signal hide_info

var _dmgNum = preload("res://nodes/UI/damage_numbers.tscn")
var _miscMsg = preload("res://nodes/UI/battle/misc_message.tscn")
export(Color) var dmgCountColor = "ff9444"


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
		add_child(d)
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
	$DMG.hide()
	$DMG.add_color_override("font_color", dmgCountColor)
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
	$DMG.text = ""
	lastVital = chr.HP
	$DMG.hide()
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

func highlight(b):
	style.highlight(b)
	if b:
		if action != null:
			$Action.hide()
	else:
		if action != null:
			$Action.show()

func charge(b : bool = false):
	$Charge.emitting = b
	$Charge.self_modulate = Color(chr.energyColor)

func updateAD(x:int) -> void:
	if chr.battle != null:
		$AD.value = x

func update():
	if chr != null:
		var vital = int(chr.HP)
		var vitalN = chr.getHealthN()
		var vitalDiff = lastVital - vital
		if chr.battle != null:
			updateAD(chr.battle.AD)
			if chr.battle.guard > 0:
				$Guard.show()
				$ComplexBar/GuardBlock.show()
				$Guard.text = str(chr.battle.guard)
			else:
				$ComplexBar/GuardBlock.hide()
				$Guard.hide()
		else:
			$ComplexBar/GuardBlock.hide()
			$Guard.hide()

		if vitalN < 0.15:			blink = -1
		elif blink == -1:			blink = 0

		style.fromStatus(chr.status)
		$Status.text = core.skill.statusInfo[chr.status].short


		$Name.text = chr.name
		$HP.text = str(vital)
		$ComplexBar.value = vitalN
		if vital != lastVital:
			$DMG.text = str(abs(vitalDiff))
			if vitalDiff < 0:
				$DMG.add_color_override("font_color", "44ff94")
			else:
				$DMG.add_color_override("font_color", "ff9444")
			$DMG.show()

func _ready():
	shakeTimer = 0
	origPosition = rect_position
	set_process(true)

func selectable(f):
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

func _on_Button_pressed():
	emit_signal("select", chr)
	$Button.hide()


func _on_Button_mouse_entered():
	highlight(true)


func _on_Button_mouse_exited():
	highlight(false)


func _on_CharDisplay_mouse_entered():
	emit_signal("display_info", chr, 0)


func _on_CharDisplay_mouse_exited():
	emit_signal("hide_info")
