extends "res://classes/char/char_base.gd"
const DragonGem = preload("res://classes/inventory/item.gd").DragonGem
const DragonGemContainer = preload("res://classes/inventory/item.gd").DragonGemContainer
const DEFAULT = { energyColor = "#4466FF" }
const EXP_TABLE = {
	normal = [
		0000000000,	0000000100,	0000000200,	0000000300,	0000000400,
		0000000500,	0000000600,	0000000700,	0000000800,	0000000900,
		0000001000,	0000001100,	0000001200,	0000001300,	0000001400,
		0000001500,	0000001600,	0000001700,	0000001800,	0000001900,
		0000002000,	0000002100,	0000002200,	0000002300,	0000002400,
		0000002500,	0000002600,	0000002700,	0000002800,	0000002900,
		0000003000,	0000003100,	0000003200,	0000003300,	0000003400,
		0000003500,	0000003600,	0000003700,	0000003800,	0000003900,
		0000004000,	0000004100,	0000004200,	0000004300,	0000004400,
		0000004500,	0000004600,	0000004700,	0000004800,	0000004900,
		0000005000,	0000005100,	0000005200,	0000005300,	0000005400,
		0000005500,	0000005600,	0000005700,	0000005800,	0000005900,
		0000006000,	0000006100,	0000006200,	0000006300,	0000006400,
		0000006500,	0000006600,	0000006700,	0000006800,	0000006900,
		0000007000,	0000007100,	0000007200,	0000007300,	0000007400,
		0000007500,	0000007600,	0000007700,	0000007800,	0000007900,
		0000008000,	0000008100,	0000008200,	0000008300,	0000008400,
		0000008500,	0000008600,	0000008700,	0000008800,	0000008900,
		0000009000,	0000009100,	0000009200,	0000009300,	0000009400,
		0000009500,	0000009600,	0000009700,	0000009800,	0000009900,
		0000010000,
	]
}
const WEAPON_SLOT = [0, 1, 2, 3]
const ARMOR_SLOT =  [4]
const GEAR_SLOT =   [5, 6, 7]

enum {
	LINK_NONE,

	#Regular links
	LINK_NAKAMA,
	LINK_FRIEND,
	LINK_FAMILY,
	LINK_LOVER,
	LINK_TEACHER,
	LINK_APPRENTICE,
	LINK_PROMISE,
	LINK_COWORKER,
	LINK_RIVAL,
	LINK_ENEMY,
	LINK_RESPECT,

	#Unique links
	LINK_BESTFRIEND,
	LINK_TRUELOVE,
	LINK_THERIVAL,
	LINK_MENTOR,
}

var guildIndex:int  #reference to character's position in the guild list.
var classlib = null  #pointer to class index.
var racelib  = null  #pointer to race index.

var EP:int             = 0    #Energy Points. To use non-weapon skills.
var XP:int             = 0    #Experience points.
var SP:int             = 0    #Skill Points. Gained at level up to raise skills.
var race               = null #TID
var aclass             = null #TID
var extraSkills:Array  = []   #Skills given by equipment or other special things.

var links = null     #Party links. Array of [trust, link1, link2, link3]

var equip = core.Inventory.Equip.new()
var currentWeapon = equip.slot[0]
var DGem:DragonGemContainer #Equipped dragon gems.

var inventory:Array = []
var personalInventorySize:int = 2
var personalInventory:Array = []

# Overrides #######################################################################################

func checkPassives(runEF:bool = false) -> void:
	for i in skills:
		var S = core.lib.skill.getIndex(classlib.skills[i[0]])
		if S.category == skill.CAT_PASSIVE:
			initPassive(S, i[1], runEF)

func hasSkill(what):
	for i in skills:
		if core.tid.compare(classlib.skills[i[0]], what):
			return [ core.lib.skill.getIndex(classlib.skills[i[0]]), i[1] ]
	for i in extraSkills:
		if core.tid.compare(i, what):
			return [ core.lib.skill.getIndex(i[0]), i[1] ]
	return null

