extends Node2D

onready var effectHook = get_node("EffectHook")

var lock : bool = false
var chr = null
var origPosition : Vector2
var shakeTimer : int = 0



func init(spr, C, slot):
	if lock: return
	chr = C
	$Sprite.texture = load(spr)
	lock = false
	if slot < 5:
		scale = Vector2(1.2, 1.2)
	else:
		modulate.v = 0.8
	chr.display.effectHook = effectHook #Set effect hook for associated display.
	begin()

func begin():
	if lock: return
	print("[ENEMY_SPRITE_SIMPLE] Begin animation starting for %s(%d)." % [chr.name, chr.slot])
	$AnimationPlayer.play("BEGIN")

func act():
	if lock: return
	$AnimationPlayer.play("ACTION")
	print("[ENEMY_SPRITE_SIMPLE] Action animation starting for %s(%d)." % [chr.name, chr.slot])

func defeat():
	if lock: return
	lock = true
	$AnimationPlayer.play("DEFEAT")
	$Charge.emitting = false
	print("[ENEMY_SPRITE_SIMPLE] Defeat animation starting for %s(%d)." % [chr.name, chr.slot])

func damage():
	if lock: return
	$AnimationPlayer.play("DAMAGE")
	print("[ENEMY_SPRITE_SIMPLE] Damage animation starting for %s(%d)." % [chr.name, chr.slot])

func damageShake():
	if shakeTimer == 0:
		origPosition = $Sprite.position
		shakeTimer = 20
	else:
		shakeTimer = 20
	set_process(true)

func charge(ok : bool = false):
	if lock:return
	if not ok:
		$Charge.emitting = false
	else:
		if not lock: $AnimationPlayer.play("CHARGE")
		$Charge.emitting = true
		$Charge.self_modulate = Color(chr.energyColor)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	print("[ENEMY_SPRITE_SIMPLE: %s:%s] " % [anim_name, chr.name])
	if anim_name == "DEFEAT":
		print("[ENEMY_SPRITE_SIMPLE] Defeat animation finished for %s(%d). Freeing." % [chr.name, chr.slot])
		chr = null
		queue_free()

func _process(delta:float) -> void:
	if shakeTimer > 0:
		$Sprite.position = origPosition + Vector2(0, (-6 + randi() % 12))
		shakeTimer -= 1
		if shakeTimer == 0:
			$Sprite.position = origPosition
			set_process(false)
