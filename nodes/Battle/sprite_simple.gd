#Basic battle sprite.
extends Node2D

const AfterImage = preload("res://nodes/FX/afterimage.tscn")

onready var effectHook:Node     = $EffectHook
onready var effectorHolder:Node = $EffectHook/EffectorHolder
onready var player:Node         = $AnimationPlayer
onready var sprite:Node         = $SpriteHook/Sprite
onready var chargeEmitter:Node  = $EffectHook/Charge
onready var chargeEmitter2:Node = $EffectHook/Charge/ChargeBack
onready var glows:Sprite        = $SpriteHook/Sprite/Glows
onready var condDisplay:Node    = $ConditionDisplay
onready var parent:Node         = get_parent()

var lock:bool      = false  #FIXME: This remains from the old plans. Might need to take it out.
var afterimage:bool = true #Emit afterimages.
var chr            = null   #Reference to the character assigned to this sprite.
var shakeTimer:int = 0
var shake:float = 0.0
var origPosition:Vector2    #Original position. TODO: Review, might not be needed anymore.
var frames:Dictionary       #Frame data.

func _ready() -> void:
	var g:Gradient = Gradient.new() #Set a gradient for particle effects.
	g.add_point(0.5, "#888888") #This is the point we modify for personal particle colors and whatnot.
	g.set_color(0,   "#000649") #Dark blue.
	chargeEmitter.process_material.color_ramp.gradient = g
	#Reset these in case the animation player left a mess.
	glows.modulate      = Color(1.0,1.0,1.0,1.0)
	glows.self_modulate = Color(1.0,1.0,1.0,1.0)
	afterimage = false

func init(path:String, C, slot) -> void:
	if lock: return #FIXME: Is this still needed? I don't think it is.
	chr = C

	#Load frame data json.
	var data:Dictionary = core.loadJSON(path, 'res://resources/images/Char/debug.json')
	if data.empty(): core.aprint("[SPRITE_SIMPLE][init] ??????", core.ANSI_RED2)
	else           : frames = loadSprites(data)
	lock = false

	#Add passive skill effectors.
	var effector_check = C.getActiveSkills()
	if effector_check != null:
		for i in effector_check:
			if i[0].category == core.skill.CAT_PASSIVE:
				if i[0].effector:
					core.battle.displayManager.addEffector(C, i[0].effector, i[0], 2)

	#Set emitters to personal colors.
	chargeEmitter.process_material.color_ramp.gradient.set_color(1, C.energyColor)

	#Set default frame.
	setFrame('IDLE')
	begin()

func _process(delta:float) -> void:
	if shake > 0.1 and sprite.visible:
		sprite.offset = Vector2(randf() * shake, randf() * shake)
		glows.offset = sprite.offset #Looks terrible without.
#	if shakeTimer > 0:
#		sprite.offset = Vector2(0.0, (-6.0 + randf() * 12))
#		shakeTimer -= 1
#		if shakeTimer == 0:
#			sprite.offset = Vector2(0,0)
#			set_process(false)
	if afterimage and sprite.visible:
		var AF = AfterImage.instance()
		core.battle.background.add_child(AF)
		AF.init(sprite)

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
	charge(false)

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

func charge(ok:bool = false) -> void: #Sets a charge effect.
	if lock:return
	if not ok:
		chargeEmitter.emitting  = false
		chargeEmitter2.emitting = false
	else:
		if not lock: player.play("CHARGE")
		chargeEmitter.emitting  = true
		chargeEmitter2.emitting = true

func clearEffectors() -> void: #Removes all active effectors.
	for i in effectorHolder.get_children():
		i.check_deletion()

func setFrame(which:String) -> void:
	which = which.to_upper() #ALLCAPS!!!
	if not which in frames:
		which = "IDLE" #If the frame doesn't exist default to idle.
	var r = frames[which] #If frame exists, switch to it, and set up the region.
	sprite.region_enabled = true
	sprite.region_rect    = Rect2(r[0], r[1], r[2], r[3])
	sprite.scale          = Vector2(frames.scale[0], frames.scale[1])
	$SpriteHook.position.y = floor(-(r[3] * frames.scale[1] / 2.0)) + 20
	$EffectHook.position.y = $SpriteHook.position.y
	if ("%s_GLOWS" % which) in frames: #Search for a <frame>_GLOWS entry. If it exists set the glows node for it.
		r                    = frames[("%s_GLOWS" % which)] #Recycle this var.
		glows.visible        = true
		glows.region_enabled = true
		glows.region_rect    = Rect2(r[0], r[1], r[2], r[3])
		glows.position       = Vector2(r[4], float(r[5]))
		glows.intensity      = r[6]
		glows.self_modulate  = r[7]
	else:
		glows.visible = false #The glows sprite won't process if invisible.



func loadSprites(d:Dictionary) -> Dictionary:
	var result:Dictionary = {
		atlas = "res://resources/images/core.png",
		scale = [1.0, 1.0],
		IDLE = [315,16,317,460]
	}
	if 'atlas' in d:
		var s:String = str(d['atlas'])
		print("Checking for file %s" % s)
		if File.new().file_exists(s):
			result.atlas = str(s)
		else:
			print("File %s not found. Using placeholder." % s)
	print("Atlas:", result.atlas)
	sprite.texture = load(result.atlas)

	for i in ['IDLE', 'BEGIN', 'ACTION', 'CHARGE', 'DASH', 'GUARD', 'DAMAGE', 'DEFEAT']: #Load the standard frames.
		result[i] = [0,0,0,0] #Preinitialize an array.
		if i in d: #Check if the frame is defined.
			if d[i] is Array and d[i].size() == 4: #Must be a 4 value array.
				for j in range(4):
					result[i][j] = int(d[i][j])
		else:
			if 'IDLE' in result: #IDLE *should* be already defined in the result definition, so copy it as a last resort.
				print("Frame %s undefined, copying IDLE values." % i)
				for j in range(4): result[i][j] = result.IDLE[j]
	for i in ['IDLE_GLOWS']: #Load extras.
		if i in d:
			#0-3: Rect parameters. 4-5: XY Offset. 6: Intensity. 7: Color.
			result[i] = [0,0,0,0,0,0,0.0,"#00000000"]
			if d[i] is Array and d[i].size() == 8: #Must be a 6 value array.
				for j in range(6):
					result[i][j] = int(d[i][j])
				result[i][6] = float(d[i][6])
				result[i][7] = str(d[i][7])
	if 'scale' in d: #If there's a scale value, use it.
		if d.scale is Array:
			if d.scale.size() == 2: #Formatted as XY values, load both.
				result.scale[0] = float(d.scale[0])
				result.scale[1] = float(d.scale[1])
		if d.scale is float: #Formatted as single value, XY are assumed to be equal.
			result.scale[0] = float(d.scale)
			result.scale[1] = float(d.scale)

	return result


# Signals #####################################################################
func _on_AnimationPlayer_animation_finished(anim_name:String) -> void:
	print("[ENEMY_SPRITE_SIMPLE: %s:%s] " % [anim_name, chr.name])
	if anim_name == "DEFEAT":
		print("[ENEMY_SPRITE_SIMPLE] Defeat animation finished for %s(%d). Freeing." % [chr.name, chr.slot])
		chargeEmitter.emitting = false
		chr = null
		queue_free()
