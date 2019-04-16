extends Node2D

var lock : bool = false
var chr = null

func init(spr, C, slot):
	chr = C
	$AnimationPlayer.play("BEGIN")
	$Sprite.texture = load(spr)
	lock = false
	if slot < 5:
		scale = Vector2(1.2, 1.2)
	else:
		modulate.v = 0.8



func act():
	if lock: return
	$AnimationPlayer.play("ACTION")

func defeat():
	if lock: return
	lock = true
	$AnimationPlayer.play("DEFEAT")

func damage():
	if lock: return
	$AnimationPlayer.play("DAMAGE")

func charge(ok : bool = false):
	if not ok:
		$Charge.emitting = false
	else:
		if not lock: $AnimationPlayer.play("CHARGE")
		$Charge.emitting = true
		$Charge.self_modulate = Color(chr.energyColor)
