# Group (container of members)
# This is either the player group (the "guild") or the enemy group (in combat)
# It is meant to perform management on the whole group, and provide information.

const FRONT_ROW = 0                            #The front row.
const BACK_ROW  = 1                            #The back row. Wow.
const MON_ROW   = 2                            #The front row that is really the summoned monster row.
const ROW_SIZE  = 3                            #Amount of members in every row.
const MAX_SIZE  = ROW_SIZE * 2                 #Max size of standard group (mons not included)
const ROW_ITER  = [ [0,1,2],[3,4,5] ]  #Iterators for each row. For convenience. Order is front, back, mon.

enum {
	EVENT_ON_DEFEAT = 0, #Triggered when any character is defeated on the field.
}

var name:String           = ""   #Name of the group.
var formation             = null #Formation of the group (pointers to characters)
var lastElement:int       = 0    #Last element used by the group.
var FEguard:int           = 0    #Chance (0-100%) to prevent standard additions to the element field.
var versus                = null #Pointer to opposing group.

# Virtuals ########################################################################################
func getDefeated() -> int: return 0 #Get number of defeated group members.
###################################################################################################

# Battle turn hooks ###############################################################################
func initBattle() -> void: #Executed at the start of a battle.
	lastElement = 0
	FEguard = 0
	for i in formation:
		if i != null: i.initBattle()

func initBattleTurn() -> void: #Executed at the start of a turn.
	lastElement = 0
	FEguard = 0
	for i in formation:
		if i != null: i.initBattleTurn()

func endBattleTurn() -> void: #Executed at the end of a turn.
	for i in formation:
		if i != null: i.endBattleTurn()
###################################################################################################

# Management ######################################################################################

func swapMembers(slot1, slot2) -> void: #Swap two member slots.
	var tmp = formation[slot1] #What type was this?
	formation[slot1] = formation[slot2]
	formation[slot1].slot = slot1
	formation[slot2] = tmp
	formation[slot2].slot = slot2
	formation[slot1].refreshRow()
	formation[slot2].refreshRow()

###################################################################################################

# Counting and statistics #########################################################################
func activeCount() -> int: #Count active (able) number of members.
	var count:int = 0
	for i in formation:
		if i != null:
			if i.isAble(): count += 1
	return count

func countRowTargets(row:int, S) -> int: #Count possible targets in row.
	var rowMembers:Array = getRow(row)
	var result:int       = 0
	var st:int           = row * ROW_SIZE
	for i in rowMembers:
		if i != null and i.filter(S): result += 1
	return result
###################################################################################################

# Targeting functions #############################################################################
func activeMembers() -> Array:
	var result:Array = []
	for i in formation:
		if i != null:
			if i.isAble(): result.push_back(i)
	return result

func getRow(row:int) -> Array: #Get all members in the given row.
	var result:Array = []
	var st:int = row * ROW_SIZE #Start position
	for i in range(st, st + ROW_SIZE):
		if formation[i] != null:
			result.push_front(formation[i])
	return result

func getRowIter(row) -> Array: #Get iterator for a row.
	return ROW_ITER[row % 2]

func getEmptySlots(row:int = -1) -> Array:
	var result:Array = []
	if row >= 0:
		var st = row * ROW_SIZE
		for i in range(st, st + ROW_SIZE):
			if formation[i] == null: result.push_front(i)
	elif row == -1:
		for i in range(formation.size()):
			if formation[i] == null: result.push_front(i)
	return result

func emptySlot() -> bool:
	var result:bool = false
	for i in formation:
		if i == null:
			result = true
			break
	return result

func getAllTargets(S) -> Array:
	var result:Array = []
	for i in formation:
		if i != null and i.filter(S): result.push_front(i)
	return result

func getAllTargetsNotSelf(S, who) -> Array:
	var result:Array = []
	for i in formation:
		if i != null and i.filter(S) and i != who:
			result.push_front(i)
	return result

func getRandomTarget(S) -> Array:
	var result:Array = getAllTargets(S)
	return [result[randi() % result.size()]] #RNG

func getRandomRowTarget(row, S) -> Array:
	var result:Array = getRowTargets(row, S)
	return [result[randi() % result.size()]] #RNG

func getRowTargets(row:int, S) -> Array: #Get all targets in the given row
	var rowMembers:Array = getRow(row)
	var result:Array     = []
	for i in rowMembers:
		if i != null and i.filter(S): result.push_front(i)
	return result

func getRowTargetsNotSelf(row, S, user): #Get targets in row except self.
	var rowMembers:Array = getRow(row)
	var result:Array     = []
	for i in rowMembers:
		if i != null and i.filter(S): result.push_front(i)
	return result

func getOtherRowTargets(row, S): #Get targets in the other row.
	var otherRow:int = 0 if row == 1 else 1
	return getRowTargets(otherRow, S)

func getWeakestTarget(S):
	var candidates:Array = []
	for i in formation:
		if i != null and i.filter(S):
			candidates.push_front(i)
	if candidates.size() > 0:
		candidates.sort_custom(self, "_sort_Weakest")
		return candidates[0]
	return null

func getHealthiestTarget(S):
	var candidates:Array = []
	for i in formation:
		if i != null and i.filter(S):
			candidates.push_front(i)
	if candidates.size() > 0:
		candidates.sort_custom(self, "_sort_Healthiest")
		return candidates[0]
	return null

func getSpreadTargets(row:int, S, slot:int) -> Array: #Get all subtargets around a given target and its row.
	var result:Array = []
	var st:int       = row * ROW_SIZE
	for i in range(st, st + ROW_SIZE):
		if i == slot:
			print("[getSpreadTargets2] found slot %d" % slot)
			for j in range(slot-1, st-1, -1):
				print("[getSpreadTargets2] prev slot %d %s" % [j, formation[j]])
				if formation[j] != null and formation[j].filter(S):
					print("OK")
					result.push_front(formation[j])
					break
			for j in range(slot+1, st+ROW_SIZE):
				print("[getSpreadTargets2] next slot %d %s" % [j, formation[j]])
				if formation[j] != null and formation[j].filter(S):
					print("OK")
					result.push_front(formation[j])
					break
	return result

###################################################################################################

# Effect related ##################################################################################

func findEffects(S) -> bool: #Find if the party has a specific skill effect.
	for i in formation:
		if i != null:
			if i.findEffects(S):
				return true
	return false

func countEffects(S) -> int: #Count instances of the specific skill effect.
	var count:int = 0
	for i in formation:
		if i != null:
			if i.findEffects(S): count += 1
	return count

###################################################################################################

# Sorter functions ################################################################################
static func _sort_Weakest(a, b):
	if a.HP > b.HP: return 0
	return 1

static func _sort_Healthiest(a, b):
	if a.HP < b.HP: return 0
	return 1
###################################################################################################
