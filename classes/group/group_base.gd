const FRONT_ROW = 0
const BACK_ROW = 1

var name : String = ""
var formation = null
var lastElement : int = 0
var versus = null

func getRow(row, size) -> Array:
	var result = []
	var st = row * size
	for i in range(st, st + size):
		if formation[i] != null:
			result.push_front(formation[i])
	return result

func getRowIter(row) -> Array:
	return []

func getEmptySlots(row = -1, size = 3) -> Array:
	var result = []
	if row >= 0:
		var st = row * size
		for i in range(st, st + size):
			if formation[i] == null:
				result.push_front(i)
	elif row == -1:
		for i in range(formation.size()):
			if formation[i] == null:
				result.push_front(i)
	return result

func swapMembers(slot1, slot2):
	var tmp = formation[slot1]
	formation[slot1] = formation[slot2]
	formation[slot1].slot = slot1
	formation[slot2] = tmp
	formation[slot2].slot = slot2
	formation[slot1].refreshRow()
	formation[slot2].refreshRow()

func activeMembers() -> Array:
	var m = []
	for i in formation:
		if i != null:
			if i.isAble():
				m.push_back(i)
	return m

func activeCount():
	var count = 0
	for i in formation:
		if i != null:
			if i.isAble():
				count += 1
	return count

func emptySlot() -> bool:
	var result: bool = false
	for i in formation:
		if i == null:
			result = true
			break
	return result

func countRowTargets(row, size, S) -> int:
	var rowMembers = getRow(row, size)
	var result : int = 0
	var st = row * size
	for i in rowMembers:
		if i != null and i.filter(S):
			result += 1
	return result

func getRowTargets2(row, size, S):
	var rowMembers = getRow(row, size)
	var result = []
	for i in rowMembers:
		if i != null and i.filter(S):
			result.push_front(i)
	return result

func getSpreadTargets2(row, size, S, slot):
	var result = []
	var st = row * size
	for i in range(st, st+size):
		if i == slot:
			print("[getSpreadTargets2] found slot %d" % slot)
			for j in range(slot-1, st-1, -1):
				print("[getSpreadTargets2] prev slot %d %s" % [j, formation[j]])
				if formation[j] != null and formation[j].filter(S):
					print("OK")
					result.push_front(formation[j])
					break
			for j in range(slot+1, st+size):
				print("[getSpreadTargets2] next slot %d %s" % [j, formation[j]])
				if formation[j] != null and formation[j].filter(S):
					print("OK")
					result.push_front(formation[j])
					break
	return result


func getDefeated() -> int:
	return 0

func getWeakestTarget(S):
	var candidates = []
	for i in formation:
		if i != null and i.filter(S):
			candidates.push_front(i)
	if candidates.size() > 0:
		candidates.sort_custom(self, "_sort_Weakest")
		return candidates[0]
	return null

func getHealthiestTarget(S):
	var candidates = []
	for i in formation:
		if i != null and i.filter(S):
			candidates.push_front(i)
	if candidates.size() > 0:
		candidates.sort_custom(self, "_sort_Healthiest")
		return candidates[0]
	return null

static func _sort_Weakest(a, b):
	if a.HP > b.HP: return 0
	return 1

static func _sort_Healthiest(a, b):
	if a.HP < b.HP: return 0
	return 1

func getAllTargets(S):
	var result = []
	for i in formation:
		if i != null and i.filter(S):
			result.push_front(i)
	return result

func getAllTargetsNotSelf(S, who):
	var result = []
	for i in formation:
		if i != null and i.filter(S) and i != who:
			result.push_front(i)
	return result

func getRandomTarget(S):
	var result = getAllTargets(S)
	return [result[randi() % result.size()]] #RNG

func getRandomRowTarget(row, S):
	var result = getRowTargets(row, S)
	return [result[randi() % result.size()]] #RNG

func getRowSize(): #To be overriden by extends.
	return 0

func getSpreadTargets(row, S, slot): #Get targets around the given target in given row.
	return getSpreadTargets2(row, getRowSize(), S, slot)

func getRowTargets(row, S): #Get all targets in the given row
	return getRowTargets2(row, getRowSize(), S)

func getRowTargetsNotSelf(row, S, user): #Get targets in row except self.
	var rowMembers = getRow(row, getRowSize())
	var result = []
	for i in rowMembers:
		if i != null and i.filter(S):
			result.push_front(i)
	return result

func getOtherRowTargets(row, S): #Get targets in the other row.
	var otherRow : int = 0 if row == 1 else 1
	return getRowTargets2(otherRow, getRowSize(), S)

func initBattle() -> void:
	for i in formation:
		if i != null:
			i.initBattle()


func initBattleTurn() -> void:
	for i in formation:
		if i != null:
			i.initBattleTurn()

func endBattleTurn() -> void:
	for i in formation:
		if i != null:
			i.endBattleTurn()

func findEffects(S) -> bool:
	for i in formation:
		if i != null:
			if i.findEffects(S):
				return true
	return false

func countEffects(S) -> int:
	var count : int = 0
	for i in formation:
		if i != null:
			if i.findEffects(S):
				count += 1
	return count
