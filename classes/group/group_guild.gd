extends "res://classes/group/group_base.gd"
const Adventurer = preload("res://classes/char/char_player.gd")
const Inventory  = preload("res://classes/inventory/item.gd")
const DragonGem  = Inventory.DragonGem
const Consumable = Inventory.Consumable
const Item       = Inventory.Item

var roster:Array         = core.newArray(24)         #All characters in the guild.
var formationSlots:Array = core.newArray(MAX_SIZE)   #???
var dragonGems:Array     = []                        #Dragon Gem inventory.
var monsFormation:Array  = core.newArray(6)          #Monster party.
var monCards:Array       = core.newArray(1024)       #All monsters.
var guest:Adventurer     = null                      #Guest character, if any. Only for events.
var funds:int            = 0                         #Guild's shared money.
var inventory            = null                      #Guild's shared inventory.
var display              = null                      #Pointer to GUI.
var stats                = null                      #Guild stats.
var FO                   = null                      #Guild's Field Officer.

# Virtual overrides ###############################################################################
func getDefeated() -> int:
	var result:int = 0
	for i in formation:
		if i != null:
			if i.condition == core.skill.CONDITION_DOWN: result += 1
	return result
###################################################################################################

func init(dict) -> void:
	formation = core.newArray(MAX_SIZE)
	name      = str(dict.name)
	funds     = dict.funds as int if ('funds' in dict) else int(0)

	stats     = {
		wins    = int(dict.stats.wins),
		defeats = int(dict.stats.defeats),
	}
	#Restore world settings.
	var world:Dictionary = {
		time      = dict.world.time      if 'time'      in dict.world else 29,
		day       = dict.world.day       if 'day'       in dict.world else 1,
		IDcounter = dict.world.IDcounter if 'IDcounter' in dict.world else 1,
	}
	core.world.init(world)
	#Load item inventory
	#TODO: Make a proper item class and use it. This will do until then.
	inventory = Inventory.Inventory.new(dict.inventory)

	#Load dragon gem inventory
	if dict.dragonGems != null:
		for i in dict.dragonGems:
			dragonGems.push_back(DragonGem.new(i[0], i[1]))
		#print("[GROUP][DRAGONGEM] %s" % str(dragonGems))

	for i in range(dict.roster.size()):	roster[i] = dict.roster[i].duplicate()
	formationSlots = dict.formationSlots.duplicate()
	#Load individual characters now.
	for i in range(MAX_SIZE):
		if formationSlots[i] != null:
			var A = roster[formationSlots[i]]
			formation[i] = Adventurer.new()
			formation[i].initDict(A) #Initialize party member.
			formation[i].slot      = i
			formation[i].row       = 0 if i < ROW_SIZE else 1 #Assign row.
			formation[i].group     = self #Set group to this one.
			formation[i].inventory = inventory.initPersonal(A.inventory if 'inventory'  in A else [], formation[i])
		else:
			formation[i] = null

func giveXP(amount:int) -> void: #Gives <amount> experience to all party members in formation.
	for i in formation:
		if i != null:
			print("[GROUP_GUILD][giveXP] Giving %d XP to %s" % [amount, i.name])
			i.giveXP(amount)

func giveDGem(G) -> bool: #Add a DGem to inventory.
	#TODO: Make -> bool, return status in case inventory is full!
	if typeof(G) == TYPE_ARRAY:
		var DG:DragonGem = DragonGem.new(G[0], G[1])
		dragonGems.push_back(DG)
	elif G is DragonGem:
		dragonGems.push_back(G)
	sortDGems()
	return true

func giveItem(I) -> bool:
	inventory.giveConsumable(Item.new(inventory.getFreeSlot(), Item.ITEM_CONSUMABLE, I))
	return true

func sortDGems() -> void: #Sort DGem inventory.
	#TODO: Maybe it should be a sorting rule.
	var result:Array = []
	for i in dragonGems:
		if i != null:
			result.push_back(i)
	dragonGems = result

func rosterSize() -> int: #Get roster size.
	var count:int = 0
	for i in range(roster.size()):
		count += 1 if roster[i] != null else 0
	return count

func partySize() -> int: #Get party size (1-6 ideally)
	var count:int = 0
	for i in range(formation.size()):
		if formation[i] != null:
			count += 1 if formation[i].incapacitated != false else 0
	return count

func partyStatus() -> Array:
	var alive:int = 0
	var down:int  = 0
	for i in formation:
		if i.condition == core.skill.CONDITION_DOWN:
			down += 1
		else:
			alive += 1
	return [ alive, down ]

func loadJson(json): #Process a JSON file with guild data here. A save file basically.
	var dict:Dictionary = {} #TODO: Actually do that.
	return init(dict)

func loadDebug() -> void: #Load debug "save file".
	var f = preload("res://data/debug_guild.gd").new()
	var data = f.data
	if not data:
		print("[!]: Couldn't load guild data")
		return
	init(data)

func getFormationSlot(n): #Get member in a given slot.
	return formation[n]

func healAll() -> void: #Heals all party members.
	for i in formation:
		if i != null:
			i.condition = core.skill.CONDITION_GREEN
			i.condition2 = 0
			i.fullHeal()

func restoreAll() -> void: #Heals all party members, restores all weapon durability.
	for i in formation:
		if i != null:
			i.condition = core.skill.CONDITION_GREEN
			i.condition2 = 0
			i.fullHeal()
			if i is core.Player: i.equip.fullRepair(true)

func on_hour_pass() -> void: #Hook for time passing.
	inventory.updateCharges()
