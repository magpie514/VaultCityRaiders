const FIELD_EFFECT_SIZE = 12
const FIELD_LAST = FIELD_EFFECT_SIZE - 1
var data:Array   = core.valArray(0, FIELD_EFFECT_SIZE)              #Element Field layout
var bonus:Array  = core.newArray(9)                                 #Bonus per element
var chain:Array  = core.newArray(9)                                 #Amount of chains per element
var chains:int   = 0                                                #Calculated amount of chains
var unique:int   = 0                                                #Count of individual elements
var maxChain:int = 0                                                #Highest chain
var hyper:int    = 0                                                #G-Dominion "always optimal field". 0 = disabled, 1 = party, 2 = enemy
var dominant:int = 0                                                #Dominant element
var locked:int   = 0

var frange = range(FIELD_EFFECT_SIZE)	#Some optimization.

func _init() -> void:
	print("[FIELD_EFFECT] Initializing element field. Size: %d" % FIELD_EFFECT_SIZE)
	data.resize(FIELD_EFFECT_SIZE)
	for i in data:
		i = 0 as int
	for i in range(bonus.size()):
		bonus[i] = 0
		chain[i] = 0

func init(t = null) -> void:
	match(typeof(t)):
		TYPE_ARRAY: #Specify field layout.
			fill(0) #Set the field to untyped first.
			if t.size() <= FIELD_EFFECT_SIZE: #Don't push more than the array size. It'd be pointless.
				for i in range(t.size()):
					push(int(t[i]))
		TYPE_INT: #Specify element fill.
			fill(t)
		TYPE_NIL:
			random(0)

func getBonus(elem:int, side:int = 0) -> float:
	if hyper != 0 and side == hyper:	return 2.0 #G-Dominion bonus.
	else                           : return (float(bonus[elem]) * .01)

func fieldMod(elem:int, mult:float) -> float:
	return 1.0 + ( getBonus(elem) * mult )

func calculate(x:float, elem:int = 0, mult:float = 1.0) -> float:
	if elem == 0: return x #No element mod so don't mess the current value.
	var rawBonus:int = round(float(bonus[elem]) * mult) as int
	var FEbonus:float = fieldMod(elem, mult)
	print("[FIELD EFFECT][calculate] Element: %d | FE Bonus: %d | (%d x %d) ((%d + %d) x %d = %d)" % [
		elem, bonus[elem],
		getBonus(elem), mult,
		x, rawBonus, FEbonus,
		(rawBonus + x) * FEbonus
	])
	return round((rawBonus + x) * FEbonus)

func update() -> void:
	var last:int         = 0                           #Storage for last element.
	var temp:int         = 0                           #Temp buffer.
	var highestChain:int = 0                           #Highest detected chain.
	var chainCount:int   = 0                           #Amount of chains.
	var chainElem:int    = 0                           #Temp var to determine element of a chain.
	var _chains:Array    = core.newArray(bonus.size()) #Stores the values of all chains per element.
	var totalChains:int  = 0                           #Total chain values?
	var elemCount:int    = 0                           #Count of unique elements.
	var highest:int      = 0                           #Dominant element.
	for i in range(bonus.size()):
		bonus[i] = 0
		_chains[i] = 0
	for i in frange:
		temp = data[i]
		if temp != 0:
			bonus[temp] += 1
			if temp == last and last != 0: #Chain
				if chainElem != temp:
					_chains[temp] += 1
					chainElem = temp
				chainCount += 1
				if chainCount > highestChain: highestChain = chainCount
				bonus[temp] += 1 #if temp != 0 else 0
				if bonus[temp] >= 23: bonus[temp] = 25
			else:
				chainCount = 0
				chainElem = 0
			last = temp
	temp = 0
	for i in range(bonus.size()):
		totalChains += _chains[i]
		elemCount += 1 if bonus[i] > 0 else 0
		if bonus[i] > temp:
			highest = i
			temp = bonus[i]
	maxChain = highestChain + 1 if highestChain > 0 else 0
	chains = totalChains
	unique = elemCount
	dominant = highest

