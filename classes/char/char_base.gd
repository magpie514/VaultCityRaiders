var stats = core.stats
var skill = core.skill

enum { #Flags for scripted fights.
	EVENTFLAGS_NONE =       0x0000,     #Normal operation
	EVENTFLAGS_INVINCIBLE = 0x0001,     #Character has plot armor and negates most damage.
}


# Basic stats ##################################################################
var name:String      = ""   #Character's given name.
var level:int        = 0	 #EXP level
var condition:int    = 0    #Condition (Primary)
var condition2:int   = 0	 #Condition (Secondary) #TODO: Move to battle stats.

var HP:int           = 0    #Character's vital (HP)
var statBase         = stats.create()	#Base stats
var statFinal        = stats.create()  #Calculated stats
var battle           = null            #Battle stats (See createBattleStats())

# Battle display ###############################################################
var display            = null      #Reference to the character's UI element for quick access.
var energyColor:String = "#AAFFFF" #Color used for certain effects.
# Miscelaneous shortcut vars ###################################################
var slot:int = 0 #Character's position slot in its group.
var row:int  = 0 #Character's calculated row
var side:int = 0 #Quick ally/enemy reference. Mostly for text coloring.
var group = null #Reference to the character's group.

class BattleStats:
	# Core stats ################################################################################
	var stat = core.stats.create()    #Calculated battle stats
	var statmult : Dictionary = {}    #Stat multipliers
	var over:int = 33 setget set_over #Over counter
	# Statistics ################################################################################
	var accumulatedDMG:int = 0        #Damage accumulated during current battle
	var accumulatedDealtDMG:int = 0   #Damage dealt accumulated during current battle
	var defeats:int = 0               #Number of enemies defeated during current battle.
	var resistedHits:int = 0          #Number of attacks that hit an elemental resistance this turn
	var weaknessHits:int = 0          #Number of attacks that hit an elemental weakness this turn
	var turnDMG:int = 0               #Damage accumulated during current turn
	var turnDealtDMG : int = 0        #Damage dealt during current turn
	var turnHits:int = 0              #Number of hits this turn
	var turnDodges:int = 0            #Number of times attacks were dodged this turn
	var turnHeal:int = 0              #Amount of health restored this turn
	# Statistics to implement
	var turnAfflictions:int = 0       #Amount of condition afflictions this turn.
	var turnHealedAfflictions:int = 0 #Amount of healed afflictions this turn.
	# Switches ##################################################################################
	var turnActed:bool = false        #True if character acted this turn
	var paralyzed:bool = false        #If true, character is unable to act due to paralysis this turn.
	var panic:bool = false		       #If true, character is panicing and unable to act for this turn.
	var scanned:bool = false          #If scanned, use the scanned resists set.
	# Buffs/Debuffs/Effects #####################################################################
	var buff:Array = []              #Active buffs (stack of 3)
	var debuff:Array = []            #Active debuffs (stack of 3)
	var effect:Array = []            #Active special effects (max 8, will fail if no slots)
	var eventEffect:Array = []       #Active event-based effects (max 8)
	var damageEffect:Array = []      #Damage over time effects (max 4)
	# Onhit activations #########################################################################
	var follow:Array = []            #Same as above, but used as a buff to add CODE_FL skills to the user's own actions.
	var chase:Array = []             #Array of arrays [user, chance, decrement, skill, level], runs CODE_FL of that skill.
	var counter:Array = [100, 100, null, 0, core.stats.ELEMENTS.DMG_UNTYPED, 3, core.skill.PARRY_NONE]
	var delayed:Array = []           #Array of arrays [user, countdown, skill, level] Similar to above, a delayed skill will activate after X turns
	# Defensive stats ###########################################################################
	var AD:int = 100                 #Active Defense. Global final damage multiplier.
	var decoy:int = 0                #Chance to draw enemy attacks to self.
	var guard:int = 0                #Prevents an amount of damage. Like a health buffer.
	var absoluteGuard:int = 0        #Absolute Guard. Is it not depleted over turns and takes over regular guard until depleted.
	var barrier:int = 0              #Nullifies X damage from the received total.
	var dodge:int = 0                #Dodge rate%
	var forceDodge:int = 0           #Always dodges X attacks this turn unless they are set to not miss
	var chain:int = 0                #Chain counter.
	var parry:Array = [100, 33, core.skill.PARRY_NONE]
	var protectedBy:Array = []	     #Array of arrays, [pointer to defender, chance of defending]
	var defending:bool = false       #Character is marked as defending until the end of the turn.
	var endure:bool = false          #Character is enduring, will remain at 1HP.
	var adamant:bool = false          #Character will endure a fatal blow if at full health.
	# Item use stats ############################################################################
	var itemSPD:int = 090            #Item use speed.
	var itemAD:int  = 110            #Item use AD set.
	# Misc stats ################################################################################
	var FEbonus:int = 0              #Added to elemental field bonus.
	var eventFlags:int = 0           #Event special flags such as plot armor.
	var overheat : int = 0           #Reduces by 1 per turn. Prevents overheat skills from being used.
	var lastAction = null
	var overAction:Array = []        #Temporary storage for Over actions while AI or player are choosing.
	func set_over(x:int) -> void:
		over = core.clampi(x, 0, 100)

	func turn_reset() -> void: #Standard reset when a new battle turn begins.
		self.turnDMG = 0
		self.turnDealtDMG = 0
		self.turnDodges = 0
		self.turnHeal = 0
		self.turnActed = false
		self.turnHits = 0
		self.resistedHits = 0
		self.weaknessHits = 0
		self.decoy = 0
		self.guard = 0
		self.barrier = 0
		self.forceDodge = 0
		self.protectedBy.clear()
		self.defending = false
		self.endure = false
		self.adamant = false #Might be better to not unset it per turn. We'll see.
		self.itemSPD = 90
		self.itemAD = 110
		self.follow.clear()
		self.chase.clear()
		self.overAction.clear()
		self.FEbonus = 0
		self.AD = 100

	func resetCounter() -> void:
		counter[0] = 0    #Counter chance
		counter[1] = 100  #Counter decrease
		counter[2] = null #Counter skill TID
		counter[3] = 0    #Counter level
		counter[4] = 0    #Counter element filter
		counter[5] = 0    #Counter max amount
		counter[6] = core.skill.PARRY_NONE #Counter type filter

	func resetParry() -> void:
		parry[0] = 0                 #Parry chance
		parry[1] = 100               #Parry chance decrease
		parry[2] = core.skill.PARRY_NONE  #Parry attack type


