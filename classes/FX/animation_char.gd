#Animation puppet character logic. Passes parameters and positions to a linked sprite.
extends Position2D

export(String, 'IDLE', 'ACTION', 'CHARGE', 'DASH', 'GUARD', 'DAMAGE', 'DEFEAT') var frame:String = 'IDLE'
export(bool) var emitAfterimage:bool = false setget setEmitAfterimage
export(float) var shake:float        = 0.0   setget setShake

onready var a_offset:Vector2 = position
onready var fxHook:Node2D    = $FXHook
onready var parent           = get_parent()
var initialized:bool = false
var sprite

func _ready() -> void:
	pass # Replace with function body.

func init(sprite_) -> void:
	sprite = sprite_
	a_offset = position
	core.aprint("[CHAR_BASIC][init] OFFSET: {off}({self})".format({'off': a_offset, 'self':self, 'class': sprite.get_class()}), core.ANSI_YELLOW)
	initialized = true
	set_process(true)

func _process(delta:float) -> void:
	if visible:
		fxHook.global_position  = sprite.effectHook.global_position
		sprite.spriteHook.scale = scale
		sprite.modulate         = modulate

func setEmitAfterimage(x:bool) -> void:
	emitAfterimage = x
	if initialized:
		sprite.afterimage = x

func setFrame(x:String) -> void:
	frame = x
	if initialized:
		if sprite != null: sprite.setFrame(x)

func setShake(x:float) -> void:
	shake = x
	if initialized:
		sprite.shake = x
