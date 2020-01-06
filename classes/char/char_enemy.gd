extends "res://classes/char/char_base.gd"

var tid = null
var sprDisplay = null
var skills = []
var lib = null
var XPMultiplier:float = 1.0
var summoner = null
var armed:bool = true #If the enemy is supposed to be wielding weapons or not.
var ID:int = 0        #Unique ID. Used only for mons.

func recalculateStats():
	var S = stats.create()
	stats.setFromSpread(S, lib.statSpread, level)
	stats.setElementDataFromArray(S.RES, lib.RES)
	stats.setElementDataFromArray(S.OFF, lib.OFF)
	var modstats = stats.create()
	modstats.ATK = S.ATK
	modstats.DEF = S.DEF
	modstats.ETK = S.ETK
	modstats.EDF = S.EDF
	stats.copy(statBase, S)
	stats.sumInto(statFinal, S, modstats)

func initDict(C): #Initialize an enemy from a data dict.
	side = 1
	lib = C
	ID = randi() #TODO: Assign an unique integer ID to this enemy.
	self.name = str(lib.name)
	energyColor = C.energyColor
	for i in lib.skill:
		skills.push_back(core.tid.fromArray(i))
	recalculateStats()
	fullHeal()
	print(getTooltip())

func getTooltip():
	return "%s Lv.%s\n%s" % [name, level, core.stats.print(statFinal)]

func defeatMessage() -> String:
	return str(lib.defeatMsg % name)

func defeat() -> void:
	.defeat()
	core.battle.control.state.EXP += int(100 * XPMultiplier)
	print("[CHAR_ENEMY] %s defeated! +%d EXP Total enemies defeated: %s" % [name, 100 * XPMultiplier, group.defeated])
	sprDisplay.defeat()
	display.stop()
	group.defeat(slot, self)
	#skill.msg(str(lib.defeatMsg % name))

func onSummonerDefeat():
	print("[CHAR_ENEMY][onSummonerDefeat] %s's summoner fell!" % name)
	print("[TODO] Add special effects here...")
	print("[TODO] Add capture chance here when mons are a thing.")

func damage(x, data, silent = false) -> Array:
	var info : Array = .damage(x, data, silent)
	if sprDisplay != null:
		sprDisplay.damage()
		sprDisplay.damageShake()
	return info

func charge(x : bool = false) -> void:
	if sprDisplay != null:
		sprDisplay.charge(x)

func pickSkill():
	if skills == null:
		return core.tid.create("debug", "debug")
	else:
		var slot = randi() % skills.size()
		var S = core.lib.skill.getIndex(skills[slot])
		return skills[slot]

func pickTarget(S, level, F, P, state):
	var result = null
	var group = F if core.skill.TARGET_GROUP_ALLY else P
	match(S.target[level]):
		core.skill.TARGET_SELF:
			return [ self ]
		core.skill.TARGET_SINGLE:
			if S.ranged[level]:
				if core.chance(80): return group.getRandomTarget(S)
				else: return group.getRandomRowTarget(0, S)
			else:
				if row == 0:
					if core.chance(55): return group.getRandomTarget(S)
					else: return group.getRandomRowTarget(0, S)
				else:
					return group.getRandomRowTarget(0, S)
		core.skill.TARGET_ROW:
			if S.ranged[level]:
				if core.chance(55): return group.getRowTargets(0, S)
				else: return group.getRowTargets(1, S)
			else:
				if row == 0:
					if core.chance(60): return group.getRowTargets(0, S)
					else: return group.getRowTargets(1, S)
				else:
					return group.getRowTargets(0, S)
		core.skill.TARGET_ALL:
			if S.ranged[level] or row == 0:
				return group.getAllTargets(S)
			else:
				return group.getRowTargets(0, S)


func thinkBattleAction(F, P, state):
	match lib.ai:
		0:
			return thinkRandom(F, P, state)
		1:
			if lib.aiPattern == null:
				return thinkRandom(F, P, state)
			else:
				return thinkPattern(F, P, state, lib.aiPattern)
		_:
			return thinkRandom(F, P, state)


func thinkRandom(F, P, state) -> Array:
	var action = pickSkill()
	var S = core.lib.skill.getIndex(action)
	var target = pickTarget(S, 1, F, P, state)
	print("[%s] using %s on %s" % [name, S.name, target])
	return [ action, 1, target ]