func endBattleTurn(defer):
	battle.over += calculateTurnOverGains()
	.endBattleTurn(defer)

func getEquipSpeedMod() -> int:
	return equip.getWeaponSpeedMod(currentWeapon)

func defend() -> void:
	var gain:int = calculateTurnOverGains() / 2
	battle.over += gain
	.defend()

func damagePreventionPass(S, user, elem:int = 0, crit:bool=false) -> bool:
	#Check if inventory items can negate an incoming hit.
	var IT:Array
	if crit:
		IT = group.inventory.canCounterEvent(core.lib.item.COUNTER_CRITICAL, inventory)
		if not IT.empty():
			group.inventory.takeConsumable(IT[0])
			print("\t[SKILL][canHit] %s was protected by %s!" % [name, IT[0].data.lib.name])
			skill.msg("%s was protected by %s!" % [core.battle.control.state.color_name(self), IT[0].data.lib.name])
			display.message(str(">CRIT BLOCKED BY %s" % IT[0].data.lib.name), "00FFFF")
			return false
	IT = group.inventory.canCounterAttack(elem, inventory)
	if not IT.empty() and elem > 0:
		group.inventory.takeConsumable(IT[0])
		print("\t[SKILL][canHit] %s was protected by %s!" % [name, IT[0].data.lib.name])
		skill.msg("%s was protected by %s!" % [core.battle.control.state.color_name(self), IT[0].data.lib.name])
		display.message(str(">ELEM BLOCKED BY %s" % IT[0].data.lib.name), "00FFFF")
		return false
	return .damagePreventionPass(S, user, crit)

func addInflict(x:int) -> void:
#	match(x):
	if x in core.lib.item.COND_COUNTER_CONV:
		var tmp:int = core.lib.item.COND_COUNTER_CONV[x]
		var IT:Array = group.inventory.canCounterEvent(tmp, inventory)
		if not IT.empty():
			group.inventory.takeConsumable(IT[0])
			print("[CHAR_PLAYER][addInflict] %s was protected by %s!" % [name, IT[0].data.lib.name])
			skill.msg("%s was protected by %s!" % [core.battle.control.state.color_name(self), IT[0].data.lib.name])
			display.message(str(">COND BLOCKED BY %s" % IT[0].data.lib.name), "00FFFF")
			battle.conditionDefs[x] = battle.conditionDefsMax[x]
			return
	.addInflict(x)
func recalculateStats() -> void:
	#Get stats from race/class.
	var raceStats = stats.create()
	#TODO: Reset it to race defaults instead.
	stats.resetElementData(raceStats.OFF)
	stats.resetElementData(raceStats.RES)
	stats.setFromSpread(raceStats, racelib.statSpread, level)
	var classStats = stats.create()
	stats.setFromSpread(classStats, classlib.statSpread, level)
	stats.sumInto(statBase, raceStats, classStats)

	#Get stats from equipment.
	extraSkills.clear()
	var gearStats = stats.create()
	currentWeapon.getBonuses(extraSkills, gearStats)
	for i in core.Inventory.Equip.ARMOR_SLOT:
		equip.slot[i].recalculateStats(level)
		equip.slot[i].getBonuses(extraSkills, gearStats)
	for i in range(core.CONDITIONDEFS_DEFAULT.size()):
		conditionDefs[i] = racelib.conditionDefs[i] + classlib.conditionDefs[i]
		conditionDefs[i] += gearStats.CON[i]
	print("[CHAR_PLAYER][recalculateStats] Condition Defenses:", conditionDefs)
	#TODO: Process field skill bonuses.

	#stats.sum(gearStats, equip.calculateWeaponBonuses(extraSkills, currentWeapon))
	#stats.sum(gearStats, equip.calculateArmorBonuses(extraSkills, level))
	#stats.sum(gearStats, equip.calculateGearBonuses())
	print("[CHAR_PLAYER][recalculateStats] ", extraSkills)

	stats.sumInto(statFinal, statBase, gearStats)

