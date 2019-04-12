extends Node2D

func _ready():
	pass


func enemySpriteInit(slot, spr, C):
	var S = null
	if spr != null:
		S = spr
	else:
		S = "res://resources/images/test.png"
	var t = slot + 1
	var prefix = "F" if t < 6 else "B"
	t = t if t < 6 else (t - 5)
	var nodeName = str("Enemy/%s%s" % [prefix, t])
	var node = get_node(nodeName)
	if node == null:
		return null
	else:
		var sprite = load("res://nodes/UI/battle/enemy_sprite_simple.tscn").instance()
		node.add_child(sprite)
		sprite.init(S, C)
		return sprite


func init(group):
	for i in range(10):
		if group.formation[i] != null:
			group.formation[i].sprDisplay = enemySpriteInit(i, group.formation[i].lib.spriteFile, group.formation[i])
