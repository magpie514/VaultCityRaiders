extends Sprite

var initialized:bool = false
var sprite:Node2D

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if initialized and visible:
		texture         = sprite.texture
		region_enabled  = sprite.region_enabled
		region_rect     = sprite.region_rect

func init(link:Node2D) -> void:
	sprite = link
	initialized = true
	core.aprint("Initialized %s" % link, core.ANSI_CYAN2)
	set_process(true)
