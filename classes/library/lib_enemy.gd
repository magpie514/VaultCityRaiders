extends "res://classes/library/lib_base.gd"
var skill = core.skill
const LIBEXT_AIPATTERN   = "loaderAIPattern"
const LIBEXT_SKILL_SETUP = "loaderSkillSetup"
const LIBEXT_ENEMY_SKILL = "loaderEnemySkills"

const SKILLSETUP_ERROR   = [ [ [0,1], [1,1], [2,1], [3,1] ] ]
enum {
	AIPATTERN_SIMPLE,
	AIPATTERN_PICK_RANDOMLY,
	AIPATTERN_PICK_2_IF_WEAK,
	AIPATTERN_PICK_2_IF_RANK,
	AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY,
	AIPATTERN_PICK_2_IF_CAN_REVIVE,
	AIPATTERN_PICK_2_IF_NIGHT,
	AIPATTERN_PICK_2_IF_DAY,
}

enum {
	AIPATTERN_LOOP,
	AIPATTERN_LOOP_SKIP_FIRST,
}

enum {
	AITARGET_SELF,
	AITARGET_RANDOM,
	AITARGET_WEAKEST,
	AITARGET_ALLY_WEAKEST,
	AITARGET_SUMMONER
}


var example = {
	"story" : {
		"lunablaz": {
			name = "Flame From Beyond",
			description = "An anomaly of time, burning with heat from times unknown.",
			statSpread = [
				[0045, 001, 038, 012, 015, 011, 005],
				[0250, 001, 135, 125, 096, 120, 050]
			],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 02, 05, 03, 03, 09, 08, 02, 09, 99, 08],
			OFF = [ 100,100,100,  150,100,100,  100,100,  100,100 ],
			RES = [ 075,075,125,  005,125,050,  100,100,  100,110 ],
			race = core.RACE_ELDRITCH, aspect = core.RACEF_SPI,
			canResurrect = false,
			defeatMsg = "%s returned to the void!",
			ai = 1,
			aiPattern = {
				pattern = [
					[AIPATTERN_SIMPLE, [0, AITARGET_SUMMONER]],
					[AIPATTERN_SIMPLE, [0, AITARGET_RANDOM]],
					[AIPATTERN_SIMPLE, [1, AITARGET_SUMMONER]],
				],
				flags = AIPATTERN_LOOP,
			},
			skills = [ "gem/firewave", "debug/memebeyo" ],
		}
	},
	"debug" : {
		"debug": {
			name = "Debugger",
			description = "Combat testing robot. Vanilla flavored.",
			statSpread = [
				#HP    ATK  DEF  ETK  EDF  AGI  LUC
				[0045, 010, 010, 010, 010, 010, 010],
				[0500, 100, 100, 100, 100, 100, 100]
			],
			OFF = [ 100,100,100, 100,100,100, 100,100, 100,100 ],
			RES = [ 090,100,090, 120,100,100, 100,100, 100,100 ],
			race = core.RACE_MACHINE, aspect = core.RACEF_MEC,
			defeatMsg = "%s exploded!",
			ai = 1,
			aiPattern = {
				pattern = [
					[AIPATTERN_SIMPLE, [2, AITARGET_WEAKEST]],
#					[AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY, [1, AITARGET_RANDOM], [2, AITARGET_RANDOM]],
#					[AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY, [3, AITARGET_SELF], [2, AITARGET_RANDOM]],
#					[AIPATTERN_PICK_RANDOMLY, 050, [2, AITARGET_RANDOM], [0, AITARGET_RANDOM]],
#					[AIPATTERN_PICK_2_IF_WEAK, 050, [3, AITARGET_SELF], [0, AITARGET_RANDOM]],
				],
				flags = 0,
				loopFrom = 1,
			},
			skills     = [ "debug/alertstc", "debug/defdown", "debug/shoot", "core/defend" ],
			skillSetup = [ [ [0,1], [1,1], [2,1], [3,1] ], [ [0,2], [1,3], [2,2], [3,4] ] ],
		}, "debug1": {
			name = "Solid Debugger",
			description = "Combat testing robot specialized in high kinetic defense.",
			statSpread = [[0045, 010, 030, 010, 010, 010, 010], [0500, 100, 300, 100, 100, 100, 100]],
			OFF = [ 100,100,100, 100,100,100, 100,100, 100,100 ],
			RES = [ 090,100,090, 120,100,100, 100,100, 100,100 ],
			race = core.RACE_MACHINE, aspect = core.RACEF_MEC,
			defeatMsg = "%s exploded!",
			ai = 0,
			skills = [ "core/defend", "debug/bash" ]
		}, "debug2": {
			name = "Barrier Debugger",
			description = "Combat testing robot specialized in high energy defense.",
			statSpread = [[0045, 010, 010, 010, 030, 010, 010], [0500, 100, 100, 100, 300, 100, 100]],
			OFF = [ 100,100,100, 100,100,100, 100,100, 100,100 ],
			RES = [ 090,100,090, 120,100,100, 100,100, 100,100 ],
			race = core.RACE_MACHINE, aspect = core.RACEF_MEC,
			defeatMsg = "%s exploded!",
			ai = 0,
			skills = [ ["debug", "shoot"] ]
		}, "debug3": {
			name = "Speed Debugger",
			description = "Combat testing robot specialized in high mobility.",
			statSpread = [[0045, 010, 010, 010, 010, 030, 030], [0500, 100, 100, 100, 100, 300, 300]],
			OFF = [ 100,100,100, 100,100,100, 100,100, 100,100 ],
			RES = [ 090,100,090, 120,100,100, 100,100, 100,100 ],
			race = core.RACE_MACHINE, aspect = core.RACEF_MEC,
			defeatMsg = "%s exploded!",
			ai = 0,
			skills = [ ["debug", "slash"], ["debug", "shoot"], ["debug", "decoy"] ]
		},
		"debug4": {
			name = "Repair Debugger",
			description = "Combat testing robot specialized in team maintenance.",
			statSpread = [[0045, 010, 010, 010, 030, 010, 030], [0500, 100, 100, 100, 100, 100, 300]],
			OFF = [ 100,100,100, 100,100,100, 100,100, 100,100 ],
			RES = [ 090,100,090, 120,100,100, 100,100, 100,100 ],
			race = core.RACE_MACHINE, aspect = core.RACEF_MEC,
			defeatMsg = "%s exploded!",
			ai = 1,
			aiPattern = {
				pattern = [
#					[AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY, [1, AITARGET_RANDOM], [2, AITARGET_RANDOM]],
					[AIPATTERN_PICK_2_IF_CAN_REVIVE, [1, AITARGET_ALLY_WEAKEST], [2, AITARGET_SELF]],
				],
				flags = 0,
				loopFrom = 1,
			},
			skills = [ ["core", "defend"], ["debug", "heal"], ["enemy", "repair"] ]
		},
		"compiler": {
			name = "Compiler",
			description = "Combat testing drone. A glorified moving turret. Vanilla scented.",
			statSpread = [
				[0015, 001, 008, 012, 008, 011, 005],
				[0200, 001, 095, 125, 096, 120, 050]
			],
			OFF = [ 100,100,100, 100,100,100, 100,100, 100,100 ],
			RES = [ 090,100,090, 120,100,100, 100,100, 100,100 ],
			defeatMsg = "%s exploded!",
			ai = 1,
			aiPattern = {
				pattern = [
					[AIPATTERN_SIMPLE, [0, AITARGET_RANDOM]],
					[AIPATTERN_SIMPLE, [0, AITARGET_RANDOM]],
					[AIPATTERN_SIMPLE, [1, AITARGET_RANDOM]],
				],
				flags = AIPATTERN_LOOP|AIPATTERN_LOOP_SKIP_FIRST,
			},
			skills = [ ["debug", "shoot"], ["debug", "sprshot"] ]
		}, "compiler2": {
			name = "Repair Compiler",
			description = "Combat testing drone. A glorified moving turret. Chocolate scented.",
			statSpread = [
				[0015, 001, 008, 012, 008, 011, 005],
				[0200, 001, 095, 125, 096, 120, 050]
			],
			OFF = [ 100,100,100, 100,100,100, 100,100, 100,100 ],
			RES = [ 090,100,090, 120,100,100, 100,100, 100,100 ],
			weakThreshold = 025,
			defeatMsg = "%s exploded!",
			ai = 1,
			aiPattern = {
				pattern = [
					[AIPATTERN_SIMPLE, [1, AITARGET_RANDOM]],
					[AIPATTERN_PICK_2_IF_WEAK, 025, [1,AITARGET_RANDOM], [0, AITARGET_SELF]],
					[AIPATTERN_PICK_2_IF_RANK, 300, [1, AITARGET_ALLY_WEAKEST], [0, AITARGET_SELF]],
					[AIPATTERN_SIMPLE, [2, AITARGET_ALLY_WEAKEST]],
					[AIPATTERN_PICK_RANDOMLY, 50, [1, AITARGET_RANDOM], [2, AITARGET_ALLY_WEAKEST]],
				],
				flags = AIPATTERN_LOOP|AIPATTERN_LOOP_SKIP_FIRST,
			},
			flavorScript = {
				opener = [
					[1, "SYSTEMS SWITCHED TO COMBAT MODE"],
				],
			},
			skills = [ ["core", "defend"], ["debug", "shoot"], ["debug", "heal"] ]
		}
	}
}

