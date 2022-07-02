extends "res://classes/group/group_base.gd"
var display               = null
var defeated:Array        = []
var lib                   = null
var summonRestriction:int = 1
var boss:bool             = false

# Virtual overrides ###############################################################################
func getDefeated() -> int:	return defeated.size()
###################################################################################################
func init(tid, lvbonus:int = 0) -> void:
	formation = core.newArray(MAX_SIZE)
	var form  = core.lib.mform.getIndex(tid)
	lib       = form
	name      = lib.name
	for i in range(MAX_SIZE):
		if form.formation[i] != null: addMember(lib.formation[i], i, lvbonus)

func addMember(data, slot:int, lvbonus:int = 0) -> void:
	formation[slot]         = initMember(data, lvbonus)
	formation[slot].slot    = slot
	formation[slot].row     = 0 if slot < ROW_SIZE else 1
	formation[slot].group   = self
	formation[slot].initBattle()
	#formation[slot].sprite = core.battle.displayManager.initSprite(formation[slot], slot)

func updateFormation() -> void:
	var M = null

func initBattleTurn() -> void:
	var current = null
	for i in range(MAX_SIZE):
		current = formation[i]
		if current != null and current.condition == core.skill.CONDITION_DOWN:
			print("[GROUP_ENEMY] %s is down, removing from battle..." % [current.name])
			formation[i] = null
	#display.update()
	.initBattleTurn()

func initMember(D:Dictionary, lvbonus:int = 0) -> Enemy:
	var m:Enemy = Enemy.new()
	m.level     = D.level + lvbonus
	m.tid       = D.tid
	m.initDict(core.lib.enemy.getIndex(D.tid))
	return m

func getSummoned(C) -> Array:
	var result:Array = []
	for i in formation:
		if i != null and i.summoner == C:
			result.push_back(i)
	return result

func defeat(slot:int, C) -> void: #Do stuff when the enemy is down.
	var summoned = getSummoned(C)
	for i in summoned: #Notify summons that this enemy is down.
		i.onSummonerDefeat()
	formation[slot] = null
	if C.lib.canResurrect: defeated.push_front(C) #If it can be resurrected, add to the list.

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

	var SU = null
	var slot:int = -1
	var success:bool = false

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

func summon(user:Enemy, slot:int, SU) -> void:
	print("[GROUP_ENEMY][summon] Trying to summon %s" % [str(SU)])
	addMember(SU, slot)
	core.battle.displayManager.initSprite(formation[slot], slot)
	formation[slot].summoner = user

func revive(x:int) -> void:
	#Only get here if AI determined a revive is possible
	var F = defeated.pop_front()
	var pos:int = -1
	if formation[F.slot] == null: #Use previously occupied slot.
		pos = F.slot
		print("[GROUP_ENEMY][revive] Reviving at old position (%s)" % pos)
		print(F)
	else:
		for i in range(MAX_SIZE): #Find a new slot.
			if formation[i] == null:
				pos = i
				print("[GROUP_ENEMY][revive] Reviving at position %s" % pos)
				break
	if pos > 0: #Valid position found.
		#display.revive(F, pos)
		formation[pos]       = F
		formation[pos].slot  = pos
		formation[pos].row   = 0 if pos < ROW_SIZE else 1
		formation[pos].group = self
		core.battle.displayManager.initSprite(F, pos)
		F.revive(x)
	else: #Revival failed.
		return

func canRevive() -> bool:
	if defeated.size() > 0:
		if emptySlot():
			print("[GROUP_ENEMY] Can revive: %s" % defeated.size())
			return true
	return false

func loadDebug() -> void:
	init(["debug", "debug"])
