extends Panel
var S = null
var skill = core.skill
var textures : Array = core.newArray(8)
var elements : Array = core.newArray(3)
var colors = ["000000", "880000", "FF0000", "FF8800", "FFFF00", "88FF88", "00FFFF", "88FFFF", "FFFFFF"]

func _init() -> void:
	for i in range(8):
		textures[i] = load(core.stats.ELEMENT_DATA[i].icon)

func init(_S, level) -> void:
	S = _S
	if S == null: return
	$Name.text = "%s  LV%02d/%02d" % [S.name, level+1, S.levels]
	$Desc.text = S.description
