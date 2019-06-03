extends "res://classes/char/char_base.gd"
var raceLib = core.lib.race
var classLib = core.lib.aclass
var tid = core.tid
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

var guildIndex:int   #reference to character's position in the guild list.
var aclassPtr = null #pointer to class index.
var racePtr = null   #pointer to race index.

var XP:int = 0       #Experience points.
var SP:int = 0       #Skill Points. Gained at level up to raise skills.
var EP:int = 0
var race = null #tid
var aclass = null #tid
var skills = null #array of class ID + level
var links = null #array of [trust, link1, link2, link3]

var equip = equipClass.new()
var currentWeapon = equip.slot[0]
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
	var DEFAULT : Dictionary = {
		tid = core.tid.create("debug", "debug"),
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
	var lib:Dictionary

class Armor:
	var DEFAULT : Dictionary = {
		tid = core.tid.create("debug", "debug"),
		gem = null,
		extraData = {}
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
	var extraData:Dictionary = {} #Frame / Vehicle data
	var stats:Dictionary = {}
	var upgraded:bool = false

	func _init(_tid = null, data = DEFAULT) -> void:
		var tmp_tid = _tid
		if tmp_tid == null: tmp_tid = data.tid if 'tid' in data else DEFAULT.tid
		self.tid = core.tid.fromArray(tmp_tid)
		self.lib = core.lib.armor.getIndex(self.tid)
		self.DGem = DragonGemContainer.new(0, data.gem)
		stats = STATS_DEFAULT.duplicate()
		recalculateStats(1)

	func save() -> Dictionary:
		return {
			tid = self.tid,
			dgem = self.DGem.save()
		}
	func clampStats() -> void:
		pass
	func recalculateStats(lv:int) -> void: #TODO: Move DGem stuff to the character instead?
		var gemstats = DGem.stats
		core.stats.reset(stats)
		if lib.vehicle != null:
			print("[ARMOR][recalculateStats] Vehicle <TODO>")
		if lib.frame != null:
			print("[ARMOR][recalculateStats] Frame")
			core.stats.setFromSpread(stats, lib.frame.statSpread, lv) #TODO: Get user level somehow.

		stats.DEF += lib.DEF[1 if upgraded else 0] + (gemstats.DEF if 'DEF' in gemstats else 0)
		stats.EDF += lib.EDF[1 if upgraded else 0] + (gemstats.EDF if 'EDF' in gemstats else 0)
		for i in ['ATK', 'ETK', 'AGI', 'LUC']:
			stats[i] += gemstats[i] if i in gemstats else 0
		for i in ['OFF', 'RES']:
			if i in gemstats:
				for j in core.stats.ELEMENTS:
					stats[i][j] += gemstats[i][j] if j in gemstats[i] else 0
		clampStats()


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
		if tmp_tid == null: tmp_tid = data.tid if 'tid' in data else DEFAULT.tid
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
	var tid = core.tid

	const TOTAL_SLOTS = 8
	const WEAPON_SLOT =  [ 0, 1, 2, 3 ]
	const ARMOR_SLOT =   [ 4 ]
	const GEAR_SLOT =    [ 5, 6, 7 ]

	var slot:Array = core.newArray(TOTAL_SLOTS)
	var currentWeapon : Weapon

	func _init() -> void:
		for i in range(TOTAL_SLOTS):
			slot[i] = null

	func calculateStatBonuses():
		var stats = core.stats.create()

	func fullRepair(all:bool) -> void:
		if all:
			print("[EQUIP][fullRepair] Repairing all weapons.")
			for i in WEAPON_SLOT:
				if slot[i] is Weapon:
					slot[i].fullRepair()
				#TODO: Check onboard weapons here.
		else:
			print("[EQUIP][fullRepair] Repairing current weapon.")
			currentWeapon.fullRepair()

	func partialRepair(val:int, all:bool) -> void:
		if all:
			print("[EQUIP][partialRepair] Repairing %d%% to all weapons." % val)
			for i in WEAPON_SLOT:
				if slot[i] is Weapon:
					slot[i].partialRepair(val)
		else:
			print("[EQUIP][partialRepair] Repairing %d%% to current weapon." % val)
			currentWeapon.partialRepair(val)

	func loadWeapons(data) -> void:
		for i in WEAPON_SLOT:
			if data[i] != null:
				slot[i] = Weapon.new(null, data[i])
			else:
				slot[i] = Weapon.new()

	func initWeaponSlot() -> Weapon: #Is this used?
		print("[EQUIP][initWeaponSlot] New weapon slot")
		return Weapon.new()

	func calculateWeaponBonuses(weapon): #->core.stats ?
		var wstats = weapon.stats
		var stats = core.stats.create()
		for i in ['ATK', 'DEF', 'ETK', 'EDF', 'AGI', 'LUC']:
			stats[i] += wstats[i] if i in wstats else 0
		for i in ['OFF', 'RES']:
			if i in wstats:
				for j in core.stats.ELEMENTS:
					stats[i][j] = wstats[i][j] if j in wstats[i] else 0
		return stats

	func calculateArmorBonuses(lv): #->core.stats: ?
		var stats = core.stats.create()
		for a in ARMOR_SLOT:
			slot[a].recalculateStats(lv)
			var astats = slot[a].stats
			for i in ['MHP', 'ATK', 'DEF', 'ETK', 'EDF', 'AGI', 'LUC']:
				stats[i] += astats[i] if i in astats else 0
			for i in ['OFF', 'RES']:
				if i in astats:
					for j in core.stats.ELEMENTS:
						stats[i][j] = astats[i][j] if j in astats[i] else 0
		return stats


	func getWeaponSpeedMod(weapon) -> int:
		var W = weapon.lib
		return W.weight[weapon.level]

	func loadArmor(data) -> void:
		for i in ARMOR_SLOT: #Make it a loop anyway in case there's a reason to increase later.
			if data[i] != null:
				slot[i] = Armor.new(null, data[i]) #loadArmor(data[i])
			else:
				slot[i] = Armor.new() #TODO: Load class or race default instead.

	func loadGear(data) -> void:
		for i in GEAR_SLOT:
			if data[i] != null:
				pass

	func initGearSlot() -> Dictionary:
		return {
			tid = tid.create("debug", "debug"),
			level = int(0),
			extraData = null,
		}




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

func recalculateStats() -> void:
	#Get stats from race/class.
	var raceStats = stats.create()
	#TODO: Reset it to race defaults instead.
	stats.resetElementData(raceStats.OFF)
	stats.resetElementData(raceStats.RES)
	stats.setFromSpread(raceStats, racePtr.statSpread, level)
	var classStats = stats.create()
	stats.setFromSpread(classStats, aclassPtr.statSpread, level)
	stats.sumInto(statBase, raceStats, classStats)

	#Get stats from equipment.
	var gearStats = stats.create()
	stats.sum(gearStats, equip.calculateWeaponBonuses(currentWeapon))
	stats.sum(gearStats, equip.calculateArmorBonuses(level))
	#stats.sum(gearStats, equip.calculateGearBonuses())
	stats.sumInto(statFinal, statBase, gearStats)

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
	#self.level = int(C.level)                  #Set character level. TODO: Read EXP instead?
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
		energyColor = "#4466FF"
	setXP(C.XP)                                #Set level from experience points.
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