func initTemplate():
	return {
		"name"         : { loader = LIBSTD_STRING },                      #Enemy name
		"spriteFile"   : { loader = LIBSTD_STRING, default = "res://resources/images/Char/debug.json"},
		"energyColor"  : { loader = LIBSTD_STRING, default = "#AAFFFF" }, #Energy effect color.
		"summons"      : { loader = LIBSTD_SUMMONS },                     #Summoner (or reinforcement) data.
		"monster"      : { loader = LIBSTD_BOOL, default = false },       #If the enemy is a monster that can be captured/tamed.
		"canResurrect" : { loader = LIBSTD_BOOL, default = true },        #If the enemy can be resurrected. If not, it won't be added to the resurrect list.
		"description"  : { loader = LIBSTD_STRING },                      #Enemy description.
		"statSpread"   : { loader = LIBSTD_STATSPREAD },                  #Stat spread.
		# Condition defenses                                         PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
		"conditionDefs": { loader = LIBSTD_CONDITIONDEFS, default = [ 03, 04, 04, 04, 03, 03, 03, 03, 03, 03] },
		"armed"        : { loader = LIBSTD_BOOL, default = false },       #If enemy is supposed to be wielding a weapon or not.
		"OFF"          : { loader = LIBSTD_ELEMENTDATA, default = [ 100,100,100, 100,100,100, 100,100, 100,100 ] }, #Elemental offense.
		"RES"          : { loader = LIBSTD_ELEMENTDATA, default = [ 100,100,100, 100,100,100, 100,100, 100,100 ] }, #Elemental defense.
		"race"         : { loader = LIBSTD_INT },                         #Race type (for "slayer/brand" effects)
		"aspect"       : { loader = LIBSTD_INT },                         #Race aspects (BIO/MEC/SPI), affects vulnerability to certain effects.
		"defeatMsg"    : { loader = LIBSTD_STRING, default = "%s was defeated!" },	#Message to display when defeated. "%s倒した！"
		"ai"           : { loader = LIBSTD_INT },                         #AI mode
		"aiPattern"    : { loader = LIBEXT_AIPATTERN },	                  #AI pattern
		"skills"       : { loader = LIBEXT_ENEMY_SKILL },                 #Enemy skill list.
		"skillSetup"   : { loader = LIBEXT_SKILL_SETUP, default = [ [ [0,1], [1,1], [2,1], [3,1] ] ] },  #Skill setup [skill array index, level]
	}


