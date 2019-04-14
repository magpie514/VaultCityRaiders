extends "res://classes/char/char_base.gd"

var tid = null
var sprDisplay = null
var skills = []
var lib = null
var XPMultiplier : float = 1.0

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


func initDict(C):
	side = 1
	lib = C
	self.name = str(lib.name)
	energyColor = C.energyColor
	for i in lib.skill:
		skills.push_back(core.tid.fromArray(i))
	recalculateStats()
	fullHeal()
	print(getTooltip())

func getTooltip():
	return "%s Lv.%s\n%s" % [name, level, core.stats.print(statFinal)]

func defeat():
	.defeat()
	core.battle.control.state.EXP += (100 * XPMultiplier)

	if sprDisplay != null:
		sprDisplay.defeat()

func damage(x, data, silent = false) -> Array:
	var info : Array = .damage(x, data, silent)
	if sprDisplay != null and not silent:
		sprDisplay.damage()
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
				if core.chance(80): return group.getRandomTarget(0)
				else: return group.getRandomRowTarget(0, 0)
			else:
				if row == 0:
					if core.chance(55): return group.getRandomTarget(0)
					else: return group.getRandomRowTarget(0, 0)
				else:
					return group.getRandomRowTarget(0, 0)
		core.skill.TARGET_ROW:
			if S.ranged[level]:
				if core.chance(55): return group.getRowTargets(0, 0)
				else: return group.getRowTargets(1, 0)
			else:
				if row == 0:
					if core.chance(60): return group.getRowTargets(0, 0)
					else: return group.getRowTargets(1, 0)
				else:
					return group.getRowTargets(0, 0)
		core.skill.TARGET_ALL:
			if S.ranged[level] or row == 0:
				return group.getAllTargets(S.filter)
			else:
				return group.getRowTargets(0, 0)


func thinkBattleAction(F, P, state):
	match lib.ai:
		0:
			return thinkRandom(F, P, state)
		1:
			if lib.aiPattern == null:
				return thinkRandom(F, P, state)
			else:
				return thinkPattern(F, P, state, lib.aiPattern)
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
	var targetHint = core.lib.monster.AITARGET_RANDOM
	var action = null
	var S = null
	var target = null
	var temp = null
	if index <= pattern.size():
		print("turn %s, index %s:" % [state.turn, index])
	match pattern[index][0]:
		core.lib.monster.AIPATTERN_SIMPLE:
			action = skills[(pattern[index][1][0])]
			targetHint = pattern[index][1][1]
			S = core.lib.skill.getIndex(action)
			print("[SIMPLE, %s]" % [S.name])
		core.lib.monster.AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY:
			action = skills[(pattern[index][1][0])]
			targetHint = pattern[index][1][1]
			temp = "false"
			if state.checkForAction(action):
				action = skills[(pattern[index][2][0])]
				targetHint = pattern[index][2][1]
				temp = "true"
			S = core.lib.skill.getIndex(action)
			print("[PICK_2_IF_ALLY_USED_1_ALREADY, %s, %s]" % [temp, S.name])

		core.lib.monster.AIPATTERN_PICK_RANDOMLY:
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
		core.lib.monster.AIPATTERN_PICK_2_IF_WEAK:
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
		_:
			action = skills[0]
			targetHint = core.lib.monster.AITARGET_RANDOM
			S = core.lib.skill.getIndex(action)
			print("[ERROR, using %s]" % [S.name])
	match targetHint:
		_:
			target = pickTarget(S, 1, F, P, state)                                    #TODO: Set skill level properly.
	print("[%s] using %s on %s" % [name, S.name, target])
	if S.chargeAnim[0]:
		sprDisplay.charge(true)
	return [ action, 1, target ]
