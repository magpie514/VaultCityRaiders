enum { #Armor classes
	ARCLASS_NONE = 0,
	ARCLASS_LIGHT,
	ARCLASS_HEAVY,
	ARCLASS_BARRIER,
	ARCLASS_VEHICLE,
	ARCLASS_FRAME,
}

enum { #Vehicle classes
	VECLASS_NONE = 0,
	VECLASS_SMALL,
	VECLASS_LARGE,
	VECLASS_HEAVY,
	VECLASS_AERIAL,
	VECLASS_VANGUARD,
}

enum { #Vehicle parts. (Frames need no check, they use all)
	PARTS_ENGINE = 1,
	PARTS_ARMOR,
	PARTS_FCS,
	PARTS_COOLING,
	# Frame only
	PARTS_BOOSTER,
	# Goes in extra slot
	PARTS_EXTRA,
}

const ARCLASS_TRANSLATE = {
	'LIGHT':		ARCLASS_LIGHT,
	'HEAVY':		ARCLASS_HEAVY,
	'BARRIER':	ARCLASS_BARRIER,
	'VEHICLE':	ARCLASS_VEHICLE,
	'FRAME':		ARCLASS_FRAME,
}

const ARMORPARTS_TRANSLATE = {
	"ENGINE":   PARTS_ENGINE,
	"ARMOR":		PARTS_ARMOR,
	"FCS":      PARTS_FCS,
	"COOLING":  PARTS_COOLING,
	"BOOSTER":  PARTS_BOOSTER,
	"EXTRA":    PARTS_EXTRA,
}
const ARMORPARTS = {
	PARTS_ENGINE:   { name = "Engine" },
	PARTS_FCS:      { name = "FCS" },
	PARTS_ARMOR:		{ name = "Armor" },
	PARTS_COOLING:  { name = "Cooling" },
	PARTS_BOOSTER:  { name = "Booster" },
	PARTS_EXTRA:    { name = "Extra" },
}

const VEPARTS = {
	VECLASS_SMALL:    [ PARTS_ENGINE,PARTS_FCS,PARTS_COOLING ],
	VECLASS_LARGE:    [ PARTS_ENGINE,PARTS_FCS,PARTS_COOLING,PARTS_ARMOR ],
	VECLASS_HEAVY:    [ PARTS_ENGINE,PARTS_FCS,PARTS_COOLING,PARTS_ARMOR ],
	VECLASS_AERIAL:   [ PARTS_ENGINE,PARTS_FCS,PARTS_COOLING,PARTS_BOOSTER ],
	VECLASS_VANGUARD: [ PARTS_ENGINE,PARTS_FCS,PARTS_COOLING,PARTS_ARMOR,PARTS_BOOSTER ],
}

const armortypes = {
	ARCLASS_NONE :    { name = "???",     icon = "" },
	ARCLASS_LIGHT :   { name = "Light",   icon = "" },
	ARCLASS_HEAVY :   { name = "Heavy",   icon = "" },
	ARCLASS_BARRIER : { name = "Barrier", icon = "" },
	ARCLASS_VEHICLE : { name = "Vehicle", icon = "" },
	ARCLASS_FRAME :   { name = "Frame",   icon = "" },
}


class DragonGem:
	const EXP_TABLE = [
		[0, 100, 200, 300, 400,  500, 600, 700, 800, 900]
	]
	var id = null
	var level : int = 1
	var XP : int = 0
	var lib = null
	func _init(type, xp):
		self.id = core.tid.from(type)
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

