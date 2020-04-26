extends Control
signal display_info(x)
signal hide_info

var textures:Array = core.newArray(9)
var S = null
var level:int = 1

func _init() -> void:
	for i in range(9):
		textures[i] = load(core.stats.ELEMENT_DATA[i].icon)

enum {
	COST_NONE = 0,
	COST_EP,
	COST_WP,
	COST_OV
}

func init(_S, _level, costs = COST_NONE, gem:bool = false):
	S = _S
	level = _level
	var DE = S.displayElement
	var elem = null
	$Label.text = S.name
	$Button.hint_tooltip = S.description
	$Label.set("custom_colors/font_color", "#FFDD00" if gem else "#FFFFFF")

	if DE.size() > 0:
		for i in range(DE.size()):
			if i < 3:
				elem = get_node(str("Element",i))
				elem.texture = textures[DE[i]]
				elem.self_modulate = core.stats.ELEMENT_DATA[DE[i]].color
				elem.show()
	else:
		$Element0.texture = textures[S.element[level]]
		$Element0.self_modulate = core.stats.ELEMENT_DATA[S.element[level]].color
	match costs:
		COST_NONE:
			$USE.text = ""
		COST_EP:
			$USE.text = "%d" % S.costEP[level]
		COST_OV:
			$USE.text = "%d%%" % S.costOV
		COST_WP:
			$USE.text = "%d" % S.costWP[level]


func _on_Button_mouse_entered() -> void:
	emit_signal("display_info", S, 2, level)

func _on_Button_mouse_exited() -> void:
	emit_signal("hide_info")
