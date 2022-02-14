tool
extends Sprite

var nextVal:float    = randf()
var count:float      = randf()
var currentVal:float = randf()
var intensity:float  = 0.7

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if not visible: return
	count += 0.1
	if count > 1.0:
		count = 0
		currentVal = nextVal
		nextVal = clamp(randf(), 0.1+intensity, 1.0)
	modulate.a = lerp(currentVal, nextVal, count)
