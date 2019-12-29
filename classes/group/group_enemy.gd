extends "res://classes/group/group_base.gd"
var enemy = preload("res://classes/char/char_enemy.gd")
const ROW_SIZE = 3
const MAX_SIZE = ROW_SIZE * 2

const ROW_ITER = [[0, 1, 2], [3, 4, 5], [6, 7, 8]]

var display = null
var defeated = []
var lib = null
var summonRestriction : int = 1

func getRowIter(row: int) -> Array:
	return ROW_ITER[row % 2]


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

func initMember(d, lvbonus = 0):
	var m = enemy.new()
	m.level = d.level + lvbonus
	m.tid = d.tid
	m.initDict(core.lib.enemy.getIndex(d.tid))
	return m

func getSummoned(C) -> Array:
	var result = []
	for i in formation:
		if i != null and i.summoner == C:
			result.push_back(i)
	return result

func defeat(slot:int, C): #Do stuff when the enemy is down.
	var summoned = getSummoned(C)
	for i in summoned: #Notify summons that this enemy is down.
		i.onSummonerDefeat()
	formation[slot] = null
	if C.lib.canResurrect: defeated.push_front(C) #If it can be resurrected, add to the list.
	display.bars[slot] = null

func revive(x: int) -> void:
	#Only get here if AI determined a revive is possible
	var F = defeated.pop_front()
	var pos:int = -1
	if formation[F.slot] == null:
		pos = F.slot
	else:
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

func canSummon() -> bool:
	if summonRestriction > 0:
		if emptySlot():
			print("[GROUP_ENEMY] Can summon.")
			return true
	return false

func trySummon(user, x: int, override = null, level = -1) -> Array:
	if not canSummon():
		print("[GROUP_ENEMY][trySummon] Cannot summon!")
		return [false, null]

	var slot : int = -1
	var SU = null
	var success : bool = false

	if override != null and x < override.size(): #Using a skill-defined override.
		print("[GROUP_ENEMY][trySummon] Using skill override.")
		SU = override[x]
	elif lib.summons != null and x < lib.summons.size(): #Try to summon formation specific summons
		print("[GROUP_ENEMY][trySummon] Using group override.")
		SU = lib.summons[x]
	elif user.lib.summons != null and x < user.lib.summons.size(): #Try to summon enemy specific summons
		print("[GROUP_ENEMY][trySummon] Using enemy summon data.")
		SU = user.lib.summons[x]
	else: #None is defined, try to call a repeat of user.
		print("[GROUP_ENEMY][trySummon] No summons data found. Trying to clone user.")
		SU = core.lib.enemy.loaderSummons([{tid = user.tid, level = user.level - 2}])[0]
	if level > 0:
		SU.level = level
	for i in SU.amount:
		slot = findSummonSlot(SU)
		if slot >= 0: #Slot found, proceed.
			summon(user, slot, SU)
			success = true
		else:
			print("[GROUP_ENEMY][trySummon] Couldn't find slot to summon!")
			break
	return [success, SU]


func findSummonSlot(SU) -> int:
	var slot = -1
	if SU.restrictRow > 0: #Restrict summoning to specific slots
		var row = getRowIter(SU.restrictRow - 1)
		if SU.center: #Start searching from slots near to user
			for j in row:
				if formation[j] == null:
					slot = j
					break
		else: #Start searching in order
			for j in row:
				if formation[j] == null:
					slot = j
					break
	else: #Just find a slot if available! no rules!
		for j in range(formation.size()):
			if formation[j] == null:
				slot = j
	return slot

func summon(user, slot, SU):
	print("[GROUP_ENEMY][summon] Trying to summon %s" % [str(SU)])
	addMember(SU, slot)
	formation[slot].summoner = user

func addMember(data, slot):
	formation[slot] = initMember(data)
	formation[slot].slot = slot
	formation[slot].row = 0 if slot < ROW_SIZE else 1
	formation[slot].group = self
	formation[slot].initBattle()
	formation[slot].display = display.createDisplay(slot)
	display.bars[slot] = formation[slot].display
	#formation[slot].sprDisplay = initSprite(formation[slot], slot)
	display.connectSignals(display.bars[slot], core.battle.control)


func init(tid, lvbonus = 0):
	formation = core.newArray(MAX_SIZE)
	var form = core.lib.mform.getIndex(tid)
	lib = form
	name = lib.name
	for i in range(MAX_SIZE):
		if form.formation[i] != null:
			formation[i] = initMember(lib.formation[i],  lvbonus)
			formation[i].group = self
			formation[i].slot = i
			formation[i].row = 0 if i < ROW_SIZE else 1


func getRowSize():
	return ROW_SIZE

func getDefeated() -> int:
	return defeated.size()

func loadDebug():
	init(["debug", "debug"])