###############################################################################

func createBattleStats():
	return BattleStats.new()

func checkParalysis() -> bool:
	if condition != skill.CONDITION_PARALYSIS:
		return false
	else:
		return true if core.chance(50) else false

func clampHealth() -> void:
	HP = core.clampi(HP, 0, maxHealth())

func setGuard(x:int, elem:int = 0, flags:int = 0, elemMult:float = 1.0) -> void:
	var temp:float = .0
	if flags & core.skill.OPFLAGS_VALUE_PERCENT:
		temp = float(maxHealth()) * core.percent(x)
	else:
		temp = float(x)
	if elem != 0:
		temp = core.battle.control.state.field.calculate(temp, elem, elemMult)
	var result:int = round(temp) as int
	if flags & core.skill.OPFLAGS_VALUE_ABSOLUTE:
		battle.guard = result
	else:
		if battle.absoluteGuard > 0:
			battle.absoluteGuard += result
		else:
			battle.guard += result

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
	condition2 = condition2 & ~core.skill.CONDITION2_STUN
	battle.dodge = 0
	recalculateStats()
	stats.copy(battle.stat, statFinal)
	resetBattleStatMultipliers()
	battle.turn_reset()                      #Reset battle specific stats.
	battle.AD = 100                          #Reset Active Defense. Done here in case a base modifier is eventually put in place.
	battle.resetCounter()
	battle.resetParry()
	checkEffects(battle.buff       , true)   #Calculate effects from buffs.
	checkEffects(battle.debuff     , true)   #Same with debuffs.
	checkEffects(battle.effect     , true)   #Then special effects such as active passives and such.
	checkEffects(battle.eventEffect, true)   #And finally effects from scripted events.
	applyBattleStatMultipliers()
	#TODO: Set paralysis value as a random bool. Only check if it's true/false if paralysis is the current main condition.
	#Paralysis calculated at the end of the turn in case any effect adds or removes paralysis.
	battle.paralyzed = checkParalysis()      #Check for paralysis. If true, the character can't act normally.




func updateBattleStats() -> void:
	recalculateStats()
	stats.copy(battle.stat, statFinal)
	resetBattleStatMultipliers()
	checkEffects(battle.buff)
	checkEffects(battle.debuff)
	applyBattleStatMultipliers()

