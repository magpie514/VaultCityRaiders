extends "res://classes/group/group_base.gd"
const adventurer = preload("res://classes/char/char_player.gd")
const DragonGem = adventurer.DragonGem

const ROW_SIZE = 3
const MAX_SIZE = ROW_SIZE * 2

const ROW_ITER = [[0, 1, 2], [3, 4, 5], [6, 7, 8]]

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
				tmp_data = adventurer.Weapon
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



var roster : Array = core.newArray(24)
var formationSlots : Array = core.newArray(MAX_SIZE)
var dragonGems : Array = []
var mons : Array = core.newArray(6) #Monster party.
var guest : adventurer = null
var funds : int = 0
var inventory = null
var display = null
var stats = null

func init(dict):
	formation = core.newArray(MAX_SIZE)
	name = str(dict.name)
	funds = int(dict.funds)
	stats = {
		wins = int(dict.stats.wins),
		defeats = int(dict.stats.defeats),
	}
	#Restore world settings.
	var world = {
		time = dict.world.time if 'time' in dict.world else 29,
		day = dict.world.day if 'day' in dict.world else 1,
	}
	core.world.init(world)
	#Load item inventory
	#TODO: Make a proper item class and use it. This will do until then.
	inventory = Inventory.new(dict.inventory)

	#Load dragon gem inventory
	if dict.dragonGems != null:
		for i in dict.dragonGems:
			dragonGems.push_back(DragonGem.new(i[0], i[1]))
		print("[GROUP][DRAGONGEM] %s" % str(dragonGems))

	for i in range(dict.roster.size()):
		roster[i] = dict.roster[i].duplicate()
	formationSlots = dict.formationSlots.duplicate()
	var A = null
	for i in range(MAX_SIZE):                                                     #Load individual characters now.
		if formationSlots[i] != null:
			A = roster[formationSlots[i]]
			formation[i] = adventurer.new()
			formation[i].initDict(A)
			formation[i].slot = i
			formation[i].row = 0 if i < ROW_SIZE else 1
			formation[i].group = self
			formation[i].inventory = inventory.initPersonal(A.inventory if 'inventory'  in A else [], formation[i])
		else:
			formation[i] = null

func getRowSize():
	return ROW_SIZE

func giveDGem(G):
	dragonGems.push_back(G)
	sortDGems()

func sortDGems():
	var result : Array = []
	for i in dragonGems:
		if i != null:
			result.push_back(i)
	dragonGems = result

func getDefeated() -> int:
	var result : int = 0
	for i in formation:
		if i != null:
			if i.status == core.skill.STATUS_DOWN:
				result += 1
	return result

func size() -> int:
	var count : int = 0
	for i in range(roster.size()):
		count += 1 if roster[i] != null else 0
	return count

func partySize() -> int:
	var count : int = 0
	for i in range(formation.size()):
		if formation[i] != null:
			count += 1 if formation[i].incapacitated != false else 0
	return count

func partyStatus() -> Array:
	var alive : int = 0
	var down : int = 0
	for i in formation:
		if i.status == core.skill.STATUS_DOWN:
			down += 1
		else:
			alive += 1
	return [ alive, down ]

func loadJson(json):
	var dict = {}
	return init(dict)

func loadDebug():
	var f = preload("res://data/debug_guild.gd").new()
	var data = f.data
	if not data:
		print("[!]: Couldn't load guild data")
		return
	init(data)

func getFormationSlot(n):
	return formation[n]

func healAll():
	for i in formation:
		if i != null:
			i.status = core.skill.STATUS_NONE
			i.fullHeal()

func restoreAll():
	for i in formation:
		if i != null:
			i.status = core.skill.STATUS_NONE
			i.fullHeal()
			if i is core.Player: i.equip.fullRepair(true)

func getRowIter(row: int) -> Array:
	return ROW_ITER[row % 2]

func on_hour_pass() -> void:
	inventory.updateCharges()