func setCharClass(t) -> void:
	aclass = core.tid.from(t)
	classlib = core.lib.aclass.getIndex(aclass)

func setCharRace(t) -> void:
	race = core.tid.from(t)
	racelib = core.lib.race.getIndex(race)

func initSkillList(sk) -> void:
	skills.clear()
	for i in sk:
		skills.push_back([ int(i[0]), int(i[1]) ]) #skill TID, level

func initDict(C):	#Load the character from save data
	side = 0
	self.DGem = DragonGemContainer.new(0)
	self.name = str(C.name)                    #Init adventurer's name
	print("[CHAR][initDict] Initializing %s" % [name])
	setCharRace(C.race)                        #Init adventurer's race and set pointer to it for easy reference.
	setCharClass(C.aclass)                     #Init adventurer's class and set pointer.
	equip.loadWeapons(C.equip)                 #Init adventurer's weapons.    (Slots 0-3)
	equip.loadArmor(C.equip)                   #Init armor, vehicle or frame. (Slot 4)
	equip.loadGear(C.equip)                    #Init gear/accesories.         (Slots 5-7)
	currentWeapon = equip.slot[0]              #Set main weapon as slot 0. TODO: Save last used slot as int?
	equip.currentWeapon = currentWeapon
	self.personalInventorySize = C.personalInventorySize if 'personalInventorySize' in C else 2
	if 'personalInventory' in C:
		for i in C.personalInventory:
			personalInventory.push_back([int(i[0]), core.tid.fromArray(i[1]), i[2].duplicate(true)])
	initSkillList(C.skills)                    #Init adventurer's skill list.
	initLinkList(C.links)                      #Init adventurer's links and trust with other guild members.
	if 'energyColor' in C:
		energyColor = C.energyColor
	else:
		energyColor = DEFAULT.energyColor
	setXP(C.XP)                                #Set level from experience points.
	recalculateStats()
	fullHeal()
	print(getTooltip())

func initJson(json):
	pass

func revive(x: int) -> void:
	.revive(x)

func defeat() -> void:
	var IT:Array = group.inventory.canCounterEvent(core.lib.item.COUNTER_DEFEAT, self.inventory)
	if not IT.empty():
		group.inventory.takeConsumable(IT[0])
		print("\t[CHAR_BASE][defeat] %s was protected by %s!" % [name, IT[0].data.lib.name])
		if battle != null:
			skill.msg("%s was hurt, but held on thanks to the %s!" % [name, IT[0].data.lib.name])
			display.message(str(">HELD ON USING %s" % IT[0].data.lib.name), "00FFFF")
			HP = getHealthPercent(IT[0].data.level + 1)
			return
	.defeat()

func getTooltip() -> String:
	return "%s\nLv.%s %s %s\n%s" % [name, level, racelib.name, classlib.name, core.stats.print(statFinal)]

func setXP(val:int) -> void: #Silently set level from experience. Used at initialization.
	XP = val
	var levelup = setLevel()
	recalculateStats()

func giveXP(val:int) -> void: #Increases party member's experience by val.
	self.XP = XP + val
	var levelup = setLevel()
	if levelup: #TODO: Notify the interface to show a warning and play some jingle.
		recalculateStats()

func setLevel() -> bool: #Calculate current level based on EXP.
	var levelup = false
	while level < 100 and XP >= EXP_TABLE['normal'][self.level]:
		self.level += 1
		levelup = true
	return levelup

func setWeapon(WP) -> void: #Sets current weapon.
	if currentWeapon != WP:
		equip.currentWeapon = WP
		currentWeapon = WP
		updateBattleStats()

func getSkillTID(t):
	return classlib.skills[t[0]]

func checkRaceType(type:int) -> bool:
	var result:bool = false
	if type in race.lib.race:
		result = true
	return result

