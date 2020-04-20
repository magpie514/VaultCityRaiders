extends Node2D

onready var effectHook:Node     = $EffectHook
onready var effectorHolder:Node = $EffectHook/EffectorHolder
onready var player:Node         = $AnimationPlayer
onready var sprite:Node         = $SpriteHook/Sprite
onready var chargeEmitter:Node  = $SpriteHook/Charge
onready var condDisplay:Node    = $SpriteHook/Position2D/ConditionDisplay

var lock:bool      = false
var chr            = null
var shakeTimer:int = 0
var origPosition:Vector2

func init(spr, C, slot) -> void:
	if lock: return
	chr = C
	sprite.texture = load(spr)
	lock = false
	begin()

func begin() -> void:
	if lock: return
	print("[ENEMY_SPRITE_SIMPLE] Begin animation starting for %s(%d)." % [chr.name, chr.slot])
	player.play("BEGIN")

func act() -> void:
	if lock: return
	print("[ENEMY_SPRITE_SIMPLE] Action animation starting for %s(%d)." % [chr.name, chr.slot])
	player.play("ACTION")

func defeat() -> void:
	if lock: return
	lock = true
	print("[ENEMY_SPRITE_SIMPLE] Defeat animation starting for %s(%d)." % [chr.name, chr.slot])
	player.play("DEFEAT")
	chargeEmitter.emitting = false

func damage() -> void:
	if lock: return
	print("[ENEMY_SPRITE_SIMPLE] Damage animation starting for %s(%d)." % [chr.name, chr.slot])
	player.play("DAMAGE")

func damageShake() -> void:
	if shakeTimer == 0:
		origPosition = sprite.position
		shakeTimer = 20
	else: shakeTimer = 20
	set_process(true)

func charge(ok:bool = false) -> void:
	if lock:return
	if not ok:
		chargeEmitter.emitting = false
	else:
		if not lock: player.play("CHARGE")
		chargeEmitter.emitting = true
		chargeEmitter.self_modulate = Color(chr.energyColor)

func clearEffectors() -> void:
	for i in effectorHolder.get_children():
		i.queue_free()

func _process(delta:float) -> void:
	if shakeTimer > 0:
		sprite.position = origPosition + Vector2(0, (-6 + randi() % 12))
		shakeTimer -= 1
		if shakeTimer == 0:
			sprite.position = origPosition
			set_process(false)

# Signals #####################################################################
func _on_AnimationPlayer_animation_finished(anim_name:String) -> void:
	print("[ENEMY_SPRITE_SIMPLE: %s:%s] " % [anim_name, chr.name])
	if anim_name == "DEFEAT":
		print("[ENEMY_SPRITE_SIMPLE] Defeat animation finished for %s(%d). Freeing." % [chr.name, chr.slot])
		chargeEmitter.emitting = false
		chr = null
		queue_free()
