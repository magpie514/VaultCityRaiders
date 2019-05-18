extends "res://classes/char/char_base.gd"
var raceLib = core.lib.race
var classLib = core.lib.aclass
var tid = core.tid

const WEAPON_SLOTS = 4
const GEAR_SLOTS = 4

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

var guildIndex : int #reference to character's position in the guild list.
var aclassPtr = null #pointer to class index.
var racePtr = null #pointer to race index.

var XP : int = 0 setget setXP
var SP : int = 0
var EP : int = 0
var race = null #tid
var aclass = null #tid
var skills = null #array of class ID + level
var links = null #array of [trust, link1, link2, link3]

var equip = equipClass.new()
var currentWeapon = equip.weps[0]
var inventory:Array = []
var personalInventorySize:int = 2
var personalInventory:Array = []

class DragonGem:
	const EXP_TABLE = [
		[0, 100, 200, 300, 400,  500, 600, 700, 800, 900]
	]
	var id = null
	var level : int = 1
	var XP : int = 0
	var lib = null
	func _init(type, xp):
		self.id = core.tid.fromArray(type)
		self.lib = core.lib.dgem.getIndex(id)
		self.XP = xp
		self.level = 1
		setLevel()
		print("[GEM] Initialized dragon gem %s LV.%s" % [lib.name, level])

	func save() -> Array:
		return [self.id, self.XP]

	func setLevel():
		var levelup = false
		while level < 9 and XP >= EXP_TABLE[0][self.level]:
			#print("[GEM] Level up!")
			level += 1
			levelup = true
		return levelup

	func getSkill():
		return lib.skill

	func getUnicodeIcon():
		match lib.shape:
			core.lib.dgem.GEMSHAPE_DIAMOND:
				return '◆'
			core.lib.dgem.GEMSHAPE_CIRCLE:
				return '●'
			core.lib.dgem.GEMSHAPE_SQUARE:
				return '■'

	func printGem() -> String:
		var result : String = "%s %s LV.%02d/%02d" % [getUnicodeIcon(), lib.name, level, lib.levels]
		return result


	func getStats(type : int, D : Dictionary) -> void:
		var where = null
		match(type):
			0:
				where = lib.on_weapon
				#print("[GEM][getStats] Calculating for weapon.")
			1:
				where = lib.on_body
				print("[GEM][getStats] Calculating for body.")
		for i in where:
			if i in D:
				if i == 'OFF' or i == 'RES':
					for j in core.stats.ELEMENTS:
						D[i][j] += where[i][j][level]
				else:
					D[i] += where[i][level]
			else:
				if i == 'OFF' or i == 'RES':
					D[i] = {}
					for j in core.stats.ELEMENTS:
						D[i][j] = where[i][j][level]
				else:
					D[i] = where[i][level]



