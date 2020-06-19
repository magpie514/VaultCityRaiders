var data = {}
var template = initTemplate()

const LIBSTD_BOOL          = "loaderBool"
const LIBSTD_INT           = "loaderInt"
const LIBSTD_FLOAT         = "loaderFloat"
const LIBSTD_STRING        = "loaderString"
const LIBSTD_TID           = "loaderTID"
const LIBSTD_TID_OR_NULL   = "loaderTIDorNull"
const LIBSTD_TID_ARRAY     = "loaderTIDArray"
const LIBSTD_VARIABLEARRAY = "loaderVariableArray"
const LIBSTD_STATSPREAD    = "loaderStatSpread"
const LIBSTD_CONDITIONDEFS = "loaderConditionDefs"
const LIBSTD_STATBONUS     = "loaderStatBonus"
const LIBSTD_ELEMENTDATA   = "loaderElementData"
const LIBSTD_SKILL_ARRAY   = "loaderSkillArray"
const LIBSTD_SKILL_LIST    = "loaderSkillList"
const LIBSTD_SUMMONS       = "loaderSummons"
const LIBSTD_SKILL_CODE    = "loaderSkillCode"

func initTemplate():
	return null

func initEntry(entry):
	if template != null:
		return parseTemplate(entry)
	else:
		print("[EE] CRITICAL: No datalib template defined. This is gonna explode.")
		return null

func loadJson(json):
	pass

func loadGD(file):
	var f = load(file).new()
	var dat = f.dat
	if not dat:
		return null
	else:
		print(dat)
		return dat

func loadDict(dict):
	for key in dict:
		data[key] = {}
		for key2 in dict[key]:
			data[key][key2] = initEntry(dict[key][key2])

func copyIntegerArray(a:Array) -> Array:
	var size:int     = a.size()
	var result:Array = core.newArray(size)
	for i in range(size):
		result[i] = int(a[i])
	return result

func getIndex(id:Array):
	if typeof(id) != TYPE_ARRAY:
		print("[!!] Given library TID is not an array. Attempting to return failsafe.")
		return data["debug"]["debug"]
	if id.size() != 2:
		print("[!!] Given library TID is not an array of two elements. Attempting to return failsafe.")
		return data["debug"]["debug"]
	if id[0] in data:
		if id[1] in data[id[0]]:
			return data[id[0]][id[1]]
	print("[!!] Given library TID [%s/%s] not found. Attempting to return failsafe." % [id[0], id[1]])
	return data["debug"]["debug"]

func printData():
	for key in data:
		for key2 in data[key]:
			print("[%s/%s]: %s" % [key, key2, data[key][key2]])

func getData() -> Array:
	var result:Array = []
	for key in data:
		for key2 in data[key]:
			result.push_back([key, key2])
	return result

func loadKey(loader, val):
	var result = call(loader, val)
	return result

func parseTemplate(dict:Dictionary) -> Dictionary:
	return parseSubTemplate(template, dict)

func parseSubTemplate(sub:Dictionary, dict:Dictionary):
	#TODO:Add a way to define a way to crop numeric values to a given range.
	var result:Dictionary = {}
	for key in sub:
		if key in dict:
			result[key] = loadKey(sub[key].loader, dict[key])
		else:
			if 'default' in sub[key]:
				result[key] = loadKey(sub[key].loader, sub[key].default)
			else:
				result[key] = loadKey(sub[key].loader, null)
	return result

# Standard loaders #############################################################

func loaderBool(val):
	if val == null:
		return false
	else:
		return bool(val)

func loaderInt(val) -> int:
	if val == null:
		return int(0)
	else:
		return int(val)

func loaderFloat(val) -> float:
	if val == null:
		return float(0.0)
	else:
		return float(val)

func loaderString(val) -> String:
	if val == null:
		return "NULL"
	else:
		return str(val)

func loaderVariableArray(val) -> Array:
	var result:Array = []
	if val == null:
		return result
	else:
		result.resize(val.size())
		for i in range(val.size()):
			result[i] = int(val[i])
		return result


func loaderStatSpread(val):
	if val == null:
		return [
		#  HP   ATK  DEF  ETK  EDF  AGI  LUC
			[000, 000, 000, 000, 000, 000, 000],
			[000, 000, 000, 000, 000, 000, 000]
		]
	else:
		return [ copyIntegerArray(val[0]), copyIntegerArray(val[1]) ]


func loaderElementData(val) -> Array:
	if val == null:
		return [
		#  CUT  PIE  BLU   FIR  ICE  ELE   ULT  KIN  NRG
			[100, 100, 100,  100, 100, 100,  100, 100, 100]
		]
	else:
		var result = copyIntegerArray(val)
		result.push_front(int(000)) #DMG_UNTYPED entry.
		return result

func loaderTID(val):
	if val == null:
		return core.tid.create("debug", "debug")
	else:
		return core.tid.from(val)

func loaderTIDorNull(val):
	if val == null: return null
	else:
		#TODO: Verify if it's properly constructed.
		return core.tid.from(val)

func loaderTIDArray(val):
	if val == null:
		return null
	else:
		var result:Array = []
		for i in val:
			var tmp = loaderTID(i)
			result.push_back(tmp)
		return result

