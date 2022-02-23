extends Position2D

enum Focus { NONE, USER, TARGET }

export(float) var shake:float = 0.0
export(bool) var capture:bool = false
export(Focus) var track:int = Focus.NONE setget setTracking
export(Focus) var jump:int  = Focus.NONE setget setJump
var cam:Camera2D

var user:Node2D
var target:Node2D
var initialized:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)

func init(cam_:Camera2D):
	var parent:Node2D = get_parent()
	core.aprint(cam_, core.ANSI_YELLOW2)
	cam    = cam_
	global_position = cam.global_position
	cam.smoothing_enabled = false
	user   = parent.user
	target = parent.target
	initialized = true
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if initialized:
		if shake > 0.1:
			cam.offset = Vector2(randf() * shake, randf() * shake)
		if capture:
			cam.zoom = scale
			cam.global_position = global_position + cam.OFFSET
		match track:
			Focus.USER:   cam.global_position = user.effectHook.global_position + cam.OFFSET
			Focus.TARGET: cam.global_position = target.effectHook.global_position + cam.OFFSET

func _exit_tree() -> void:
	cam.zoom = Vector2(1.0, 1.0)

func setShake(x:float) -> void:
	shake = x
	if initialized:
		cam.shake = x

func setTracking(x:int) -> void:
	track = x

func setJump(x:int) -> void:
	jump = x
