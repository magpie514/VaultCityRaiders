extends Panel

signal display_info(x)
signal hide_info

onready var tween:Tween = $Tween
var style               = core._charPanel.new(self, "res://resources/tres/char_display.tres", "custom_styles/panel")
var chr                 = null
var fade:float          = 1.0
var effectHook:Node #Set from sprite init

func init(c) -> void:
	chr = c
	$Label.text = chr.name
	#effectHook = c.sprite.effectHook
	update()
	show()
	set_process(true)

func stop() -> void:
	hide()
	#set_process(false)

func highlight(x):
	pass

func damage():
	update()

func message(msg, color) -> void:
	chr.messageNode.add(msg, color)

func resize(v):
	rect_size.x = v.x
	$Label.rect_size.x = v.x
	$Button.rect_size.x = v.x
	$ComplexBar.rect_size.x = rect_size.x * 0.8

func updateDEbar(x:int) -> void: #Update Damage Effect display.
	if x > 0:
		$ComplexBar.secondary = true
		var mhp:int = chr.maxHealth()
		$ComplexBar.value2 = (x as float / mhp as float)
	else:
		$ComplexBar.secondary = false

func updateAD(x:int) -> void:
	if chr.battle != null:
		$AD.value = x

func update():
	$ComplexBar.value = chr.getHealthN()
	style.fromStatus(chr.condition)
	$Status.text = core.stats.CONDITION_DATA[chr.condition].short
	updateAD(chr.battle.AD)
	updateDEbar(chr.calculateDamageEffects())

func _process(delta:float) -> void:
	modulate.a = fade


func _on_EnemyDisplay_mouse_entered():
	if chr != null:
		emit_signal("display_info", chr, 1)

func _on_EnemyDisplay_mouse_exited():
	emit_signal("hide_info")
