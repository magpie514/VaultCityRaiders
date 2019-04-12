extends Panel
const icons = [
	"res://resources/icons/dgem_empty.svg",
	"res://resources/icons/dgem_diamond.svg",
	"res://resources/icons/dgem_round.svg",
	"res://resources/icons/dgem_square.svg",
	"res://resources/icons/dgem_square.svg",
]
const blinks = [1, 3, 8, 14, 21, 30, 41, 53, 66, 81]
var colors : Array = core.newArray(8)
var levels : Array = core.newArray(8)
var timer : float = 0.0
var blink : bool = false
var is_init : bool = false

func init(DG):
	is_init = true
	for i in range(8):
		var node = get_node(str("Gem%1d" %i))
		var spr = node.get_node("Sprite")
		var current = DG.slot[i]
		if current != null:
			spr.self_modulate = current.lib.color
			spr.texture = load(icons[current.lib.shape])
			spr.get_node("Shadow").texture = spr.texture
			spr.show()
			colors[i] = current.lib.color
			levels[i] = current.level
			node.hint_tooltip = current.printGem()
		else:
			spr.self_modulate = "#FFFFFFFF"
			colors[i] = "#FFFFFFFF"
			levels[i] = 0
			spr.texture = null
			node.hint_tooltip = ""
			spr.hide()

func _process(delta: float) -> void:
	if is_visible() and is_init:
		timer += delta
		if blink:
			timer = 0.0
			blink = false
			for i in range(8):
				var node = get_node(str("Gem%1d" %i))
				var spr = node.get_node("Sprite")
				if spr.is_visible():
					spr.self_modulate = colors[i]
		if timer > 0.3:
			blink = true
			for i in range(8):
				var node = get_node(str("Gem%1d" %i))
				var spr = node.get_node("Sprite")
				if spr.is_visible():
					spr.self_modulate = Color(2.0, 2.0, 2.0) if core.chance(blinks[levels[i]]) else colors[i]



