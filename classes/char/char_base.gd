var stats = core.stats
var skill = core.skill

# Basic stats ##################################################################
var name = ""													#Name of the character
var level = int()											#XP level
var status = core.skill.STATUS_NONE		#Status

var HP : int = 0											#Character's vital (HP)
var statBase = stats.create()					#Base stats
var statFinal = stats.create()				#Calculated stats
var battle = null 										#Battle stats (See createBattleStats())

# Battle display ###############################################################
var display = null										#Reference to the character's UI element for quick access.
var energyColor = "#AAFFFF"           #Color used for certain effects.
# Various shortcut vars ########################################################
var slot : int = 0										#Character's position slot in its group.
var row : int = 0											#Character's calculated row
var side : int = 0										#Quick ally/enemy reference. Mostly for text coloring.
var group = null											#Reference to the character's group.


class BattleStats:
	# Core stats ################################################################################
	var stat = core.stats.create()         #Calculated battle stats
	var statmult : Dictionary = {}      #Stat multipliers
	# Statistics ################################################################################
	var accumulatedDMG : int = 0      #Damage accumulated during current battle
	var accumulatedDealtDMG : int = 0 #Damage dealt accumulated during current battle
	var defeats : int = 0             #Number of enemies defeated during current battle.
	var resistedHits : int = 0        #Number of attacks that hit an elemental resistance this turn
	var weaknessHits : int = 0        #Number of attacks that hit an elemental weakness this turn
	var turnDMG : int = 0             #Damage accumulated during current turn
	var turnDealtDMG : int = 0        #Damage dealt during current turn
	var turnHits : int = 0            #Number of hits this turn
	var turnDodges : int = 0          #Number of times attacks were dodged this turn
	var turnHeal : int = 0            #Amount of health restored this turn
	# Switches ##################################################################################
	var turnActed : bool = false      #True if character acted this turn
	var paralyzed : bool = false      #If true, character is unable to act due to paralysis this turn.
	var scanned : bool = false        #If scanned, use the scanned resists set.
	# Buffs/Debuffs/Effects #####################################################################
	var buff : Array = []             #Active buffs (stack of 3)
	var debuff : Array = []           #Active debuffs (stack of 3)
	var effect : Array = []           #Active special effects (max 8, will fail if no slots)
  # Onhit activations #########################################################################
	var follow : Array = []           #Same as above, but used as a buff to add CODE_FL skills to the user's own actions.
	var combo : Array = []            #Array of arrays [user, chance, decrement, skill, level], runs CODE_FL of that skill.
	var counter : Array = [100, 100, null, 0, core.stats.ELEMENTS.DMG_UNTYPED, 1, core.skill.PARRY_NONE]
	var delayed : Array = []          #Array of arrays [user, countdown, skill, level] Similar to above, a delayed skill will activate after X turns
	# Defensive stats ###########################################################################
	var AD : int = 100                #Active Defense. Global final damage multiplier.
	var decoy : int = 0               #Chance to draw enemy attacks to self.
	var guard : int = 0               #Prevents an amount of damage. Like a health buffer.
	var barrier : int = 0             #Nullifies X damage from the received total.
	var specialDodge : int = 0        #Always dodges X attacks this turn unless they are set to not miss
	var chain : int = 0               #Chain counter.
	var parry : Array = [100, 33, core.skill.PARRY_NONE]
	var protectedBy : Array = []	    #Array of arrays, [pointer to defender, chance of defending]
	# Misc stats ################################################################################
	var overheat : int = 0            #Reduces by 1 per turn. Prevents overheat skills from being used.
	var lastAction = null

func createBattleStats():
	return BattleStats.new()

func checkParalysis() -> bool:
	if status != skill.STATUS_PARA:
		return false
	else:
		return true if core.chance(50) else false

func clampHealth() -> void:
	HP = int(clamp(HP, 0, maxHealth()))

func recalculateStats():
	pass

func resetBattleStatMultipliers():
	for i in stats.STATS:
		battle.statmult[i] = int(100)

func applyBattleStatMultipliers():
	for i in stats.STATS:
		battle.stat[i] = int(float(battle.stat[i]) * (float(battle.statmult[i]) * 0.01))