class Consumable:
	const MAX_CHARGE = 3000
	var DEFAULT: Dictionary = {
		tid = core.tid.create("debug", "debug"),
		level = int(1),
		charge = int(0)
	}
	var tid
	var lib: Dictionary
	var charge: int = 0
	var level: int = 0

	func _init(_tid = null, data = DEFAULT):
		self.tid = core.tid.fromArray(data.tid if _tid == null else _tid)
		self.lib = core.lib.item.getIndex(self.tid)
		level =  int(data.level  if 'level'  in data else DEFAULT.level) - 1
		charge = int(data.charge if 'charge' in data else DEFAULT.charge)

	func recharge() -> void:
		print("[CONSUMABLES][rechargeFull] Charging %s (+%s)" % [lib.name, lib.chargeRate[level]])
		charge += lib.chargeRate[level]
		if charge >= MAX_CHARGE:
			charge = MAX_CHARGE

	func rechargeFull() -> void:
		print("[CONSUMABLES][rechargeFull] Fully recharging %s" % lib.name)
		charge = MAX_CHARGE


class Inventory:
	const INIT_SLOTS = 30
	var general: Array =    []
	var counters:Array =    []
	var dragonGems: Array = []
	var materials:Array =   [] #TODO
	var keyitems: Array =   []

	func _init(IN:Array):
		for i in range(IN.size()):
			if i < IN.size():
				if IN[i].size() == 3: #[TYPE, TID, DATA]
					general.push_back(Item.new(i, IN[i][0], IN[i][1], IN[i][2], general))
		updateCounters()

	func initPersonal(IN:Array, C) -> Array:
		var result:Array = []
		for i in range(C.personalInventorySize):
			if i < IN.size():
				if IN[i].size() == 3: #[TYPE, TID, DATA]
					result.push_back(Item.new(i, IN[i][0], IN[i][1], IN[i][2], C.inventory))
		return result

	func updateCounters() -> void:
		counters.clear()
		for i in general:
			if i.type == Item.ITEM_CONSUMABLE:
				if i.data.lib.counter:
					if i.data.lib.charge:
						#Only count charge items if they have enough charge.
						if i.data.charge >= i.data.lib.chargeUse[i.data.level]:
							counters.push_back(i)
					else:
						counters.push_back(i)

	func canCounterAttack(elem = 0, personal:Array = []) -> Array:#Checks if any item can counter the incoming attack.
		var result:Array = []
		if elem > 0: #Only have effect on elemental attacks.
			var counter_type = core.lib.item.ELEMENT_CONV[elem]
			for i in personal:
				if i.data.lib.counters[i.data.level] & counter_type:
					if i.data.lib.charge:
						if i.data.charge >= i.data.lib.chargeUse[i.data.level]:
							print("[ITEM][canCounter] Counter for element %s found in personal inventory, charged" % i.data.lib.name)
							result.push_back(i)
					else:
						print("[ITEM][canCounter] Counter for element %s found in personal inventory, consumable" % i.data.lib.name)
						result.push_back(i)
			for i in counters:
				if i.data.lib.counters[i.data.level] & counter_type:
					print("[ITEM][canCounter] Counter for element %s found in general inventory" % i.data.lib.name)
					result.push_back(i)
		#TODO: Sort them, prioritize lowest quality and charge items over consumables.
		return result

	func canCounterEvent(type:int = 0, personal:Array = []) -> Array:
		var result:Array = []
		for what in [
			[core.lib.item.COUNTER_CRITICAL, 'critical'],
			[core.lib.item.COUNTER_BUFF, 'buff'],
			[core.lib.item.COUNTER_DEBUFF, 'debuff'],
			[core.lib.item.COUNTER_DISABLE, 'disable'],
			[core.lib.item.COUNTER_DEFEAT, 'defeat'],
		]:
			if what[0] == type:
				for i in personal:
					if i.data.lib.counters[i.data.level] & what[0]:
						if i.data.lib.charge:
							if i.data.charge >= i.data.lib.chargeUse[i.data.level]:
								print("[ITEM][canCounterEffect] Counter for %s %s found in personal inventory, charged" % [what[1], i.data.lib.name])
								result.push_back(i)
						else:
							print("[ITEM][canCounterEffect] Counter for %s %s found in personal inventory, consumable" % [what[1], i.data.lib.name])
							result.push_back(i)
				for i in counters:
					if i.data.lib.counters[i.data.level] & what[0]:
						print("[ITEM][canCounter] Counter for %s %s found in general inventory" % [what[1], i.data.lib.name])
						result.push_back(i)
		#TODO: Sort them, prioritize lowest quality and charge items over consumables.
		return result

	func updateCharges() -> void:
		print("[INVENTORY][updateCharges] Checking item charges.")
		for i in general:
			if i.data.lib.charge:
				i.data.recharge()
		updateCounters()

	func fullRecharge() -> void:
		print("[INVENTORY][fullRecharge] Fully recharging all items.")
		for i in general:
			if i.data.lib.charge:
				i.data.rechargeFull()
		updateCounters()

	func takeConsumable(I):
		if I.data.lib.charge:
			print("[INVENTORY][takeConsumable] Using charge of %s (slot %d)" % [str(I), I.slot])
			if I.data.charge >= I.data.lib.chargeUse[I.data.level]:
				print("[!!][INVENTORY][takeConsumable] But %s (slot %d) had no charges!" % [str(I), I.slot])
				I.data.charge -= I.data.lib.chargeUse[I.data.level]
		else:
			print("[INVENTORY][takeConsumable] Taking %s (slot %d)" % [str(I), I.slot])
			if I.container != null:
				I.container.erase(I)
			else:
				print("[!!][INVENTORY][takeConsumable] Null container on %s (slot %d)" % [str(I), I.slot])
				I = null
		updateCounters()

	func giveConsumable(I):
		general.push_back(I)
		updateCounters()

	func returnConsumable(I):
		if I.data.lib.charge:
			I.data.charge += I.data.lib.chargeUse[I.level]
		else:
			I.container.push_front(I)
		updateCounters()

	func find(lib = null, levelFilter:int = 1, type:int = 0, tid = null) -> Array:
		var result = []
		if lib != null:
			for i in general:
				if i.data.lib == lib:
					if levelFilter > 0:
						if i.data.level == levelFilter: #Only push if filter matches.
							result.push_front(i)
					else: #Push anyway.
						result.push_front(i)
		elif type != 0 and tid != null:
			for i in general:
				if i.type == type and core.tid.compare(tid, i.data.tid):
					if levelFilter > 0:
						if i.data.level == levelFilter:
							result.push_front(i)
					else:
						result.push_front(i)
		return result


	func canReuseConsumable(IT:Item)-> bool:
		var I = IT.data
		if I.lib.charge:
			if I.charge >= I.lib.chargeUse[I.level]:
				print("[ITEM][canReuseConsumable] Item is chargeable and has charge. \tRepeating.")
				return true
			else:
				print("[ITEM][canReuseConsumable] Item is chargeable but has no charge. \tNot repeating.")
				return false
		else:
			var temp = find(IT.data.lib, IT.data.level)
			if temp.size() > 0:
				print("[ITEM][canReuseConsumable] Item is consumable but there's more in stock. \tRepeating.")
				return true
			else:
				print("[ITEM][canReuseConsumable] Item is consumable but there are no more in stock. \tNot repeating.")
				return false