func endBattleTurn(defer) -> void:
	#Reset guard and barrier values now so they don't show in the player UI.
	battle.guard   = 0
	battle.barrier = 0
	#Placeholder for skills that cause overheat.
	if battle.overheat > 0:
		battle.overheat -= 1
		if battle.overheat == 0:
			battle.overheat = 0
	if condition2 & skill.CONDITION2_STUN:
		condition2 = condition2 & ~skill.CONDITION2_STUN

	battle.buff   = updateEffects(battle.buff  , defer)
	battle.debuff = updateEffects(battle.debuff, defer)
	battle.overAction.clear()
	#Apply damage effects
	damageEffects()

func initBattle() -> void:
	battle = createBattleStats()
	initBattleTurn()

func maxHealth():
	return statFinal.MHP

func getHealthN(): #Get normalized health as a float from 0 to 1.
	return float(float(HP) / float(maxHealth()))

func getHealthPercent(x:int):
	return round(float(maxHealth()) * core.percent(x)) as int

func fullHeal() -> void: #Set health to max health.
	self.HP = maxHealth()


# Over functions ##################################
func setOver(x:int, absolute:bool = false) -> void:
	if battle != null:
		if absolute:
			battle.over = x
		else:
			battle.over += x
		battle.over = core.clampi(battle.over, 0, 100)

func getOverN() -> float:
	#Not meant to be called out of battle.
	return core.percent(battle.over)

func calcSPD(spd:int) -> int:
	var AGI:float = battle.stat.AGI as float
	var equipSpeedMod:float = float(getEquipSpeedMod() + 100)
	var skillSpeedMod:float = float(spd) * 0.01
	#return (equipSpeedMod * AGI * skillSpeedMod * mod * statBonus.mult.SPD) / 10000
	return int((equipSpeedMod * AGI * skillSpeedMod * 100) / 10000)

func getEquipSpeedMod():
	return 0

func damageProtectionPass(x:int, info, ignoreDefs = false) -> int: # Modify damage according to defenses and deplete said defenses if applicable.
	if battle.eventFlags & EVENTFLAGS_INVINCIBLE:
		info.barrierFullBlock = true
		print("[CHAR_BASE][damageProtectionPass] %s has plot armor." % name)
		return 0 #Character has plot armor, act as a full barrier block.

	if ignoreDefs: return x #Incoming damage ignores defenses.

	if battle.absoluteGuard > 0: #Absolute Guard is active, prioritize over regular.
		var check:int = battle.absoluteGuard - x
		if check > 0:
			x = x - battle.absoluteGuard
			battle.absoluteGuard = check
		else: #Guard Break.
			x -= battle.absoluteGuard
			battle.absoluteGuard = 0
			battle.guard = 0
			info.guardBreak = true
	else: #No Absolute Guard, check regular.
		if battle.guard > 0:
			var check:int = battle.guard - x
			if check > 0:
				x -= battle.guard
				battle.guard = check
			else: #Guard Break
				x -= battle.guard
				battle.guard = 0
				info.guardBreak = true
	if battle.barrier > 0: #Process barrier afterwards.
		x = x - battle.barrier
		if x <= 0: #Full block, damage was completely negated.
			info.barrierFullBlock = true
	return x

func damageResistModifier(x:float, _type:int, energyDMG:bool) -> Array:
	# Apply Kinetic/Energy damage modifiers first..
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

func finalizeDamage(x, info, ignoreDefs:bool = false, nocap:bool = false) -> int:
	#Apply active defense, reduce damage from guard or barrier.
	#var finalDmg : float = x * (float(battle.AD) * .01)
	var finalDmg = damageProtectionPass(x * core.percent(battle.AD), info, ignoreDefs)
	return core.clampi(finalDmg, 1, core.skill.MAX_DMG if not nocap else 2^63)

func defeatMessage() -> String:
	return "%s is down!" % name