func fullRepair(all:bool=true) -> void:
	equip.fullRepair(all)

func partialRepair(val:int, all:bool=true) -> void:
	equip.partialRepair(val,all)


# Over calculation ############################################################

func calculateTurnOverLink(who) -> int:
	var gain : int = 0
	var trust : int = links[who.slot][0]
	for i in range(3):
		match(links[who.slot][i]):
			LINK_FRIEND:
				match(who.condition):
					skill.CONDITION_GREEN:
						gain += valueByTrust([1, 2, 3], trust)
					skill.CONDITION_DOWN:
						gain += valueByTrust([1, 1, 2], trust)
			LINK_NAKAMA:
				match(who.condition):
					skill.CONDITION_GREEN:
						gain += valueByTrust([1, 1, 2], trust)
					skill.CONDITION_DOWN:
						gain += valueByTrust([1, 2, 2], trust)
			LINK_LOVER:
				match(who.condition):
					skill.CONDITION_GREEN:
						gain += valueByTrust([2, 2, 3], trust)
					skill.CONDITION_DOWN:
						gain += valueByTrust([3, 3, 3], trust)
			LINK_FAMILY:
				match(who.condition):
					skill.CONDITION_GREEN:
						gain += valueByTrust([0, 0, 1], trust)
					skill.CONDITION_DOWN:
						gain += valueByTrust([1, 1, 3], trust)
			LINK_BESTFRIEND:
				match(who.condition):
					skill.CONDITION_GREEN:
						gain += valueByTrust([2, 3, 3], trust)
					skill.CONDITION_DOWN:
						gain += valueByTrust([2, 2, 3], trust)
			LINK_TRUELOVE:
				match(who.condition):
					skill.CONDITION_GREEN:
						gain += valueByTrust([2, 3, 3], trust)
					skill.CONDITION_DOWN:
						gain += valueByTrust([3, 3, 3], trust)
			LINK_APPRENTICE:
				match(who.condition):
					skill.CONDITION_GREEN:
						gain += valueByTrust([0, 0, 2], trust)
					skill.CONDITION_DOWN:
						gain += valueByTrust([1, 1, 2], trust)
			LINK_TEACHER:
				match(who.condition):
					skill.CONDITION_GREEN:
						gain += valueByTrust([1, 2, 2], trust)
					skill.CONDITION_DOWN:
						gain += valueByTrust([0, 0, 1], trust)
			LINK_MENTOR:
				match(who.condition):
					skill.CONDITION_GREEN:
						gain += valueByTrust([2, 2, 3], trust)
					skill.CONDITION_DOWN:
						gain += valueByTrust([1, 2, 2], trust)
			LINK_PROMISE:
				if who.condition == skill.CONDITION_GREEN:
					gain += valueByTrust([0, 0, 1], trust)
				elif who.condition == skill.CONDITION_DOWN:
					gain += valueByTrust([2, 3, 3], trust)
				else:
					gain += valueByTrust([1, 1, 2], trust)
	return gain

func initLinkList(ln) -> void:
	links = []
	links.resize(24)
	for i in range(24):
		links[i] = [0 as int, LINK_NONE, LINK_NONE, LINK_NONE]
	if ln != null:	#Malformed save check.
		for i in range(ln.size()):
			links[i] = [int(ln[i][0]), int(ln[i][1]), int(ln[i][2]), int(ln[i][3])]
			print("[OVER][initLinkList] links to %s [trust: %s, %s, %s, %s]" % [i, links[i][0], links[i][1], links[i][2], links[i][3]])

func calculateTurnOverGains() -> int:
	var result : int = 0
	for i in group.formation:
		if i != null:
			if i.slot != slot:
				if links[i.slot][1] != LINK_NONE:
					result += calculateTurnOverLink(i)
	return result

static func valueByTrust(a, v:int) -> int: #Return Over gain value based on trust.
	if v >= 100:   return a[2]
	elif v >= 50:  return a[1]
	else:          return a[0]
