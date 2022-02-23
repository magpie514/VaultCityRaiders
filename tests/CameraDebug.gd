extends Camera2D
#Battle main camera.
const DEFAULT_SPD = 40.0 #Value for Camera2D's smoothing_speed
const OFFSET    = Vector2(0, -115) #Vertical offset for the camera, otherwise focuses to the shadow of the sprite.

var shake:float = 0.0    #Camera shake factor.

func _ready() -> void:
	smoothing_enabled = true
	smoothing_speed   = DEFAULT_SPD

func _process(delta: float) -> void:
	if shake > 0.1:
		offset = Vector2(randf() * shake, randf() * shake)
	if Input.is_key_pressed(KEY_A):
		position.x -= 5.0
	elif Input.is_key_pressed(KEY_D):
		position.x += 5.0
	elif Input.is_key_pressed(KEY_W):
		position.y -= 5.0
	elif Input.is_key_pressed(KEY_S):
		position.y += 5.0
	elif Input.is_key_pressed(KEY_Q):
		zoom += Vector2(0.02,0.02)
	elif Input.is_key_pressed(KEY_E):
		zoom -= Vector2(0.02,0.02)

func focus(x:int, y:int, quick:bool = false) -> void:
	smoothing_enabled = not quick
	current = true
	position = Vector2(x, y)  + OFFSET

func focusAnchor(n:Node, quick:bool = false) -> void:
	print("[35m Camera anchoring %s %s[0m" % [str(n), n.global_position] )
	focus(n.global_position.x, n.global_position.y, quick)
