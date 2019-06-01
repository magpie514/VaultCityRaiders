extends Panel
var weaponNode = load("res://nodes/UI/weapon.tscn")
var currentChar = null
var buttons = []

func _ready():
	pass

func clear():
	pass

func init(C):
	var count : int = 0
	var W = null
	var button = null
	clear()
	currentChar = C
	for t in C.equip.WEAPON_SLOT:
		var i = C.equip.slot[t] #TODO: Remember this hack.
		if i != null:
			count += 1
			W = i.lib
			button = get_node(str("Weapon%s" % count))
			button.init(i, count)
			button.setCurrent(i == C.currentWeapon)