func push(elem:int) -> void:
	if locked > 0: return
	for i in range(FIELD_EFFECT_SIZE - 1):
		data[i] = data[i + 1]
	data[FIELD_EFFECT_SIZE - 1] = elem
	update()

func pop() -> int:
	var tmp:int = data[FIELD_LAST]
	data[FIELD_LAST] = 0
	shiftRight()
	return tmp

func passTurn() -> void:
	if locked > 0:
		locked -= 1

func lock(n:int) -> void:
	locked = n if locked == 0 else (n - 1)

func unlock() -> void:
	locked = 0

func setHyper(side:int) -> void:
	hyper = side

func pushMulti(elem:int, times:int) -> void:
	if locked > 0: return
	var total = times if times < FIELD_EFFECT_SIZE else FIELD_EFFECT_SIZE
	for i in range(total):
		push(elem)

func fill(elem:int) -> void:
	if locked > 0: return
	for i in data:
		i = elem

func fullReset() -> void:
	for i in data:
		i = 0
	update()

func random(t:int) -> void:
	if locked > 0: return
	match(t):
		0: #Random fill
			for i in frange: data[i] = randi() % 9
		1: #Random fill, no empty spaces.
			for i in frange: data[i] = 1 + (randi() % 8)
		2: #Random fill with increased chance of a chain.
			var el:int = 0
			for i in range(FIELD_EFFECT_SIZE):
				if el != 0 and core.chance(50):
					data[i] = el
				else:
					el = randi() % 9
					data[i] = el
		3: #Fill with random element (except untyped)
			var el:int = 1 + (randi() % 8)
			fill(el)
	update()

func optimize() -> void: #Simply sorts all elements. This makes repeats form a chain.
	if locked > 0: return
	data.sort()
	update()

func replace(elem1:int, elem2:int) -> void: #Replace all instances of elem1 for elem2.
	if locked > 0: return
	for i in frange:
		if data[i] == elem1: data[i] = elem2
	update()

func fillChance(elem:int, chance:int) -> void: #Fill all slots with elem, but with a chance for every slot.
	if locked > 0: return
	for i in frange:
		if core.chance(chance):	data[i] = elem
	update()

func replaceChance(elem1:int, elem2:int, chance:int) -> void: #Replace all elem1 for elem2 with a random chance every slot.
	if locked > 0: return
	for i in frange:
		if data[i] == elem1:
			if core.chance(chance): data[i] = elem2
	update()

func replaceChance2(elem:int, chance:int) -> void: #Wait this is the same as fillchange what?
	if locked > 0: return
	for i in frange:
		if core.chance(chance): data[i] = elem
	update()

func consume(elem:int, elem2:int = 0) -> void: #Remove all elem. Replace by elem2 if specified.
	if locked > 0: return
	for i in frange:
		if data[i] == elem: data[i] = elem2
	data.sort_custom(self.Sorters, "_consume_sort")
	update()

func take(amount:int, elem:int, elem2:int = 0) -> int:
	#Take amount icons of elem. Replace by elem2 if specified.
	if locked > 0 or amount <= 0: return 0
	var taken = 0
	for j in range(amount):
		for i in frange:
			if data[i] == elem:
				data[i] = elem2
				taken += 1
				break
	data.sort_custom(self.Sorters, "_consume_sort")
	update()
	return taken

func shift(amount:int, right:bool = true ) -> void: #Shift all elements right
	if locked > 0: return
	for i in range(amount):
		if right: shiftRight()
		else    : shiftLeft()
	update()

func shiftRight() -> void: #Shift all elements to the right
	var temp:int = data[FIELD_EFFECT_SIZE-1]
	for i in range(FIELD_EFFECT_SIZE-1, 0, -1):
		data[i] = data[i - 1]
	data[0] = temp

func shiftLeft() -> void: #Shift all elements to the left
	for i in range(FIELD_EFFECT_SIZE-1):
		data[i] = data[i + 1]
	data[0] = 0


class Sorters:
	static func _consume_sort(a, b):
		if a == 0: return true
		else:      return false
