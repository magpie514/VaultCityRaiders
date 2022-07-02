#Animation control node
# Groups:
# speed_control      : Add to any elements that can change speed. Particle emitters, animated sprites, etc.
# color_control      : Add to any elements that can be given an user's custom color.
# fit_to_screen_size : 1x1 elements that get scaled to screen size.

extends Node2D
signal anim_done

const DRAMATIC_SLOWDOWN = 0.05
#export(bool)  var showOverlay:bool = false setget setShowOverlay
export(bool) var slowdown:bool      = false setget setSlowdown
onready var puppetUser:Position2D   = $PuppetUser
onready var puppetTarget:Position2D = $PuppetTarget
onready var cam:Camera2D            = $LocalCamera
onready var puppetCam:Position2D    = $PuppetCamera
onready var player:AnimationPlayer  = $AnimationPlayer
onready var cutinSpace:CanvasLayer  = $CutInSpace

var initialized:bool = false
var user             = null
var target           = null
var initSpeed:float  = 1.0

func _ready() -> void:
	set_process(false)
	for i in get_tree().get_nodes_in_group('fit_to_screen_size'): #Resize screen obscurers so they fit the screen size right.
		i.position = Vector2(0,0)      #Reset position just in case they got moved.
		i.scale = OS.get_screen_size() #They are 1x1 textures so just scaling will get the right size.

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
	$CutInSpace/FakeUser.init(user)
	$CutInSpace/FakeTarget.init(target)
	if mirror: scale.x = -1.0
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
	set_speed(spd)
	set_process(true)
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
	$CutInSpace/FakeTarget.set_process(false)
	$CutInSpace/FakeUser.set_process(false)
	#Reset user/target positions.
	user.global_position   = user.get_parent().global_position
	user.reset()
	target.global_position = target.get_parent().global_position
	target.reset()
	emit_signal("anim_done")
	queue_free()

func setSlowdown(x:bool) -> void:
	slowdown = x
	if initialized:
		if x: set_speed(DRAMATIC_SLOWDOWN)
		else: set_speed(initSpeed)