func damage(x:int, data, silent:bool = false, nonlethal:bool = false) -> Array:
	var temp = HP - x
	var overkill:bool = false
	var defeat:bool   = false
	var full:bool     = true if HP >= maxHealth() else false
	var HP1:int = HP
	HP = int(clamp(temp, 1.0 if nonlethal else 0.0, maxHealth()))
	if x > 0 and nonlethal and HP == 1: display.message("Spared!", false, "EFEFEF")
	var HPdelta:int = HP1 - HP
	if HP == 0: #Defeated!
		if int(abs(temp)) >= maxHealth() / 2: #Check for overkill.
			overkill = true
		if battle.adamant and full:
			HP = 1
			display.message("Survived!", false, "EFEFEF")
			#TODO: Should display some animation and play a sound here.
		else:
			defeat()
			defeat = true
	battle.accumulatedDMG += HPdelta
	battle.turnDMG += HPdelta
	if not silent:
		display.damage([[x, data[0], overkill, data[2], data[3]]])
	return [overkill, defeat]

func setAD(x:int, absolute:bool = false) -> void: #Set active defense.
	if absolute:
		battle.AD = x
	else:
		battle.AD += x
	if battle != null and display != null:
		display.updateAD(battle.AD)
	print("[CHAR_BASE] %s AD is now %03d" % [name, battle.AD])

func defeat() -> void: #Process defeat.
	condition = skill.CONDITION_DOWN
	HP = 0 #Set HP to zero in case this was called outside of damage()
	#Ensure some things are removed on defeat.
	if battle != null:
		battle.follow.clear()
		battle.chase.clear()
		battle.resetCounter()
		battle.resetParry()
		battle.counter[0] = 0
		battle.AD = 100
		battle.dodge = 0
		battle.forceDodge = 0
		battle.defending = false
		battle.buff.clear()
		battle.debuff.clear()
		battle.effect.clear()
		charge(false)
	print("[CHAR_BASE][DEFEAT] %s is down." % name)

# Healing #########################################################################################
func heal(x:int) -> void:
	HP = int(clamp(HP + x, 0, maxHealth()))
	if HP == 0:	defeat()
	battle.turnHeal += x
	display.damage([[-x, false, false, 0, null]])

func overHeal(x, y) -> void:
	var temp = maxHealth() + y
	HP = clamp(HP+x, 0, temp) as int
	if HP == 0:	defeat()
	battle.turnHeal += x
	display.damage([[-x, false, false, 0, null]])

func revive(x:int) -> void:
	if condition == skill.CONDITION_DOWN:
		condition = skill.CONDITION_GREEN
		heal(x)
		display.update()

func inflict(x) -> void:
	condition = x if HP > 0 else skill.CONDITION_DOWN
	display.message(skill.statusInfo[x].name, false, skill.statusInfo[x].color)

func addInflict(x:int) -> void:
	match x:
		skill.CONDITION_DOWN:
			defeat()
		skill.CONDITION_CRYO:
			condition = skill.CONDITION_CRYO
		skill.CONDITION_NARCOSIS:
			condition = skill.CONDITION_NARCOSIS
		skill.CONDITION_SEAL:
			condition = skill.CONDITION_SEAL
		skill.CONDITION_PARALYSIS:
			condition = skill.CONDITION_PARALYSIS
		skill.CONDITION_BLIND:
			condition2 = condition2 | skill.CONDITION_BLIND
		skill.CONDITION_STUN:
			condition2 = condition2 | skill.CONDITION_STUN
		skill.CONDITION_CURSE:
			condition2 = condition2 | skill.CONDITION_CURSE
		skill.CONDITION_PANIC:
			condition2 = condition2 | skill.CONDITION_PANIC
		skill.CONDITION_STASIS:
			condition2 = condition2 | skill.CONDITION_STASIS

func tryInflict(user, cond:int, power:int, crit:int) -> void:
	#TODO: See something about hit checks. Like a way to not have to do "if_connect" all the time?
	if condition != skill.CONDITION_DOWN:
		var critf:float = crit as float * .01
		var comp:float = ( ((user.battle.stat.LUC * 3) as float + 76.5) / ((battle.stat.LUC * 3) as float + 76.5) ) * 10
		var rate:float = 0
		if   comp as int <= 2      : rate = critf
		elif comp > 2 and comp < 50: rate = critf * comp
		else                       : rate = critf * 50.0
		var finalrate:int = clamp(rate * 100, 0, 1500) as int
		if randi() % 1000 <= finalrate: #Critical affliction. Bypass check.
			addInflict(cond)
		else: #Regular affliction. #TODO: Apply defenses.
			addInflict(cond)

