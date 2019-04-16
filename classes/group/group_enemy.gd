extends "res://classes/group/group_base.gd"
var enemy = preload("res://classes/char/char_enemy.gd")

const ROW_SIZE = 5
const MAX_SIZE = ROW_SIZE * 2

var display = null
var defeated = []

func updateFormation():
	var M = null

func initBattleTurn():
	var current = null
	for i in range(MAX_SIZE):
		current = formation[i]
		if current != null and current.status == core.skill.STATUS_DOWN:
			print("[GROUP_ENEMY] %s is down, removing from battle..." % [current.name])
			current.display.stop() #TODO: Move to .defeat() on char_enemy?
			formation[i] = null
	display.update()
	.initBattleTurn()

func initSprite(C, slot):
	var spr : String = C.lib.spriteFile
	var t: int  = slot + 1
	var prefix = "F" if t < 6 else "B"
	t = t if t < 6 else (t - 5)
	var nodeName = str("Enemy/%s%s" % [prefix, t])
	var node = core.battle.background.get_node(nodeName)
	if node != null:
		var sprite = load("res://nodes/UI/battle/enemy_sprite_simple.tscn").instance()
		node.add_child(sprite)
		sprite.init(spr, C, slot)
		return sprite
	return null

func initMember(d, lvbonus):
	var m = enemy.new()
	m.level = d.level + lvbonus
	m.tid = d.tid
	m.initDict(core.lib.enemy.getIndex(d.tid))
	return m
	
func defeat(slot:int, C):
	formation[slot].display.stop()
	formation[slot] = null
	defeated.push_front(C)
	display.bars[slot] = null

func revive(x: int) -> void:
	#Only get here if AI determined a revive is possible
	var F = defeated.pop_front()
	var pos:int = -1
	for i in range(MAX_SIZE):
		if formation[i] == null:
			pos = i
			break
	if pos > 0:
		formation[pos] = F
		F.slot = pos
		F.row = 0 if pos < ROW_SIZE else 1
		display.revive(F, pos)
		F.revive(x)

func canRevive() -> bool:
	if defeated.size() > 0:
		if emptySlot():
			print("[GROUP_ENEMY] Can revive: %s" % defeated.size())
			return true
	return false

func init(tid, lvbonus = 0):
	formation = core.newArray(MAX_SIZE)
	var form = core.lib.mform.getIndex(tid)
	name = form.name
	for i in range(MAX_SIZE):
		if form.formation[i] != null:
			formation[i] = initMember(form.formation[i], lvbonus)
			formation[i].group = self
			formation[i].slot = i
			formation[i].row = 0 if i < ROW_SIZE else 1

func getSpreadTargets(row, filter, slot):
	return getSpreadTargets2(row, ROW_SIZE, filter, slot)

func getRowTargets(row, filter):
	return getRowTargets2(row, ROW_SIZE, filter)

func loadDebug():
	init(["debug", "debug"])
