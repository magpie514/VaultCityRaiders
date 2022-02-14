extends Node2D
signal anim_done

export(int, 'None', 'User', 'Target')  var focus:int        = 0 setget setFocus
export(int, 'None', 'Skill', 'Global') var switchCamera:int = 0 setget setCamera
export(float) var globalCameraShake:float = 0.0
export(float) var localCameraShake:float  = 0.0
export(bool)  var showOverlay1:bool = false setget setShowOverlay1
export(bool)  var showOverlay2:bool = false setget setShowOverlay2
export(Color) var overlay1 = Color(0.0, 0.0, 0.0, 0.0) setget setOverlay1
export(Color) var overlay2 = Color(0.0, 0.0, 0.0, 0.0) setget setOverlay2
export(Color) var underlay = Color(0.0, 0.0, 0.0, 0.0) setget setUnderlay

onready var user:Position2D     = $DummyUser
onready var target:Position2D   = $DummyTarget
onready var cam:Camera2D        = $Camera2D
onready var camDummy:Position2D = $CameraDummy
onready var localOverlay:Sprite = $Overlay/Overlay
onready var speedControl:Array  = get_tree().get_nodes_in_group("speed_control") #Nodes that require speed adjustments.

var state:Array = [0,0] #Status for background overlay and underlay to restore at exit.

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var origin:Vector2 = Vector2(0,0)
	match focus:
		1: origin = user.global_position
		2: origin = target.global_position

	cam.global_position = camDummy.position + origin
	if localCameraShake > 0.1:
		cam.offset = Vector2(randf() * localCameraShake, randf() * localCameraShake)

func play(spd:float, mirror:bool = false) -> void:
	var n = get_tree().get_nodes_in_group("speed_control")
	state[0] = core.battle.background.overlay.modulate
	state[1] = core.battle.background.underlay.modulate
	if mirror: scale.x = -1.0
	$AnimationPlayer.playback_speed = spd
	$Particles2D.speed_scale        = spd
	$AnimationPlayer.play("ACTION")

func done() -> void:
	emit_signal("anim_done")

func pos(x) -> void:
	global_position = x

func setGlobalCameraShake(x:float) -> void:
	globalCameraShake = x
	core.battle.cam.shake = globalCameraShake

func setFocus(on:int) -> void:
	focus = on
	match focus:
		0: return
		1: core.battle.cam.focusAnchor(user, true)
		2: core.battle.cam.focusAnchor(target)

func setCamera(on:int) -> void:
	if not cam: return
	switchCamera = on
	match switchCamera:
		0: return
		1:
			cam.global_position = core.battle.cam.global_position
			cam.current = true
		2: core.battle.cam.current = true

func setOverlay1(to:Color) -> void:
	overlay1 = to
	core.battle.background.overlay.modulate = overlay1

func setUnderlay(to:Color) -> void:
	underlay = to
	core.battle.background.underlay.modulate = underlay

func setOverlay2(to:Color) -> void:
	overlay2 = to
	localOverlay.modulate = overlay2

func setShowOverlay1(x:bool) -> void:
	showOverlay1 = x
	core.battle.background.overlay.visible = showOverlay1

func setShowOverlay2(x:bool) -> void:
	showOverlay2 = x
	localOverlay.visible = showOverlay2

func _on_AnimationPlayer_animation_finished(x) -> void:
	#Restore state of layer effects.
	core.battle.background.overlay.modulate  = state[0]
	core.battle.background.underlay.modulate = state[1]
	core.battle.background.overlay.hide()
	emit_signal("anim_done")
	queue_free()
