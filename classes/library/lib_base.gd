#Data library base class.
#This is a helper to generate dictionaries with proper typing, organization, JSON loading and all the things.


var data:Dictionary = {}
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

func initTemplate(): #VIRTUAL: Returns the working template dictionary.
	return null

func initEntry(entry, base:Dictionary = {}):
	if template != null:
		return parseTemplate(entry, base)
	else:
		core.aprint("[EE] CRITICAL: No datalib template defined. This could explode.", core.ANSI_RED2)
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

func loadDict(dict) -> void: #Starts the loading of a library entry.
	var second_pass:Array = []
	for key in dict:
		data[key] = {}
		for key2 in dict[key]: #At this point we are checking for keys in the x/y format.
			if 'inherits' in dict[key][key2]:
				var tmp_tid = core.tid.from(dict[key][key2].inherits)
				core.aprint("INHERITS: %s" % tmp_tid, core.ANSI_PINK2)
				if tmp_tid[0] in data and tmp_tid[1] in data[tmp_tid[0]]: #Ideal situation, the thing we want to inherit from is already defined.
					core.aprint("%s found. Using as base." % tmp_tid, core.ANSI_PINK2)
					data[key][key2] = initEntry(dict[key][key2], data[tmp_tid[0]][tmp_tid[1]])
					data[key][key2].self_tid = "%s/%s" % [key, key2] #Add a key with its own TID.
				else: #Not so ideal, the entry hasn't been defined yet. We need a second pass.
					core.aprint("%s not found. Adding %s to second pass." % [tmp_tid, [key, key2]], core.ANSI_PINK2)
					second_pass.append([key, key2])
					data[key][key2] = {} #Add empty so we can see if an entry is meant to exist or not.
			else:
				data[key][key2] = initEntry(dict[key][key2])
				data[key][key2].self_tid = "%s/%s" % [key, key2] #Add a key with its own TID.
	if second_pass.size() > 0: #See if we have pending entries.
		core.aprint("%s entries pending." % second_pass.size(), core.ANSI_PINK2)
		var tries:int = 0
		var remaining:Array = []
		for i in second_pass: #Verify if the inheritances exist or not.
			var tmp_tid = core.tid.from(dict[i[0]][i[1]].inherits)
			core.aprint("%s inherits from: %s" % [i,tmp_tid], core.ANSI_PINK2)
			if tmp_tid[0] in data and tmp_tid[1] in data[tmp_tid[0]]: #The parent entry to inherit exists, we continue with it.
				core.aprint("%s inherits from a valid TID, continuing." % [i], core.ANSI_PINK2)
				remaining.append([i[0], i[1]])
			else: #The parent entry doesn't exist. Mistake or typo, what can one do with this?
				core.aprint("%s inherits from an invalid TID, dropping. Adding entry with defaults for sanity." % [i], core.ANSI_RED2)
				data[i[0]][i[1]] = initEntry(dict[i[0]][i[1]], initEntry({})) #Modify a dummy entry with defaults. It won't work as intended but it'll have all the variables.
				data[i[0]][i[1]].self_tid = "%s/%s" % [i[0],i[1]] #Add a key with its own TID.

		while remaining.size() > 0 and tries < 20: #Final step. Now we got to load things until we run out of things to load.
			core.aprint("%s valid entries pending." % remaining.size(), core.ANSI_PINK2)
			var temp:Array = remaining.duplicate()
			remaining.clear()
			for i in temp:
				var tmp_tid = core.tid.from(dict[i[0]][i[1]].inherits)
				if tmp_tid[0] in data and tmp_tid[1] in data[tmp_tid[0]]:
					if data[tmp_tid[0]][tmp_tid[1]].empty(): #This means the entry has been defined but not loaded, keep trying.
						core.aprint("%s not found. Trying again." % tmp_tid, core.ANSI_PINK2)
						remaining.append(i)
					else: #The entry is defined and loaded, we can load this.
						core.aprint("%s found. Using as base." % tmp_tid, core.ANSI_PINK2)
						data[i[0]][i[1]] = initEntry(dict[i[0]][i[1]], data[tmp_tid[0]][tmp_tid[1]])
						data[i[0]][i[1]].self_tid = "%s/%s" % [i[0],i[1]] #Add a key with its own TID.
			tries += 1 #Just in case, we'll give up after a bunch of tries.


func parseTemplate(dict:Dictionary, base:Dictionary = {}) -> Dictionary:
	return parseSubTemplate(template, dict, base)

func parseSubTemplate(sub:Dictionary, dict:Dictionary, base:Dictionary = {}) -> Dictionary:
	#TODO:Add a way to define a way to crop numeric values to a given range.
	var result:Dictionary = base.duplicate(true)
	if not base.empty():
		core.aprint("Inheriting from %s:" % base.name, core.ANSI_PINK2)
		for key in dict:
			if key != 'inherits':
				core.aprint("- Overwriting key [%s]: <%s> => <%s>" % [key, base[key], dict[key]], core.ANSI_PINK2)
				result[key] = loadKey(sub[key].loader, dict[key])
		return result
	for key in sub:
		if key in dict:
			result[key] = loadKey(sub[key].loader, dict[key])
		else:
			if 'default' in sub[key]:
				result[key] = loadKey(sub[key].loader, sub[key].default)
			else:
				result[key] = loadKey(sub[key].loader, null)
	return result

func loadKey(loader, val):
	var result = call(loader, val)
	return result

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

func printData() -> void:
	for key in data:
		for key2 in data[key]:
			core.aprint("[%s/%s]: %s" % [key, key2, data[key][key2]])

func getData() -> Array:
	var result:Array = []
	for key in data:
		for key2 in data[key]:
			result.push_back([key, key2])
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


func loaderStatSpread(val) -> Array:
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
		#  CUT  PIE  BLU   FIR  ICE  ELE  UNK  ULT  KIN  NRG
			[100, 100, 100,  100, 100, 100, 100, 100, 100, 100]
		]
	else:
		var result:Array = copyIntegerArray(val)
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
								for i in range(1, 11):
									match(skill.opCodeType(result[j][0])):
										skill.OPTYPE_INT:
											result[j][i] = int(line[1])
										skill.OPTYPE_FLOAT:
											result[j][i] = float(line[1])
										skill.OPTYPE_STR:
											result[j][i] = str(line[1])
								result[j][11] = int(line[2])
							11: # Instruction + values for 10 levels
								result[j][0] = skill.translateOpCode(line[0])
								for i in range(1, 11):
									match(skill.opCodeType(result[j][0])):
										skill.OPTYPE_INT:
											result[j][i] = int(line[i])
										skill.OPTYPE_FLOAT:
											result[j][i] = float(line[i])
										skill.OPTYPE_STR:
											result[j][i] = str(line[i])
							12: # Instruction + values for 10 levels + flags
								result[j][0] = skill.translateOpCode(line[0])
								for i in range(1, 11):
									match(skill.opCodeType(result[j][0])):
										skill.OPTYPE_INT:
											result[j][i] = int(line[i])
										skill.OPTYPE_FLOAT:
											result[j][i] = float(line[i])
										skill.OPTYPE_STR:
											result[j][i] = str(line[i])
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
		#print("[LIB_BASE][loaderConditionDefs] Condition Defenses: ", val)
		for i in range(val.size()):
			result[i] = int(val[i])
	return result
