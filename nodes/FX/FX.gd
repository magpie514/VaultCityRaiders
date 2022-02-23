#Animation control node
# Groups:
# speed_control: Add to any elements that can change speed. Particle emitters, animated sprites, etc.
# color_control: Add to any elements that can be given an user's custom color.
extends Node2D
signal anim_done

const DRAMATIC_SLOWDOWN = 0.05
#export(bool)  var showOverlay:bool = false setget setShowOverlay
export(bool) var slowdown:bool = false setget setSlowdown

onready var puppetUser:Position2D   = $PuppetUser
onready var puppetTarget:Position2D = $PuppetTarget
onready var cam:Camera2D            = $Camera2D
onready var puppetCam:Position2D    = $PuppetCamera
onready var localOverlay:Sprite     = $Overlay/Overlay
onready var player:AnimationPlayer  = $AnimationPlayer

var initialized:bool = false
var user   = null
var target = null
var initSpeed:float = 1.0

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	pass

func init(user_:Node2D, target_:Node2D, mirror:bool = false) -> void:
	initialized = true
	var anim:Animation = player.get_animation('ACTION')
	var track:int = 0
	var pos:Vector2
	user   = user_
	target = target_
	#Initialize puppet nodes.
	puppetUser.init(user)
	puppetTarget.init(target)
	puppetCam.init(core.battle.cam)
	$Overlay/FakeUser.init(user.sprite)
	$Overlay/FakeTarget.init(target.sprite)
	if mirror: scale.x = -1.0
	#global_position = target.global_position
	#puppetTarget.position      = to_local(target.sprite.global_position)
	#puppetUser.position        = to_local(user.sprite.global_position)

	#cam.global_position       = user.global_position

	#If a change in position is detected, add keys at the start and at the end of the track.
	#NOTE: Change to something else? Like a detection of capture and position?
#	track = anim.find_track("PuppetUser:position")
#	if track != -1:
#		pos = to_local(user.global_position)
#		for i in range(anim.track_get_key_count(track)):
#			var tmp = anim.track_get_key_value(track, i)
#			core.aprint(anim.track_get_key_value(track, i), core.ANSI_YELLOW)
#		anim.track_insert_key(track, 0.0, pos)
#		anim.track_insert_key(track, anim.get_length(), pos)


func play(spd:float, mirror:bool = false) -> void:
	initSpeed = spd
	set_process(true)
	set_speed(spd)
	player.play("ACTION")

func set_speed(spd:float = 1.0) -> void:
	var val:float = initSpeed * spd
	var n = get_tree().get_nodes_in_group("speed_control")
	for i in n:
		match i.get_class():
			'Particles2D'    : i.speed_scale    = val
			'AnimationPlayer': i.playback_speed = val

func _on_animation_finished(x) -> void:
	#Restore state of layer effects.
	set_process(false)
	puppetCam.set_process(false)
	puppetUser.set_process(false)
	puppetTarget.set_process(false)
	#Reset user/target positions.
	user.global_position   = user.get_parent().global_position
	target.global_position = target.get_parent().global_position
	emit_signal("anim_done")
	queue_free()

func setSlowdown(x:bool) -> void:
	slowdown = x
	if initialized:
		if x: set_speed(DRAMATIC_SLOWDOWN)
		else: set_speed(initSpeed)
