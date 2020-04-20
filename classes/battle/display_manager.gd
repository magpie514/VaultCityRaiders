const SpriteH = preload("res://nodes/UI/battle/enemy_sprite_simple.tscn")
const placeholder_1 = 'res://resources/images/test.png'

var skill           = core.skill
var groups:Array    = core.newArray(2)
var background:Node

func _init(guild, eform, BG) -> void:
	groups[0] = guild
	groups[1] = eform
	background = BG
	for slot in range(6):
		if groups[1].formation[slot] != null:
			var C = groups[1].formation[slot]
			initSprite(C, slot)
		if groups[0].formation[slot] != null:
			var C = groups[0].formation[slot]
			initSprite(C, slot)

func initSprite(C, slot:int) -> void:
	var spr:String = C.lib.spriteFile if C is core.Enemy else placeholder_1
	var node:Node  = getAnchorNode(C, slot)
	if node != null:
		var sprite:Node = SpriteH.instance()
		node.add_child(sprite)
		C.sprite = sprite
		C.UIdisplay = core.battle.UI.grid[1 if C is core.Enemy else 0][slot]
		C.UIdisplay.init(C)
		C.display = node.get_node("Position2D/CharDisplay")
		sprite.init(spr, C, slot)

func addEffector(C, fx:String) -> void:
	var temp:String = str("res://nodes/FX/%s.tscn" % fx)
	print("[DISPLAY_MANAGER][addEffector] Trying to find file %s (input:%s)" % [temp, fx])
	var f:File = File.new()
	if f.file_exists(temp):
		print("[DISPLAY_MANAGER][addEffector] Adding effector %s to %s(%s)" % [temp, C.name, C.slot])
		var scene = load(temp)
		var node:Node = scene.instance()
		C.sprite.effectorHolder.add_child(node)
	else:
		print("[DISPLAY_MANAGER][addEffector] File %s not found." % temp)


func getAnchorNode(C, slot:int) -> Node:
	# Get location node placed in the background scene.
	var t:int         = slot + 1
	var prefix:String = "F" if t < 4 else "B"
	t = t if t < 4 else (t - 3)
	var side:String      = 'Player' if C is core.Player else 'Enemy'
	var nodeName:String  = str("%s/%s%s" % [side, prefix, t])
	var node:Node        = core.battle.background.get_node(nodeName)
	return node