class DragonGemContainer:
	const GEM_SLOTS = 9
	var slot = core.newArray(GEM_SLOTS)
	var type = 0
	var stats = null
	var skills = null

	func _init(loc : int, data = null) -> void:
		self.type = loc
		#print("[GEMCONTAINER][_init] Init gem on %s with data %s" % [["body", "self"][loc], data])
		if data == null:
			for i in range(GEM_SLOTS):
				slot[i] = null
		else:
			for i in range(GEM_SLOTS):
				if i < data.size():
					if data[i] == null:
						slot[i] = null
					else:
						slot[i] = DragonGem.new(data[i][0], data[i][1])
		calcStats()
		#print("[GEMCONTAINER][_init] Result: %s %s" % [loc, slot])

	func attach(G : DragonGem, sl : int):
		if sl > GEM_SLOTS:
			calcStats()
			return
		slot[sl] = G
		print("[GEMCONTAINER][attach] %s in slot %s" % [slot[sl], sl])
		calcStats()

	func detach(sl : int):
		if sl > GEM_SLOTS:
			return null
		elif slot[sl] == null:
			calcStats()
			return null
		var G = slot[sl]
		slot[sl] = null
		calcStats()
		return G

	func addModifiers(M):
		if M == null:
			pass

	func calcStats():
		var result = {}
		for i in range(GEM_SLOTS): #TODO: Use weapon level instead
			if slot[i] != null:
				#print("[GEMCONTAINER][calcStats] %s LV.%s in slot %s" % [slot[i].lib.name, slot[i].level, i])
				slot[i].getStats(type, result)
		print("[GEMCONTAINER][calcStats] this container provides %s" % result)
		self.stats = result
		var sk = {}
		var sk_mod = {}
		var sk_last = null
		for i in range(GEM_SLOTS):
			var temp = slot[i].getSkill() if slot[i] != null else null
			if temp != null:
				print("[GEMCONTAINER][calcStats] Found skill %s" % [str(temp)])
				if temp in sk:
					sk[temp] = slot[i].level if slot[i].level > sk[temp] else sk[temp]
				else:
					sk[temp] = slot[i].level
			if slot[i] != null and slot[i].lib.shape == core.lib.dgem.GEMSHAPE_SQUARE and i > 0:
				if sk_last != null and slot[i].lib.skillMod != null:
					print("[GEMCONTAINER][calcStats] modifier %s on %s" % [slot[i].lib.name, str(sk_last)])
					if sk_last in sk_mod:
						#Skill already has a temporary copy, so modify that.
						core.skill.factory(sk_mod[sk_last], slot[i].lib.skillMod, slot[i].level)
					else:
						#Create a temporary copy of the skill data to modify.
						var tmp = core.lib.skill.getIndex(sk_last)
						var tmp2 = tmp.duplicate(true)
						core.skill.factory(tmp2, slot[i].lib.skillMod, slot[i].level)
						sk_mod[sk_last] = tmp2
			sk_last = temp if (slot[i] != null and slot[i].lib.shape == core.lib.dgem.GEMSHAPE_DIAMOND) else null

		var sk2 = []
		for i in sk:
			sk2.push_back([i, sk[i], sk_mod[i] if i in sk_mod else null])

		self.skills = sk2
		print("[GEMCONTAINER][calcStats] skills:")
		for i in self.skills:
			print(i[0])

	func printGems() -> String:
		var result = "["
		var gem : DragonGem
		for i in range(GEM_SLOTS):
			gem = slot[i]
			if i == 8:
				if gem == null:
					result = "_"+result
				else:
					result = "◆"+result
			else:
				if gem != null: #◆●■
					#print("[GEMCONTAINER][printGems] Gem: %s LV.%s" % [gem.lib.name, gem.level])
					match(gem.lib.shape):
						core.lib.dgem.GEMSHAPE_DIAMOND:
							result += "[color=%s]◆[/color]" % gem.lib.color
						core.lib.dgem.GEMSHAPE_CIRCLE:
							result += "[color=%s]●[/color]" % gem.lib.color
						core.lib.dgem.GEMSHAPE_SQUARE:
							result += "[color=%s]■[/color]" % gem.lib.color
						_:
							result += "?"
				else:
					result += "_"
		result += "]"
		return result

class Gear:
	var lib:Dictionary

class Armor:
	var DEFAULT : Dictionary = {
		tid = core.tid.create("debug", "debug"),
		gem = null,
		extraData = null
	}
	var STATS_DEFAULT : Dictionary = {
		MHP = int(0), MEP = int(0),
		ATK = int(0), ETK = int(0), WRD = int(0), DUR = int(0),
		DEF = int(0), EDF = int(0), AGI = int(0), LUC = int(0),
		OFF = core.stats.createElementData(),
		RES = core.stats.createElementData(),
		SKL = [],
	}
	var tid = null
	var lib:Dictionary
	var DGem:DragonGemContainer
	var extraData = null #Frame / Vehicle data
	var stats:Dictionary = {}
	func _init(_tid = null, data = DEFAULT )-> void:
		var tmp_tid = _tid


