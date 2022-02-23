tool
extends Sprite

var nextVal:float    = randf()
var count:float      = randf()
var currentVal:float = randf()
var intensity:float  = 0.5

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if not visible: return
	count += clamp(intensity * 0.5, 0.1, 0.9)
	if count > 1.0:
		count = 0
		currentVal = nextVal
		nextVal = clamp(randf(), intensity, 1.0)
	self_modulate.a = lerp(currentVal, nextVal, count)
