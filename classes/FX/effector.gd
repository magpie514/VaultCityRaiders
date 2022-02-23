extends Node2D
enum REMOVE {
	ALWAYS = 0,
	ON_SKILL_END = 1,
	PASSIVE = 2,
}
export(REMOVE) var removal_mode:int = REMOVE.ALWAYS
var skill_tid:String = ''
var chr = null
var initialized:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init(C, S:Dictionary, delmode:int = REMOVE.ALWAYS) -> void:
	skill_tid = S.self_tid
	removal_mode = delmode
	chr = C
	initialized = true
	pass

func check_deletion() -> void:
	match removal_mode:
		REMOVE.ALWAYS:
			queue_free()
		REMOVE.ON_SKILL_END:
			pass #TODO:Needs some sort of quick list of active passives+buffs+debuffs+effects.
		REMOVE.PASSIVE: #Do not remove.
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