func checkProtect(S) -> Array:
	if battle.protectedBy.empty() or S.category != skill.CAT_ATTACK:
		if S.category == skill.CAT_ATTACK: print("%s is not protected by anyone" % [name])
		return [false, self]
	else:
		for i in battle.protectedBy:
			print("%s is protecting %s, chance: %s" % [i[0].name, name, i[1]])
			if core.chance(i[1]) and i[0].filter(S):
				print("%s intercepted the attack! (chance: %s)" % [i[0].name, i[1]])
				return [true, i[0]]
		return [false, self]


# Effect processing ###############################################################################
func newEffect(S, lv:int, user) -> Array:
	var E:Array = [
		S,                    #E[0]: Skill pointer.
		lv,                   #E[1]: Skill level (0-9).
		S.effectDuration[lv], #E[2]: Effect duration counter.
		user,                 #E[3]: Pointer to effect caster.
		0,                    #E[4]: Effect value.
	]
	return E

func addEffect(S, lv:int, user) -> void:
	#TODO: Effects with duration 0 should be added to the stack anyway and removed at the end of turn.
	if S == null:
		print("[!][CHAR_BASE][addEffect] Null skill, aborting")
		return
	var holder:Array
	var mcolor:String
	match S.effectType:
		skill.EFFTYPE_BUFF:
			holder = battle.buff
			mcolor = skill.messageColors.buff
		skill.EFFTYPE_DEBUFF:
			holder = battle.debuff
			mcolor = skill.messageColors.debuff
		_:
			holder = battle.effect
			mcolor = skill.messageColors.effect
	var tempLV:int = core.clampi(lv - 1, 0, 9)
	var E:Array    = newEffect(S, tempLV, user)
	var check      = checkEffectRefresh(holder, E)  #Check if effect is already active.
	if check != null: #If it is, apply refresh as per skill settings.
		refreshEffect(check, E, holder)
	else: #Add the new effect to the list otherwise.
		print("[CHAR_BASE][addEffect] Adding %sL%s to %s, duration %s" % [S.name, tempLV, user.name, E[2]])
		holder.push_back(E)
		initEffect(E, true)
		display.message(S.name, false, mcolor)


func refreshEffect(E:Array, data:Array, holder:Array) -> void:
	match E[0].effectIfActive:
		skill.EFFCOLL_REFRESH:
			print("[CHAR_BASE][refreshEffect] %s: Refreshing effect duration to %s." % [E[0].name, data[2]])
			E[2] = data[2]
		skill.EFFCOLL_ADD:
			print("[CHAR_BASE][refreshEffect] %s: Adding effect duration to %s." % [E[0].name, E[2] + data[2]])
			E[2] += data[2]
		skill.EFFCOLL_NULLIFY:
			print("[CHAR_BASE][refreshEffect] %s: Cancelling effect." % E[0].name)
			removeEffect(E[0], holder)
		skill.EFFCOLL_FAIL:
			print("[CHAR_BASE][refreshEffect] %s: Effect already set, failed." % E[0].name)
			return

func checkEffectRefresh(list:Array, E):
	if list.empty(): return null
	for E_ in list: #Check list for instances of this effect.
		if E_[0] == E[0]: return E_ #Return immediately.
	return null

func checkEffects(A, runEF = false) -> void:
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

func initEffect(E, runEF:bool = false) -> void:
	var S = E[0]
	if S.effectStatBonus != null:
		calculateEffectStats(S, E[1])
	if S.effect & skill.EFFECT_SPECIAL and runEF:
		skill.runExtraCode(S, E[1] + 1, E[3], skill.CODE_EF, self)


