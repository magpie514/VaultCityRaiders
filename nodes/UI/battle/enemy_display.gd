extends Panel

signal display_info(x)
signal hide_info

onready var tween = $Tween
var _dmgNum = preload("res://nodes/UI/damage_numbers.tscn")
var _miscMsg = preload("res://nodes/UI/battle/misc_message.tscn")
var chr = null
var style = core._charPanel.new(self, "res://resources/tres/char_display.tres", "custom_styles/panel")
var fade = 1.0
var damageQueue = []
var damageDelay = 0
var effectHook #Set from sprite init

func init(c):
	chr = c
	$Label.text = chr.name
	update()
	set_process(true)

func stop():
	set_process(false)
	queue_free()

func popDamageNums():
	if damageQueue.size() > 0:
		var v = damageQueue.pop_front()
		var d = _dmgNum.instance()
		$Position2D.add_child(d)
		d.init(v)
		damageDelay = 32

func fadeTo(x, time):
	if tween == null: return
	if tween.is_active():
		tween.stop(self)
	x = clamp(x, 0.0, 1.0)
	tween.interpolate_property(self, "fade", fade, x, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	fade = x
	tween.start()

func damage(x):
	update()
	damageQueue.push_back(x)
	if damageDelay == 0:
		damageDelay = 1

func message(msg, data, color):
	$MessageDisplay.add(msg, data, color)

func resize(v):
	rect_size.x = v.x
	$Label.rect_size.x = v.x
	$Button.rect_size.x = v.x
	$ComplexBar.rect_size.x = rect_size.x * 0.8

func updateAD(x:int) -> void:
	if chr.battle != null:
		$AD.value = x

func update():
	$ComplexBar.value = chr.getHealthN()
	style.fromStatus(chr.status)
	$Status.text = core.skill.statusInfo[chr.status].short
	updateAD(chr.battle.AD)

func _process(delta):
	modulate.a = fade
	if damageDelay > 0:
		damageDelay -= 1
		if damageDelay == 0:
			popDamageNums()

func _on_EnemyDisplay_mouse_entered():
	emit_signal("display_info", chr, 1)

func _on_EnemyDisplay_mouse_exited():
	emit_signal("hide_info")