func initBattleTurn() -> void:
	clampHealth()
	recalculateStats()
	stats.copy(battle.stat, statFinal)
	resetBattleStatMultipliers()
	battle.turnDMG = 0
	battle.turnDealtDMG = 0
	battle.turnDodges = 0
	battle.turnHeal = 0
	battle.turnActed = false
	battle.turnHits = 0
	battle.resistedHits = 0
	battle.weaknessHits = 0
	battle.paralyzed = checkParalysis()
	battle.decoy = 0
	battle.guard = 0
	battle.barrier = 0
	battle.specialDodge = 0
	battle.protectedBy.clear()
	battle.follow.clear()
	battle.combo.clear()
	battle.AD = 100
	battle.counter[0] = 100
	battle.counter[1] = 100
	battle.counter[2] = null
	battle.counter[3] = 0
	battle.counter[4] = core.stats.ELEMENTS.DMG_UNTYPED
	battle.counter[5] = 1
	battle.counter[6] = skill.PARRY_NONE
	checkEffects(battle.buff, true)
	checkEffects(battle.debuff, true)
	applyBattleStatMultipliers()

func updateBattleStats() -> void:
	recalculateStats()
	stats.copy(battle.stat, statFinal)
	resetBattleStatMultipliers()
	checkEffects(battle.buff)
	checkEffects(battle.debuff)
	applyBattleStatMultipliers()

func endBattleTurn(defer) -> void:
	#Reset guard and barrier values now so they don't show in the player UI.
	battle.guard = 0
	battle.barrier = 0
	#Placeholder for skills that cause overheat.
	if battle.overheat > 0:
		battle.overheat -= 1
		if battle.overheat == 0:
			battle.overheat = 0
	battle.buff = updateEffects(battle.buff, defer)
	battle.debuff = updateEffects(battle.debuff, defer)

func initBattle() -> void:
	battle = createBattleStats()
	initBattleTurn()

func maxHealth():
	return statFinal.MHP

func getHealthN(): #Get normalized health as a float from 0 to 1.
	return float(float(HP) / float(maxHealth()))

func fullHeal():
	self.HP = maxHealth()

func calcSPD(S, level):
#[(Equipment Speed Mod + 100) * AGI * Skill Speed Mod * Random number between 90 and 110 / 10000] * Modifiers
	level -= 1
	var equipSpeedMod = float(getEquipSpeedMod() + 100)
	var AGI = battle.stat.AGI
	var mod = 100 #90 + ( randi() % 20 )
	var skillSpeedMod = float(S.spdMod[level]) * 0.01
	#return (equipSpeedMod * AGI * skillSpeedMod * mod * statBonus.mult.SPD) / 10000
	return (equipSpeedMod * AGI * skillSpeedMod * mod) / 10000

func getEquipSpeedMod():
	return 0

func damageProtectionPass(x : int) -> int:
	if battle.guard > 0:
		var check = battle.guard - x
		if check > 0:
			x = x - battle.guard
			battle.guard = check
		else:
			x = x - battle.guard
			battle.guard = 0
	if battle.barrier > 0:
		x = x - battle.barrier
	return x

func damageResistModifier(x : float, _type : int, energyDMG : bool) -> Array:
	# Apply Kinetic/Energy damage modifiers.
	if energyDMG: x = x * core.percent(battle.stat.RES.DMG_ENERGY)
	else:         x = x * core.percent(battle.stat.RES.DMG_KINETIC)

	var type : String = stats.getElementKey(_type)
	if type == "DMG_UNTYPED" or battle.stat.RES[type] == 100:
		return [x, 0] #Neutral damage, no changes to final damage, abort.

	var weak : int = 0
	if battle.stat.RES[type] > 100:	weak = 1 #is weak
	else:	weak = 2 #is resistant

	var resistMod = float(battle.stat.RES[type]) * 0.01
	var result = x * resistMod
	return [result, weak]

func finalizeDamage(x) -> int:
	#Apply active defense, reduce damage from guard or barrier.
	#var finalDmg : float = x * (float(battle.AD) * .01)
	var finalDmg = damageProtectionPass(x * core.percent(battle.AD))
	return clamp(finalDmg, 1, core.skill.MAX_DMG) as int

func damage(x : int, data, silent = false) -> Array:
	var temp = HP - x
	var overkill : bool = false
	var defeat : bool = false
	HP = int(clamp(temp, 0.0, maxHealth()))
	if HP == 0: #Defeated!
		if int(abs(temp)) >= maxHealth() / 2: #Check for overkill.
			overkill = true
		defeat()
		defeat = true
	battle.accumulatedDMG += x
	battle.turnDMG += x
	if not silent:
		display.damage([[x, data[0], overkill, data[2]]])
	return [overkill, defeat]