class Item: #Item container class.
	enum {
		ITEM_NONE,
		ITEM_CONSUMABLE,
		ITEM_SAMPLE
		ITEM_WEAPON,
		ITEM_ARMOR,
		ITEM_GEAR,
	}
	var type:int = ITEM_NONE
	var data = null
	var slot:int = 0
	var container = null

	func _init(_slot:int, _type:int = ITEM_NONE, _tid = ["debug, debug"], _data = null, _container = null):
		var lib = null
		var tmp_data = null
		type = _type; slot = _slot
		match type:
			ITEM_NONE:
				print("[!!][ITEM][_init] Item initialized as NONE, aborting.")
				return
			ITEM_CONSUMABLE:
				print("[ITEM][_init] %d Consumable.\ntype: %d\ttid:%s\tdata:%s" % [_slot, _type, str(_tid), _data])
				lib = core.lib.item
				tmp_data = Consumable
			ITEM_SAMPLE:
				print("[ITEM][_init] %d Sample.\ntype: %d\ttid:%s\tdata:%s" % [_slot, _type, str(_tid), _data])
			ITEM_WEAPON:
				print("[ITEM][_init] %d Weapon.\ntype: %d\ttid:%s\tdata:%s" % [_slot, _type, str(_tid), _data])
				lib = core.lib.weapon
				tmp_data = Weapon
			ITEM_ARMOR:
				print("[ITEM][_init] %d Armor.\ntype: %d\ttid:%s\tdata:%s" % [_slot, _type, str(_tid), _data])
				lib = core.lib.armor
				tmp_data = Armor
			ITEM_GEAR:
				print("[ITEM][_init] %d Gear.\ntype: %d\ttid:%s\tdata:%s" % [_slot, _type, str(_tid), _data])
				#tmp_lib = core.lib.item.getIndex(tid)
		if _data != null:
			data = tmp_data.new(_tid, _data)
		else:
			print("[ITEM][_init] No item data specified, using defaults.")
			data = tmp_data.new(_tid)
		if _container != null:
			container = _container


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