class Weapon:
	const MAX_DUR = 99
	var DEFAULT : Dictionary = {
		tid = core.tid.create("debug", "debug"),
		level = int(0),
		uses  = int(0),
		gem  = null,
		extraData = null,
	}
	var STATS_DEFAULT : Dictionary = {
		ATK = int(0), ETK = int(0), WRD = int(0), DUR = int(0),
		DEF = int(0), EDF = int(0), AGI = int(0), LUC = int(0),
		OFF = core.stats.createElementData(),
		RES = core.stats.createElementData(),
		SKL = [],
	}

	var tid = null
	var lib = null
	var level : int = 0 setget setBonus
	var uses : int = 0
	var DGem : DragonGemContainer
	var extraData = null
	var stats: Dictionary = {}

	func _init(_tid = null, data = DEFAULT) -> void:
		var tmp_tid = _tid
		if tmp_tid == null: tmp_tid = data.tid if 'tid' in data else DEFAULT.id
		self.tid = core.tid.fromArray(tmp_tid)
		self.lib = core.lib.weapon.getIndex(self.tid)
		self.level = data.level
		self.uses = data.uses
		self.DGem = DragonGemContainer.new(0, data.gem)
		stats = STATS_DEFAULT.duplicate()
		recalculateStats()

	func save() -> Dictionary: #Return dict for saving.
		return {
			tid = self.tid,
			level = self.level,
			uses = self.uses,
			dgem = self.DGem.save(),
		}

	func clampStats() -> void:
		stats.DUR = int(clamp(stats.DUR, 0, MAX_DUR))

	func recalculateStats() -> void:
		var gemstats = DGem.stats
		stats.ATK = lib.ATK[level] + (gemstats.ATK if 'ATK' in gemstats else 0)
		stats.ETK = lib.ETK[level] + (gemstats.ETK if 'ETK' in gemstats else 0)
		stats.WRD = lib.weight[level] + (gemstats.WRD if 'WRD' in gemstats else 0)
		stats.DUR = lib.durability[level] + (gemstats.DUR if 'DUR' in gemstats else 0)
		for i in ['DEF', 'EDF', 'AGI', 'LUC']:
			stats[i] = gemstats[i] if i in gemstats else 0
		for i in ['OFF', 'RES']:
			if i in gemstats:
				for j in core.stats.ELEMENTS:
					stats[i][j] = gemstats[i][j] if j in gemstats[i] else 0
		clampStats()

	func attachGem(gem: DragonGem, sl : int) -> void:
		DGem.attach(gem, sl)
		recalculateStats()

	func detachGem(sl:int):
		var G = DGem.detach(sl)
		recalculateStats()
		return G

	func setBonus(val) -> void: #Clamp value for upgrade level
		level = int(clamp(val, 0, 9))

	func fullRepair() -> void:
		uses = stats.DUR
		print("[WEAPON][fullRepair] Fully repaired!")

	func partialRepair(val:int) -> void:
		uses = round(float(stats.DUR) * core.percent(val)) as int
		print("[WEAPON][partialRepair] Durability is now %02d" % uses)


class equipClass:
	const WEAPON_SLOTS = 4
	const GEAR_SLOTS = 4
	var weps = core.newArray(WEAPON_SLOTS)
	var currentWeapon : Weapon
	var gear = core.newArray(GEAR_SLOTS)
	var tid = core.tid
	func _init() -> void:
		for i in range(WEAPON_SLOTS):
			weps[i] = null
		for i in range(GEAR_SLOTS):
			gear[i] = null

	func fullRepair(all:bool) -> void:
		print("[EQUIP][fullRepair] Repairing all weapons.")
		if all:
			for i in weps:
				if i != null:
					i.fullRepair()
		else:
			currentWeapon.fullRepair()

	func partialRepair(val:int, all:bool) -> void:
		print("[EQUIP][partialRepair] Repairing %d%% to all weapons." % val)
		if all:
			for i in weps:
				if i != null:
					i.partialRepair(val)
		else:
			currentWeapon.partialRepair(val)

	func loadWeapon(data : Dictionary) -> Weapon:
		var result = Weapon.new(null, data)
		return result

	func loadWeapons(data) -> void:
		for i in range(WEAPON_SLOTS):
			if i < data.size():
				weps[i] = loadWeapon(data[i])
			else:
				weps[i] = Weapon.new()

	func initWeaponSlot() -> Weapon:
		print("[EQUIP] New weapon slot")
		return Weapon.new()

	func initGearSlot() -> Dictionary:
		return {
			tid = tid.create("debug", "debug"),
			level = int(0),
			extraData = null,
		}

	func calculateStatBonuses():
		var stats = core.stats.create()
		for i in range(gear.size()):
			if i != null:
				print(i)

	func calculateWeaponBonuses(weapon):
		var wstats = weapon.stats
		var stats = core.stats.create()
		for i in ['ATK', 'DEF', 'ETK', 'EDF', 'AGI', 'LUC']:
			stats[i] += wstats[i] if i in wstats else 0
		for i in ['OFF', 'RES']:
			if i in wstats:
				for j in core.stats.ELEMENTS:
					stats[i][j] = wstats[i][j] if j in wstats[i] else 0
		return stats

	func getWeaponSpeedMod(weapon) -> int:
		var W = weapon.lib
		return W.weight[weapon.level]




