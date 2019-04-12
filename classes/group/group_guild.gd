extends "res://classes/group/group_base.gd"
const adventurer = preload("res://classes/char/char_player.gd")
const DragonGem = adventurer.DragonGem

const ROW_SIZE = 3
const MAX_SIZE = ROW_SIZE * 2

var roster : Array = core.newArray(24)
var formationSlots : Array = core.newArray(MAX_SIZE)
var dragonGems : Array = []
var mons : Array = core.newArray(6)
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
	#Load item inventory
	#TODO: Make a proper item class and use it. This will do until then.
	inventory = dict.inventory.duplicate()

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
		else:
			formation[i] = null

func getSpreadTargets(row, filter, slot):
	return getSpreadTargets2(row, ROW_SIZE, filter, slot)

func getRowTargets(row, filter):
	return getRowTargets2(row, ROW_SIZE, filter)


func giveDGem(G):
	dragonGems.push_back(G)
	sortDGems()

func sortDGems():
	var result : Array = []
	for i in dragonGems:
		if i != null:
			result.push_back(i)
	dragonGems = result



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