class ArmorPart:
	var DEFAULT : Dictionary = {
		data = [6,6]
	}
	var tid = null
	var lib:Dictionary
	var data:Array = [6,6]
	func _init(_tid = null, stat1:int = DEFAULT.data[0], stat2:int = DEFAULT.data[1]) -> void:
		self.tid = core.tid.from(_tid)
		self.lib = core.lib.armorparts.getIndex(self.tid)
		data[0] = stat1 + 1
		data[1] = stat2 + 1

class Armor:
	var DEFAULT : Dictionary = {
		tid = core.tid.from("debug/debug"),
		gem = null,
	}
	var STATS_DEFAULT : Dictionary = {
		MHP = int(0), MEP = int(0),
		ATK = int(0), ETK = int(0),
		DEF = int(0), EDF = int(0), AGI = int(0), LUC = int(0),
		OFF = core.stats.createElementData(),
		RES = core.stats.createElementData(),
		SKL = [],
	}
	var tid = null
	var lib:Dictionary
	var parts:Dictionary = {} #Frame / Vehicle data
	var stats:Dictionary = {}
	var upgraded:bool = false

	func _init(_tid = null, data = DEFAULT) -> void:
		var tmp_tid = _tid
		if tmp_tid == null: tmp_tid = data.tid if 'tid' in data else DEFAULT.tid
		self.tid = core.tid.from(tmp_tid)
		self.lib = core.lib.armor.getIndex(self.tid)
		stats = STATS_DEFAULT.duplicate(true)
		if 'parts' in data:
			if data.parts != null:
				for i in data.parts:
					if i in ARMORPARTS_TRANSLATE:
						var part:int = ARMORPARTS_TRANSLATE[i]
						parts[part] = ArmorPart.new(data.parts[i][0], data.parts[i][1], data.parts[i][2])
			else: #Unitialized parts.
				if 'parts' in lib:
					if 'default' in lib.parts:
						print("[ARMOR][_init] Initializing parts for %s" % lib.name)
						for i in lib.parts.default:
							if i in ARMORPARTS_TRANSLATE:
								var part:int = ARMORPARTS_TRANSLATE[i]
								parts[part] = ArmorPart.new(lib.parts.default[i][0])

	func save() -> Dictionary:
		return {
			tid = self.tid,
		}
	func clampStats() -> void:
		pass

	func setPartStats(_parts) -> void: #Add part bonuses into _stats
		for i in ARMORPARTS:
			if i in _parts:
				var part:ArmorPart = _parts[i]
				print("[ARMOR][setPartStarts] Part: ", part.lib.name)
				for j in [['stat1', 0], ['stat2', 1]]:
					var ind = j[0]
					var val = part.data[j[1]]
					match typeof(part.lib[ind][0]):
						TYPE_STRING:
							if part.lib[ind][0] in [ 'MHP','MEP','ATK','DEF','ETK','EDF','AGI','LUC' ]:
								print("%s > %s:%s (tune:%s)" % [part.lib.name, part.lib[ind][0], part.lib[ind][val], val])
								stats[part.lib[ind][0]] += part.lib[ind][val]
							elif core.stats.elementalModStringValidate(part.lib[ind][0]):
								print("%s > %s:%s (tune:%s)" % [part.lib.name, part.lib[ind][0], part.lib[ind][val], val])
								core.stats.elementalModApply(stats, part.lib[ind][0], part.lib[ind][val])
						TYPE_ARRAY, TYPE_STRING_ARRAY:
							if part.lib[ind][val] > 0:
								stats.SKL.push_back([part.lib[ind][0], part.lib[ind][val]])
		print(stats)

	func recalculateStats(lv:int) -> void:
		core.stats.reset(stats, 0) #Reset stats with an element value of 0, so they can be added later.
		var up = 1 if upgraded else 0
		if lib.parts != null:
			print("[ARMOR][recalculateStats] Part stats for %s (level %d)" % [lib.name, lv])
			core.stats.setFromSpread(stats, lib.parts.statSpread, lv)
			setPartStats(parts)
		if lib.bonus != null:
			print("[ARMOR][recalculateStats] Bonus stats for %s: %s" % [lib.name, str(lib.bonus)])
			for i in lib.bonus:
				if i[0] in [ 'MHP','MEP','ATK','DEF','ETK','EDF','AGI','LUC' ]:
					stats[i[0]] += i[up + 1]
				elif core.stats.elementalModStringValidate(i[0]):
					core.stats.elementalModApply(stats, i[0], i[up + 1])
		if lib.over != null:
			stats.SKL.push_back([lib.over, 1 + int(lv as float / 10.0)])
		stats.DEF += lib.DEF[up]
		stats.EDF += lib.EDF[up]
		stats.MHP += lib.MHP[up]
		clampStats()

	func getBonuses(tmpSkill:Array, tmpStats:Dictionary) -> void:
		core.stats.sum(tmpStats, stats)
		if 'SKL' in stats:
			print("[ARMOR][getBonuses] SKL: %s" % [stats.SKL])
			for i in stats.SKL:
				tmpSkill.push_back([ i[0], i[1] ])


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
		MHP = int(0), #Only present since it's a standard stat but weapons cannot give health.
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
		self.tid = core.tid.from(tmp_tid)
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
		stats.MHP = int(0) #Disallow health gains from weapons.
		stats.DUR = core.clampi(stats.DUR, 0, MAX_DUR)

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

	func getBonuses(tmpSkill:Array, tmpStats:Dictionary) -> void:
		core.stats.sum(tmpStats, stats)
		if 'SKL' in stats:
			print("[WEAPON][getBonuses] SKL: %s" % [stats.SKL])
			for i in stats.SKL:
				tmpSkill.push_back([ i[0], i[1] ])

	func attachGem(gem: DragonGem, sl : int) -> void:
		DGem.attach(gem, sl)
		recalculateStats()

	func detachGem(sl:int):
		var G = DGem.detach(sl)
		recalculateStats()
		return G

	func setBonus(val:int) -> void: #Clamp value for upgrade level
		level = int(clamp(val, 0, 9))

	func fullRepair() -> void:
		uses = stats.DUR
		print("[WEAPON][fullRepair] Fully repaired!")

	func partialRepair(val:int) -> void:
		uses = round(float(stats.DUR) * core.percent(val)) as int
		print("[WEAPON][partialRepair] Durability is now %02d" % uses)


class Equip:
	var tid = core.tid

	const TOTAL_SLOTS = 8
	const WEAPON_SLOT =  [ 0, 1, 2, 3 ]
	const ARMOR_SLOT =   [ 4 ]
	const GEAR_SLOT =    [ 5, 6, 7 ]

	var slot:Array = core.newArray(TOTAL_SLOTS)
	var currentWeapon:Weapon
	var weight:int = 0 #TODO: Calculate weight from all items and place it here so it can be read in char_player.gd directly.

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