static func valueByTrust(a, v : int) -> int:
	if v >= 100:   return a[2]
	elif v >= 50:  return a[1]
	else:          return a[0]


func calculateTurnOverLink(who) -> int:
	var gain : int = 0
	var trust : int = links[who.slot][0]
	for i in range(3):
		match(links[who.slot][i]):
			LINK_FRIEND:
				match(who.status):
					skill.STATUS_NONE:
						gain += valueByTrust([1, 2, 3], trust)
					skill.STATUS_DOWN:
						gain += valueByTrust([1, 1, 2], trust)
			LINK_NAKAMA:
				match(who.status):
					skill.STATUS_NONE:
						gain += valueByTrust([1, 1, 2], trust)
					skill.STATUS_DOWN:
						gain += valueByTrust([1, 2, 2], trust)
			LINK_LOVER:
				match(who.status):
					skill.STATUS_NONE:
						gain += valueByTrust([2, 2, 3], trust)
					skill.STATUS_DOWN:
						gain += valueByTrust([3, 3, 3], trust)
			LINK_FAMILY:
				match(who.status):
					skill.STATUS_NONE:
						gain += valueByTrust([0, 0, 1], trust)
					skill.STATUS_DOWN:
						gain += valueByTrust([1, 1, 1], trust)
			LINK_BESTFRIEND:
				match(who.status):
					skill.STATUS_NONE:
						gain += valueByTrust([2, 3, 3], trust)
					skill.STATUS_DOWN:
						gain += valueByTrust([2, 2, 3], trust)
			LINK_TRUELOVE:
				match(who.status):
					skill.STATUS_NONE:
						gain += valueByTrust([2, 3, 3], trust)
					skill.STATUS_DOWN:
						gain += valueByTrust([3, 3, 3], trust)
			LINK_APPRENTICE:
				match(who.status):
					skill.STATUS_NONE:
						gain += valueByTrust([0, 0, 2], trust)
					skill.STATUS_DOWN:
						gain += valueByTrust([1, 1, 2], trust)
			LINK_TEACHER:
				match(who.status):
					skill.STATUS_NONE:
						gain += valueByTrust([1, 2, 2], trust)
					skill.STATUS_DOWN:
						gain += valueByTrust([0, 0, 1], trust)
			LINK_MENTOR:
				match(who.status):
					skill.STATUS_NONE:
						gain += valueByTrust([2, 2, 3], trust)
					skill.STATUS_DOWN:
						gain += valueByTrust([1, 2, 2], trust)
			LINK_PROMISE:
				if who.status == skill.STATUS_NONE:
					gain += valueByTrust([0, 0, 1], trust)
				elif who.status == skill.STATUS_DOWN:
					gain += valueByTrust([2, 3, 3], trust)
				else:
					gain += valueByTrust([1, 1, 2], trust)
	return gain


func calculateTurnOverGains() -> int:
	var result : int = 0
	for i in group.formation:
		if i != null:
			if i.slot != slot:
				if links[i.slot][1] != LINK_NONE:
					result += calculateTurnOverLink(i)
	return result

func endBattleTurn(defer):
	battle.over += calculateTurnOverGains()
	.endBattleTurn(defer)

