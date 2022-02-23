#Animation puppet character logic. Passes parameters and positions to a linked sprite.
extends Position2D

export(String, 'IDLE', 'ACTION', 'CHARGE', 'DASH', 'GUARD', 'DAMAGE', 'DEFEAT') var frame:String = 'IDLE'
export(bool) var capture:bool        = false setget setCapture
export(bool) var approach:bool       = false
export(bool) var emitAfterimage:bool = false setget setEmitAfterimage
export(float) var shake:float = 0.0 setget setShake

onready var a_offset:Vector2 = position
onready var parent:Node2D = get_parent()
onready var fxHook:Node2D = $FXHook
var initialized:bool = false
var sprite

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass # Replace with function body.

func init(sprite_) -> void:
	sprite = sprite_
	a_offset = position
	core.aprint("OFFSET: {off}({self})".format({'off': a_offset, 'self':self}), core.ANSI_YELLOW)
	initialized = true
	set_process(true)

func _process(delta: float) -> void:
	if sprite != null:
		if capture:
			if approach:
				sprite.global_position = parent.global_position + (position * parent.scale)
			else:
				sprite.global_position = sprite.get_parent().global_position + (position - a_offset) * parent.scale
		fxHook.global_position = sprite.global_position


func setEmitAfterimage(x:bool) -> void:
	emitAfterimage = x
	if initialized:
		sprite.afterimage = x

func setFrame(x:String) -> void:
	frame = x
	if initialized:
		if sprite != null: sprite.setFrame(x)

func setCapture(x:bool) -> void:
	capture = x

func setShake(x:float) -> void:
	shake = x
	if initialized:
		sprite.shake = x