func setAD(x : int, absolute : bool = false):
	if absolute:
		battle.AD = x
	else:
		battle.AD += x
	if battle != null and display != null:
		display.updateAD(battle.AD)
	print("[CHAR_BASE] %s AD is now %03d" % [name, battle.AD])

func defeat():
	status = skill.STATUS_DOWN
	print("%s is down" % name)

func heal(x : int) -> void:
	HP = int(clamp(HP + x, 0, maxHealth()))
	if HP == 0:	defeat()
	battle.turnHeal += x
	display.damage([[-x, false, false, 0]])

func overHeal(x, y):
	var temp = maxHealth() + y
	HP = int(clamp(HP+x, 0, temp))
	if HP == 0:	defeat()
	battle.turnHeal += x
	display.damage([[-x, false, false, 0]])

func inflict(x):
	status = x if HP > 0 else skill.STATUS_DOWN
	display.message(skill.statusInfo[x].name, false, skill.statusInfo[x].color)

func checkProtect(S):
	if battle.protectedBy.empty() or S.category != skill.CAT_ATTACK:
		if S.category == skill.CAT_ATTACK: print("%s is not protected by anyone" % [name])
		return [false, self]
	else:
		for i in battle.protectedBy:
			print("%s is protecting %s, chance: %s" % [i[0].name, name, i[1]])
			if core.chance(i[1]) and i[0].filter(S.filter):
				print("%s intercepted the attack! (chance: %s)" % [i[0].name, i[1]])
				return [true, i[0]]
		return [false, self]

func addEffect(S, level, user):
	#TODO: Effects with duration 0 should be added to the stack anyway and removed at the end of turn.
	if S != null:
		var holder = null
		match S.effectType:
			skill.EFFTYPE_BUFF:
				holder = battle.buff
			skill.EFFTYPE_DEBUFF:
				holder = battle.debuff
			_:
				holder = battle.effect
		var tempLV = int(clamp(level - 1, 0, 9))
		var E = [S, tempLV, S.effectDuration[tempLV], user]
		var check = checkEffectRefresh(holder, E)
		if check != null:
			refreshEffect(check, E, holder)
		else:
			print("Adding effect %sL%s to %s, duration %s" % [S.name, level, user.name, E[2]])
			holder.push_back(E)
			initEffect(E, true)
			display.message(S.name, false, "FF0000" if S.effectType == skill.EFFTYPE_DEBUFF else "3252FF")


func refreshEffect(E, data, holder):
	match E[0].effectIfActive:
		skill.EFFCOLL_REFRESH:
			print("[%s] Refreshing effect duration to %s." % [E[0].name, data[2]])
			E[2] = data[2]
		skill.EFFCOLL_ADD:
			print("[%s] Adding effect duration to %s." % [E[0].name, E[2] + data[2]])
			E[2] += data[2]
		skill.EFFCOLL_NULLIFY:
			print("[%s] Cancelling effect." % [E[0].name])
			removeEffect(E[0], holder)
		skill.EFFCOLL_FAIL:
			print("[%s] Effect already set, failed." % [E[0].name])

func checkEffectRefresh(list, E):
	if list.empty():
		return null
	for i in list:
		if i[0] == E[0]:
			return i
	return null

func checkEffects(A, runEF = false):
	if A != null:
		for i in range(A.size()):
			initEffect(A[i], runEF)

func findEffects(S) -> bool:
	if S != null:
		for holder in [battle.buff, battle.debuff, battle.effect]:
			for i in holder:
				if i[0] == S:
					return true
	return false

func initEffect(E, runEF = false) -> void:
	var S = E[0]
	var level = E[1]
	if S.effect & skill.EFFECT_STATS:
		calculateEffectStats(S, level)
	if S.effect & skill.EFFECT_SPECIAL and runEF:
		skill.processEF(S, level + 1, E[3], self)