func getEquipSpeedMod() -> int:
	return equip.getWeaponSpeedMod(currentWeapon)

func recalculateStats():
	var raceStats = stats.create()
	stats.resetElementData(raceStats.OFF)
	stats.resetElementData(raceStats.RES)
	stats.setFromSpread(raceStats, raceLib.getStatSpread(race), level)
	var classStats = stats.create()
	stats.setFromSpread(classStats, classLib.getStatSpread(aclass), level)
	stats.sumInto(statBase, raceStats, classStats)
	var weaponStats = equip.calculateWeaponBonuses(currentWeapon)
	stats.sumInto(statFinal, statBase, weaponStats)

func setCharClass(t) -> void:
	aclass = tid.fromArray(t)
	aclassPtr = core.lib.aclass.getIndex(t)

func setCharRace(t) -> void:
	race = tid.fromArray(t)
	racePtr = core.lib.race.getIndex(t)

func initLinkList(ln) -> void:
	links = []
	links.resize(24)
	for i in range(24):
		links[i] = [0 as int, LINK_NONE, LINK_NONE, LINK_NONE]
	if ln != null:	#Malformed save check.
		for i in range(ln.size()):
			links[i] = [int(ln[i][0]), int(ln[i][1]), int(ln[i][2]), int(ln[i][3])]
			print("[OVER][initLinkList] links to %s [trust: %s, %s, %s, %s]" % [i, links[i][0], links[i][1], links[i][2], links[i][3]])


func initSkillList(sk) -> void:
	skills = []
	for i in sk:
		skills.push_back([ int(i[0]), int(i[1]) ]) #skill TID, level


func initDict(C):	#Load the character from save data
	side = 0
	self.name = str(C.name)                    #Init adventurer's name
	print("[CHAR][initDict] Initializing %s" % [name])
	setCharRace(C.race)                        #Init adventurer's race and set pointer to it for easy reference.
	setCharClass(C.aclass)                     #Init adventurer's class and set pointer.
	self.level = int(C.level)                  #Set character level. TODO: Read EXP instead?
	equip.loadWeapons(C.equip)                 #Init adventurer's weapons.
	currentWeapon = equip.weps[0]              #Set main weapon as slot 0. TODO: Save last used slot as int?
	equip.currentWeapon = equip.weps[0]
	self.personalInventorySize = C.personalInventorySize if 'personalInventorySize' in C else 2
	if 'personalInventory' in C:
		for i in C.personalInventory:
			personalInventory.push_back([int(i[0]), core.tid.fromArray(i[1]), i[2].duplicate(true)])
	initSkillList(C.skills)                    #Init adventurer's skill list.
	initLinkList(C.links)                      #Init adventurer's links and trust with other guild members.
	if 'energyColor' in C:
		energyColor = C.energyColor
	else:
		energyColor = "#4466FF"

	recalculateStats()
	fullHeal()
	print(getTooltip())

func initJson(json):
	pass

func damage(x, data, silent = false) -> Array:
	var info : Array = .damage(x, data, silent)
	if display != null and not silent:
		display.damageShake()
	return info

func revive(x: int) -> void:
	.revive(x)

func charge(x : bool = false) -> void:
	if display != null:
		display.charge(x)

func getTooltip():
	return "%s\nLv.%s %s %s\n%s" % [name, level, raceLib.name(race), classLib.name(aclass), core.stats.print(statFinal)]

func giveXP(val):
	self.XP = XP + val

func setXP(val):
	XP = val
	##TODO: Check for level increase etc etc.

func setWeapon(WP):
	if currentWeapon != WP:
		currentWeapon = WP
		equip.currentWeapon = WP
		updateBattleStats()

func getSkillTID(t):
	return aclassPtr.skills[t[0]]

func checkRaceType(type:int) -> bool:
	var result : bool = false
	if type in race.lib.race:
		result = true
	return result

func fullRepair(all:bool=true) -> void:
	equip.fullRepair(all)

func partialRepair(val:int, all:bool=true) -> void:
	equip.partialRepair(val,all)