func loaderSkillList(val) -> Array:
	if val == null:
		return [ loaderTID(null) ]
	else:
		var result:Array = []
		for i in val:
			result.push_back(loaderTID(i))
		return result

func loaderSkillArray(val) -> Array:
	var SIZE:int     = 10
	var result:Array = core.newArray(SIZE)
	match(typeof(val)):
		TYPE_INT:
			for i in range(SIZE):
				result[i] = int(val)
		TYPE_BOOL:
			for i in range(SIZE):
				result[i] = int(1) if val else int(0)
		TYPE_ARRAY:
			var temp:int = val.size()
			for i in range(SIZE):
				if i > temp:
					result[i] = int(val[temp])
				else:
					result[i] = int(val[i])
		TYPE_NIL:
			for i in range(SIZE):
				result[i] = int(0)
	return result

func loaderStatBonus(val) -> Dictionary:
	var result:Dictionary = {}
	for ar in [core.stats.STATS, core.stats.ELEMENT_MOD_TABLE]:
		for i in ar:
			if i in val:
				result[i] = val[i]
	return result

func loaderSkillCode(a): #Loads skill codes.
	var skill = core.skill
	var _template = core.skill.LINE_TEMPLATE

	match(typeof(a)): #Check input type
		TYPE_NIL:
			#Input is null, this skill isn't meant to have code, so we return null back.
			return null
		TYPE_ARRAY:
			#Input is an array. This is the expected input, so we process it further.
			var result = core.newArray(a.size())
			var line = null #Placeholder for the current line.
			for j in a.size():
				line = a[j]
				result[j] = _template.duplicate(true) #Initialize line as a copy of the template, saves the trouble of keeping sync.
				match(typeof(line)): #Determine line format.
					TYPE_STRING: #Line is just an instruction, usually a 'get' with default values.
						result[j][0] = skill.translateOpCode(line)
					TYPE_ARRAY:  #We have an array, the standard instruction. There are a few variants.
						match(line.size()):
							1:  # Instruction only, in case one wants to keep it as array for consistency.
								result[j][0] = skill.translateOpCode(line[0])
							2:  # Instruction + flags
								result[j][0] = skill.translateOpCode(line[0])
								result[j][11] = int(line[1])
							3:  # Instruction + single value + flags
								result[j][0] = skill.translateOpCode(line[0])
								for i in range(1, 11): result[j][i] = int(line[1])
								result[j][11] = int(line[2])
							11: # Instruction + values for 10 levels
								result[j][0] = skill.translateOpCode(line[0])
								for i in range(1, 11): result[j][i] = int(line[i])
							12: # Instruction + values for 10 levels + flags
								result[j][0] = skill.translateOpCode(line[0])
								for i in range(1, 11): result[j][i] = int(line[i])
								result[j][11] = int(line[11])
							_:  # Unexpected line. Print an error.
								print("\t[!!][SKILL][loaderSkillCode] Line size is not normal, returning null line.")
					_: # Unexpected type. Print an error.
						print("\t[!!][SKILL][loaderSkillCode] Line is neither string or array, returning null line.")
			return result
		_:
			#Input is...something else. Likely user error. Return a line with no effect as a last resort.
			print("\t[!!][SKILL][loaderSkillCode] Provided skill code is not an array. Please verify. ")
			return [ _template.duplicate() ]

func loaderSummons(val):
	if val == null or typeof(val) != TYPE_ARRAY:
		return null
	var result:Array = []
	for i in range(val.size()):
		var tmp = val[i]
		var entry:Dictionary = {}
		entry.tid         = core.tid.from(tmp.tid if "tid" in tmp else ["debug", "debug"])
		entry.level       = int(tmp.level if "level" in tmp else 1)
		entry.amount      = int(tmp.amount if "amount" in tmp else 1)
		entry.amount      = int(clamp(entry.amount, 0, 4)) #Prevent more than 4 summons at once because come on.
		entry.chance      = int(tmp.chance if "chance" in tmp else 95)
		entry.restrictRow = int(tmp.restrictRow if "restrictRow" in tmp else 0)
		entry.msg         = str(tmp.msg if "msg" in tmp else "{name} came to help!")
		entry.failmsg     = str(tmp.failmsg if "failmsg" in tmp else "But nobody came...")
		entry.center      = bool(tmp.center if "center" in tmp else true)
		result.push_back(entry)
	return result

func loaderConditionDefs(val) -> Array:
	var result:Array = core.valArray(0, core.CONDITIONDEFS_DEFAULT.size())
	if val.size() != core.CONDITIONDEFS_DEFAULT.size():
		print("[!!][LIB_BASE][loaderConditionDefs] Condition Defenses array of incorrect size.")
		var s:int = val.size()
		for i in range(core.CONDITIONDEFS_DEFAULT.size()): #Use template's size since this could be longer.
			if i <= s: #Since this value is in range, let's use whatever the array has.
				result[i] = val[i]
			else:      #If not just take the default values.
				result[i] = core.CONDITIONDEFS_DEFAULT[i]
	else:
		print("[LIB_BASE][loaderConditionDefs] Condition Defenses: ", val)
		for i in range(val.size()):
			result[i] = int(val[i])
	return result