func thinkPattern(F, P, state, aiPattern):
	var pattern = aiPattern.pattern
	var index = (state.turn - 1) % pattern.size()
	var targetHint = core.lib.enemy.AITARGET_RANDOM
	var action = null
	var S = null
	var target = null
	var temp = null
	if index <= pattern.size():
		print("turn %s, index %s:" % [state.turn, index])
	match pattern[index][0]:
		core.lib.enemy.AIPATTERN_SIMPLE:
			action = skills[(pattern[index][1][0])]
			targetHint = pattern[index][1][1]
			S = core.lib.skill.getIndex(action)
			print("[SIMPLE, %s]" % [S.name])
		core.lib.enemy.AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY:
			action = skills[(pattern[index][1][0])]
			targetHint = pattern[index][1][1]
			temp = "false"
			if state.checkForAction(action):
				action = skills[(pattern[index][2][0])]
				targetHint = pattern[index][2][1]
				temp = "true"
			S = core.lib.skill.getIndex(action)
			print("[PICK_2_IF_ALLY_USED_1_ALREADY, %s, %s]" % [temp, S.name])

		core.lib.enemy.AIPATTERN_PICK_RANDOMLY:
			if core.chance(pattern[index][1]):
				action = skills[pattern[index][2][0]]
				temp = "true"
				targetHint = pattern[index][2][1]
			else:
				action = skills[pattern[index][3][0]]
				temp = "false"
				targetHint = pattern[index][3][1]
			S = core.lib.skill.getIndex(action)
			print("[PICK RANDOMLY, (%s), %s]" % [temp, S.name])
		core.lib.enemy.AIPATTERN_PICK_2_IF_WEAK:
			if int(getHealthN() * 100) <= pattern[index][1]:
				action = skills[pattern[index][2][0]]
				temp = "true"
				targetHint = pattern[index][2][1]
			else:
				action = skills[pattern[index][3][0]]
				temp = "false"
				targetHint = pattern[index][3][1]
			S = core.lib.skill.getIndex(action)
			print("[PICK 2 IF WEAK, (%s, %s), %s]" % [temp, int(getHealthN() * 100), S.name])
		core.lib.enemy.AIPATTERN_PICK_2_IF_CAN_REVIVE:
			if not group.canRevive():
				action = skills[pattern[index][1][0]]
				temp = "true"
				targetHint = pattern[index][1][1]
			else:
				action = skills[pattern[index][2][0]]
				temp = "false"
				targetHint = pattern[index][2][1]
			S = core.lib.skill.getIndex(action)
			print("[PICK 2 IF CAN_REVIVE, (%s, %s), %s]" % [temp, int(getHealthN() * 100), S.name])
		_:
			action = skills[0]
			targetHint = core.lib.enemy.AITARGET_RANDOM
			S = core.lib.skill.getIndex(action)
			print("[ERROR, using %s]" % [S.name])

	#Try to pick a given target.
	match targetHint:
		core.lib.enemy.AITARGET_SELF:
			target = [ self ]
		core.lib.enemy.AITARGET_SUMMONER:
			if summoner != null:
				print("[AITARGET] Summoner found (%s)" % summoner.name)
				target = [ summoner ] if summoner.filter(S) else pickTarget(S, 1, F, P, state)
			else:
				print("[AITARGET] No summoner found, picking normally.")
				target = pickTarget(S, 1, F, P, state)
		core.lib.enemy.AITARGET_WEAKEST:
			var T = group.versus.getWeakestTarget(S)
			if T != null:
				print("[AITARGET] Picking weakest (%s)" % T.name)
				target = [ T ]
			else:
				print("[AITARGET] No weakest target found, picking normally.")
				target = pickTarget(S, 1, F, P, state)
		core.lib.enemy.AITARGET_ALLY_WEAKEST:
			var T = group.getWeakestTarget(S)
			if T != null:
				print("[AITARGET] Picking weakest ally (%s)" % T.name)
				target = [ T ]
			else:
				print("[AITARGET] No weakest ally target found, picking normally.")
				target = pickTarget(S, 1, F, P, state)
		_:
			print("[AITARGET] Unknown targethint %d, picking randomly." % targetHint)
			target = pickTarget(S, 1, F, P, state)                                    #TODO: Set skill level properly.
	print("[%s] using %s on %s" % [name, S.name, target])
	if S.chargeAnim[0]:
		sprDisplay.charge(true)
	return [ action, 1, target ]


func filter(S:Dictionary) -> bool:
	if S.targetBlacklist != null:
		for i in S.targetBlacklist:
			if i[0] == tid[0] and i[1] == tid[1]:
				return false
	return .filter(S)

func checkRaceType(type) -> bool:
	var result : bool = false
	if type in lib.race:
		result = true
	return result
