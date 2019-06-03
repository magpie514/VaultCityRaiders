extends "res://classes/group/group_base.gd"
const adventurer = preload("res://classes/char/char_player.gd")
const Inventory = preload("res://classes/inventory/item.gd")
const DragonGem = Inventory.DragonGem

const ROW_SIZE = 3
const MAX_SIZE = ROW_SIZE * 2

const ROW_ITER = [[0, 1, 2], [3, 4, 5], [6, 7, 8]]





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
	inventory = Inventory.Inventory.new(dict.inventory)

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

func giveXP(amount:int) -> void: #Gives <amount> experience to all party members in formation.
	for i in formation:
		if i != null:
			print("[GROUP_GUILD][giveXP] Giving %d XP to %s" % [amount, i.name])
			i.giveXP(amount)

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