func calculateEffectStats(S, level):
	var temp = null
	var stdout = str("%s stat changes from %s:" % [name, S.name])
	var K = skill.EffectStat
	for key in K:
		if S.effectStatBonus.has(key):
			temp = S.effectStatBonus[key]
			match key:
				"EFFSTAT_BASE":
					for i in stats.STATS:
						if temp.has(i) and S.effectStats & K.EFFSTAT_BASE:
							battle.stat[i] += temp[i][level]
							stdout += str("%s+%s " % [i, temp[i][level]])
				"EFFSTAT_BASEMULT":
					for i in stats.STATS:
						if temp.has(i) and S.effectStats & K.EFFSTAT_BASEMULT:
							battle.statmult[i] += temp[i][level]
							stdout += str("%s+%s%% " % [i, temp[i][level]])
				"EFFSTAT_OFF":
					for i in stats.ELEMENTS:
						if temp.has(i) and S.effectStats & K.EFFSTAT_OFF:
							battle.stat.OFF[i] += temp[i][level]
							stdout += str("%s+%s " % [i, temp[i][level]])
				"EFFSTAT_RES":
					for i in stats.ELEMENTS:
						if temp.has(i) and S.effectStats & K.EFFSTAT_RES:
							battle.stat.RES[i] += temp[i][level]
							stdout += str("%s+%s " % [i, temp[i][level]])
				"EFFSTAT_GUARD":
					if S.effectStats & K.EFFSTAT_GUARD:
						battle.guard += temp[level]
						stdout += str("Guard+%s " % [temp[level]])
				"EFFSTAT_BARRIER":
					if S.effectStats & K.EFFSTAT_BARRIER:
						battle.barrier += temp[level]
						stdout += str("Barrier+%s " % [temp[level]])
				"EFFSTAT_EVASION":
					if S.effectStats & K.EFFSTAT_EVASION:
						stdout += str("Evasion+%s " % [temp[level]])
				"EFFSTAT_DECOY":
					if S.effectStats & K.EFFSTAT_DECOY:
						battle.decoy += temp[level]
						stdout += str("Drawrate+%s " % [temp[level]])
	print(stdout)

func updateEffects(holder, defer):
	var current = null
	var tempHolder = []
	var S = null
	for i in range(holder.size()):
		current = holder[i]
		S = current[0]
		current[2] -= 1
		if current[2] < 0:
			print("[updateEffects] Effect %sL%02d expired" % [current[0].name, current[1] + 1])
			if S.effect & skill.EFFECT_ONEND:
				defer.push_back( [S, current[1], current[3], self] )
		else:
			tempHolder.push_back(current)
	return tempHolder

func removeEffect(E, holder):
	for i in range(holder.size()):
		if holder[i][0] == E:
			print("Removed %s" % holder[i][0].name)
			holder.remove(i)
			return

func dodgeAttack(user):
	battle.turnDodges += 1
	display.message("MISS", false, "888888")

func canAct() -> bool:
	match status:
		skill.STATUS_DOWN:    return false
		skill.STATUS_STASIS:  return false
		skill.STATUS_PARA:    return battle.paralyzed
		skill.STATUS_STUN:    return false
		_:                    return true

func canFollow(S, level, target) -> bool:
	if canAct():
		if target.filter(S.filter):
			return true
	return false

func updateFollows() -> void:
	var newFollows : Array = []
	for i in battle.follow:
		if i[1] > 0:
			newFollows.push_front(i)
	battle.follow = newFollows

func canCounter(target, element: int, data: Array):
	var C = battle.counter
	if C[2] != null and C[5] > 0:
		if C[4] == 0 or C[4] == element:
			if canFollow(C[2], C[3], target) and core.chance(C[0]):
				C[0] -= C[1]
				C[5] -= 1
				return [true, [self, C[0], C[1], C[2], C[3], C[4]]]
	return [false, null]

func isAble() -> bool:
	return false if status == skill.STATUS_DOWN else true

func filter(f) -> bool:
	match f:
		skill.FILTER_ALIVE:
			return false if (status == skill.STATUS_DOWN or status == skill.STATUS_STASIS) else true
		skill.FILTER_ALIVE_OR_STASIS:
			return false if status == skill.STATUS_DOWN else true
		skill.FILTER_DOWN:
			return false if status != skill.STATUS_DOWN else true
		skill.FILTER_STASIS:
			return true if status == skill.STATUS_STASIS else false
		skill.FILTER_STATUS:
			return false if ( status != skill.STATUS_NONE and status != skill.STATUS_DOWN ) else true
		skill.FILTER_DISABLE:
			return true
		_:
			return true

func refreshRow() -> void:
	row = 0 if slot < group.ROW_SIZE else 1

func setInitAD(S, level) -> void:
	setAD(S.initAD[level], true)
	print("[SKILL][setInitAD] Active Defense set to %d" % battle.AD)

func useBattleSkill(state, act:int, S, level:int, targets, WP = null, IT = null) -> void:
	core.skill.process(S, level, self, targets, WP, IT)