func name(id) -> String:
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"

func getStatSpread(id):
	var entry = getIndex(id)
	return entry.statSpread

func loadDebug() -> void:
	loadDict(example)
	print("Monster library:")
	#printData()

func loaderSkillSetup(val) -> Array:
	var result:Array = []
	if typeof(val) != TYPE_ARRAY: #Must be an array.
		print("[ !][LIB_ENEMY][loaderSkillSetup] Setup array is not an array.")
		return SKILLSETUP_ERROR.duplicate(true)
	for i in range(val.size()):
		if typeof(val[i]) != TYPE_ARRAY: #Must be an array.
			print("[ !][LIB_ENEMY][loaderSkillSetup] Malformed setup array.")
			return SKILLSETUP_ERROR.duplicate(true)
		else:
			var temp:Array = core.newArray(4)
			for j in range(4):
				temp[j] = val[i][j] if j < val[i].size() else SKILLSETUP_ERROR[0][j]
			result.push_front(temp)
	print(result)
	return result

func loaderEnemySkills(val) -> Array:
	if val == null:
		return [ loaderTID(null), loaderTID(null), loaderTID(null), loaderTID(null) ]
	else:
		var vs:int       = val.size()
		var s:int        = max(vs, 4) as int
		var result:Array = []
		for i in range(s):
			if i < vs: result.push_back(loaderTID(val[i]))
			else     : result.push_back(loaderTID(null))
		return result

func parseAISkill(S, defaultTarget = AITARGET_RANDOM) -> Array:
	match typeof(S):
		TYPE_INT  : return [int(S), defaultTarget]
		TYPE_NIL  : return [0, defaultTarget]
		TYPE_ARRAY: return [int(S[0]), int(S[1])]
		_         : return [0, defaultTarget]

func parseAIPattern(line) -> Array:
	if line == null or typeof(line) != TYPE_ARRAY: return [AIPATTERN_SIMPLE, parseAISkill(0)]
	match line[0]:
		AIPATTERN_SIMPLE                       : return [AIPATTERN_SIMPLE, parseAISkill(line[1])]
		AIPATTERN_PICK_2_IF_WEAK               : return [AIPATTERN_PICK_2_IF_WEAK, int(line[1]), parseAISkill(line[2]), parseAISkill(line[3])]
		AIPATTERN_PICK_2_IF_RANK               : return [AIPATTERN_PICK_2_IF_RANK, int(line[1]), parseAISkill(line[2]), parseAISkill(line[3])]
		AIPATTERN_PICK_RANDOMLY                : return [AIPATTERN_PICK_RANDOMLY, int(line[1]), parseAISkill(line[2]), parseAISkill(line[3])]
		AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY: return [AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY, parseAISkill(line[1]), parseAISkill(line[2])]
		AIPATTERN_PICK_2_IF_CAN_REVIVE         : return [AIPATTERN_PICK_2_IF_CAN_REVIVE, parseAISkill(line[1]), parseAISkill(line[2])]
		_                                      : return [AIPATTERN_SIMPLE, parseAISkill(0)]

func loaderAIPattern(dict):
	if dict == null:
		return null
	var result = {}
	if dict.pattern != null:
			result.pattern = []
			result.pattern.resize(dict.pattern.size())
			for i in range(dict.pattern.size()):
				result.pattern[i] = parseAIPattern(dict.pattern[i])
	print("AI pattern:", result)
	return result