func calculateEffectStats(S, lv:int) -> void: # Apply stat changes from an active skill effect.
	var temp = null
	var stdout = str("%s stat changes from %s:" % [name, S.name])
	for key in core.stats.STATS: #Get stat keys and look for bonuses.
		if key in S.effectStatBonus:
			temp = S.effectStatBonus[key]
			battle.stat[key] += temp[lv]
			stdout += str("%s+%s " % [key, temp[lv]])
		var tmpKey = str(key,'_MULT') #Now look for base stat multipliers.
		if tmpKey in S.effectStatBonus:
			temp = S.effectStatBonus[tmpKey]
			battle.statmult[key] += temp[lv]
			stdout += str("%s+%s " % [tmpKey, temp[lv]])
	for key in core.stats.ELEMENT_MOD_TABLE: #Element bonuses.
		if key in S.effectStatBonus:
			temp = S.effectStatBonus[key]
			core.stats.elementalModApply(battle.stat, key, temp[lv])
			stdout += str("%s+%s " % [key, temp[lv]])
	if 'GUARD' in S.effectStatBonus:
		battle.guard += S.effectStatBonus['GUARD'][lv]
		stdout += str("Guard+%s " % S.effectStatBonus['GUARD'][lv])
	if 'BARRIER' in S.effectStatBonus:
		battle.barrier += S.effectStatBonus['BARRIER'][lv]
		stdout += str("Barrier+%s " % S.effectStatBonus['BARRIER'][lv])
	if 'EVASION' in S.effectStatBonus:
		battle.dodge += S.effectStatBonus['EVASION'][lv]
		stdout += str("Dodge+%s " % S.effectStatBonus['EVASION'][lv])
	if 'DECOY' in S.effectStatBonus:
		battle.decoy += S.effectStatBonus['DECOY'][lv]
		stdout += str("Decoy+%s " % S.effectStatBonus['DECOY'][lv])
	if 'FE_BONUS' in S.effectStatBonus:
		battle.FEbonus += S.effectStatBonus['FE_BONUS'][lv]
		stdout += str("Field Effect bonus+%s " % S.effectStatBonus['FE_BONUS'][lv])
	if 'ITEM_SPD' in S.effectStatBonus:
		battle.itemSPD += S.effectStatBonus['ITEM_SPD'][lv]
		stdout += str("Item use speed+%s " % S.effectStatBonus['ITEM_SPD'][lv])
	if 'ITEM_AD' in S.effectStatBonus:
		battle.itemAD += S.effectStatBonus['ITEM_AD'][lv]
		stdout += str("Item use AD+%s " % S.effectStatBonus['ITEM_AD'][lv])
	print(stdout)

func updateEffects(holder, defer) -> Array:
	var current = null
	var tempHolder:Array = []
	for i in range(holder.size()):
		current = holder[i]
		var S:Dictionary = current[0]
		current[2] -= 1 #Reduce effect time.
		if current[2] < 0:
			print("[CHAR_BASE][updateEffects] %sL%02d expired" % [current[0].name, current[1] + 1])
			if S.effect & skill.EFFECT_ONEND:
				defer.push_back( [S, current[1], current[3], self] )
		else:
			tempHolder.push_back(current)
	return tempHolder

func removeEffect(E, holder) -> void:
	for i in range(holder.size()):
		if holder[i][0] == E:
			print("Removed %s" % holder[i][0].name)
			holder.remove(i)
			return

# Damage Effects (damage over time) ###############################################################

func newDamageEffect(S, dmg:int, duration:int, element:int, user) -> Array:
	var DE:Array = [
		S,
		dmg,
		duration,
		element,
		user,
	]
	return DE

func processDamageEffect(DE) -> bool:
	var info = damage(DE[1], [false, false, 0, null])
	#display.damage([[DE[1], false, false, 0, null]])
	return info[1]

func calculateDamageEffects() -> int: #Gets an estimate of how much damage the character is going to receive at the end of the turn.
	var result:int = 0
	for DE in battle.damageEffect:
		result += DE[1]
	return result


func damageEffects() -> void:
	for DE in battle.damageEffect:
		print("[CHAR_BASE][damageEffects] ", DE)
		var defeats:bool = processDamageEffect(DE)
		if defeats: return


func addDamageEffect(user, S, val:int) -> void: #Add the damage over time effect.
	for tmp in battle.damageEffect:
		if tmp[0] == S: #Already set, fail or renew.
			print("[CHAR_BASE][addDamageEffect] Already set!")
			return
	var dmg:int = core.clampi((val & 0x0FFFF00) >> 8, 0, 32000)
	var dur:int = core.clampi((val & 0x00000F0) >> 4, 0, 15   )
	var ele:int = core.clampi((val & 0x000000F)     , 0, 10   )
	var DE:Array = newDamageEffect(S, dmg, dur, ele, user)
	print("[CHAR_BASE][addDamageEffect] %s %s %s %s %s" % [DE[0].name, DE[1], DE[2], DE[3], DE[4].name])
	battle.damageEffect.push_back(DE)
	if battle.damageEffect.size() > 4: battle.damageEffect.pop_front()

func tryDamageEffect(user, S, val:int) -> void: #Attempt to inflict a damage over time effect.
	addDamageEffect(user, S, val)

###################################################################################################

