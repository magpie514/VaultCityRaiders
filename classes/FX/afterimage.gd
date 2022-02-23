extends Sprite
export(float) var TTL:float = 0.2  #Time to live.
export(Gradient) var grad:Gradient #Color gradient.

var timer:float = 0.0 #Current time.

func _ready() -> void:
	set_process(true)

func init(sprite:Node2D) -> void:
	texture = sprite.texture
	region_enabled = sprite.region_enabled
	global_position = sprite.global_position
	region_rect = sprite.region_rect
	scale = sprite.scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer > TTL:
		timer = TTL
	self_modulate = grad.interpolate((timer / TTL) if timer < TTL else 1.0)
	if timer >= TTL:
		queue_free()

