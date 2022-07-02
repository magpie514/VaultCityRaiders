extends CanvasLayer

export(bool) var enable:bool = false setget set_enable
onready var user:Position2D   = $FakeUser
onready var target:Position2D = $FakeTarget
onready var background:Sprite = $Background
var initialized:bool = false

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func set_enable(x:bool) -> void:
	enable = x
	if initialized:
		match enable:
			true:
				background.show()
			false:
				background.hide()
				user.hide()
				target.hide()