func dodgeAttack(user) -> void:
	battle.turnDodges += 1
	display.message("Dodged!", false, "EFEFEF")

func canAct() -> bool: #Checks if char can perform a regular action.
	match condition: #Main Condition check. (TODO: Finish)
		skill.CONDITION_DOWN:      return false
		skill.CONDITION_PARALYSIS: return battle.paralyzed
		skill.CONDITION_NARCOSIS:  return false
		skill.CONDITION_CRYO:      return false
		skill.CONDITION_SEAL: return false
		_: pass
	# Secondary Condition checks.
	if condition2 & skill.CONDITION2_STUN:   return false
	if condition2 & skill.CONDITION2_PANIC:  return battle.panic
	if condition2 & skill.CONDITION2_STASIS: return false
	return true


func canOver() -> bool: #Checks if char can perform Over actions.
	match condition:
		skill.CONDITION_DOWN:  return false #Is defeated and cannot use Over.
		skill.CONDITION_CRYO:  return false #Is frozen and cannot use Over.
		skill.CONDITION_SEAL:  return false #Is sealed and cannot use Over.
		_: pass
	if condition2 & skill.CONDITION2_STASIS: return false
	if condition2 & skill.CONDITION2_PANIC:  return false
	return true

# Followups #######################################################################################

func canFollow(S:Dictionary, lv:int, target) -> bool: #Checks if char can do a followup action like a combo.
	if canAct():
		if target.filter(S):
			return true
	return false

func updateFollows() -> void: #Updates followup actions..
	var newFollows:Array = []
	for i in battle.follow:
		if i[1] > 0:
			newFollows.push_front(i)
	battle.follow = newFollows

# Counters ########################################################################################

func canCounter(target, element:int, data:Array): #Checks if char is able to perform a counter skill.
	var C = battle.counter
	print("[CHAR_BASE][canCounter] Checking for counter...")
	if C[2] != null and C[5] > 0: #Check if skill isn't null and there are enough uses left.
		print("[CHAR_BASE][canCounter] Skill: %s, Chance: %d%%, Uses = %d" % [C[2].name, C[0], C[5]])
		if C[4] == 0 or C[4] == element: #If counter element isn't set to non elemental or element counter is set to this element.
			if canFollow(C[2], C[3], target) and core.chance(C[0]):
				C[0] -= C[1]
				C[5] -= 1
				print("[CHAR_BASE][canCounter] Counter status: Rate:%d%%, Decrement:-%d%%, Skill: %s, Level = %d, Max = %d" % [C[0], C[1], C[2].name, C[3], C[5]])
				return [true, [self, C[0], C[1], C[2], C[3], C[4]]]
	return [false, null]

# Safety checks ###################################################################################

func isAble() -> bool: #Checks if character is active.
	if condition == skill.CONDITION_DOWN: return false
	else                                : return true

func filter(S:Dictionary) -> bool: #Checks if character meets the conditions to be targeted.
	match S.filter:
		skill.FILTER_ALIVE:
			return false if (condition == skill.CONDITION_DOWN or condition2 & skill.CONDITION2_STASIS) else true
		skill.FILTER_ALIVE_OR_STASIS:
			return false if condition == skill.CONDITION_DOWN else true
		skill.FILTER_DOWN:
			return false if condition != skill.CONDITION_DOWN else true
		skill.FILTER_STASIS:
			return true if condition2 & skill.CONDITION2_STASIS else false
		skill.FILTER_STATUS:
			if condition != skill.CONDITION_GREEN and condition != skill.CONDITION_DOWN:
				return false
			elif condition2 == 0: return false
			else                : return true
			#return false if (condition != skill.CONDITION_GREEN and condition != skill.CONDITION_DOWN ) else true
		skill.FILTER_DISABLE:
			return true
		_:
			return true

func refreshRow() -> void: #Updates the value of current row based on position.
	row = 0 if slot < group.ROW_SIZE else 1

func setInitAD(S:Dictionary, lv:int) -> void: #Sets Active Defense before battle resolution.
	setAD(S.initAD[lv], true)
	print("[SKILL][setInitAD] Active Defense set to %d" % battle.AD)

func useBattleSkill(state, act:int, S, lv:int, targets, WP = null, IT = null) -> void:
	core.skill.process(S, lv, self, targets, WP, IT)

func checkRaceType(type) -> bool:
	return false

func charge(x : bool = false) -> void:
	pass
