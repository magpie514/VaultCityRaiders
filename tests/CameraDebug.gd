extends Camera2D
#Battle main camera.
const DEFAULT_SPD = 20.0 #Value for Camera2D's smoothing_speed
const Y_OFFSET    = -115 #Vertical offset for the camera, otherwise focuses to the shadow of the sprite.

var shake:float = 0.0    #Camera shake factor.

func _ready() -> void:
	smoothing_enabled = true
	smoothing_speed   = DEFAULT_SPD

func _process(delta: float) -> void:
	if shake > 0.1:
		offset = Vector2(randf() * shake, randf() * shake)
	if Input.is_key_pressed(KEY_A):
		position.x -= 2.0
	elif Input.is_key_pressed(KEY_D):
		position.x += 2.0
	elif Input.is_key_pressed(KEY_W):
		position.y -= 1.0
	elif Input.is_key_pressed(KEY_S):
		position.y += 1.0
	elif Input.is_key_pressed(KEY_Q):
		zoom += Vector2(0.01,0.01)
	elif Input.is_key_pressed(KEY_E):
		zoom -= Vector2(0.01,0.01)

func focus(x:int, y:int, quick:bool = false, no_offset = false) -> void:
	smoothing_enabled = not quick
	current = true
	position = Vector2(x, y + (Y_OFFSET if no_offset == false else 0))

func focusAnchor(n:Node, quick:bool = false, no_offset = false) -> void:
	print("[35m Camera anchoring %s %s[0m" % [str(n), n.global_position] )
	focus(n.global_position.x, n.global_position.y, quick, no_offset)
