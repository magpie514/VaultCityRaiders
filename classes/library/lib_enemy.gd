extends "res://classes/library/lib_base.gd"
var skill = core.skill

const LIBEXT_AIPATTERN = "loaderAIPattern"

enum {
	AIPATTERN_SIMPLE,
	AIPATTERN_PICK_RANDOMLY,
	AIPATTERN_PICK_2_IF_WEAK,
	AIPATTERN_PICK_2_IF_RANK,
	AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY,
	AIPATTERN_PICK_2_IF_CAN_REVIVE,
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
			spriteFile = "res://resources/images/flame_from_beyond.png",
			description = "An anomaly of time, burning with the heat from times unknown.",
			statSpread = [
				[0045, 001, 038, 012, 015, 011, 005],
				[0250, 001, 135, 125, 096, 120, 050]
			],
			OFF = [ 100, 100, 100,  150, 100, 100,  100, 100, 100 ],
			RES = [ 075, 075, 125,  005, 125, 050,  100, 100, 110 ],
			race = skill.RACE_ELDRITCH, aspect = skill.RACEF_SPI,
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
			skill = [ ["gem", "firewave"], ["debug", "memebeyo"] ]
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
			OFF = [ 100, 100, 100,  100, 100, 100,  100, 100, 100 ],
			RES = [ 090, 100, 090,  120, 100, 100,  100, 100, 100 ],
			race = skill.RACE_MACHINE, aspect = skill.RACEF_MEC,
			defeatMsg = "%s exploded!",
			ai = 1,
			aiPattern = {
				pattern = [
#					[AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY, [1, AITARGET_RANDOM], [2, AITARGET_RANDOM]],
					[AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY, [3, AITARGET_SELF], [2, AITARGET_RANDOM]],
					[AIPATTERN_PICK_RANDOMLY, 050, [2, AITARGET_RANDOM], [0, AITARGET_RANDOM]],
					[AIPATTERN_PICK_2_IF_WEAK, 050, [3, AITARGET_SELF], [0, AITARGET_RANDOM]],
				],
				flags = 0,
				loopFrom = 1,
			},
			skill = [ ["debug", "alertstc"], ["debug", "defdown"], ["debug", "shoot"], ["core", "defend"] ]
		}, "debug1": {
			name = "Solid Debugger",
			description = "Combat testing robot specialized in high kinetic defense.",
			statSpread = [[0045, 010, 030, 010, 010, 010, 010], [0500, 100, 300, 100, 100, 100, 100]],
			OFF = [ 100, 100, 100,  100, 100, 100,  100, 100, 100 ],
			RES = [ 090, 100, 090,  120, 100, 100,  100, 100, 100 ],
			race = skill.RACE_MACHINE, aspect = skill.RACEF_MEC,
			defeatMsg = "%s exploded!",
			ai = 0,
			skill = [ ["core", "defend"], ["debug", "bash"] ]
		}, "debug2": {
			name = "Barrier Debugger",
			description = "Combat testing robot specialized in high energy defense.",
			statSpread = [[0045, 010, 010, 010, 030, 010, 010], [0500, 100, 100, 100, 300, 100, 100]],
			OFF = [ 100, 100, 100,  100, 100, 100,  100, 100, 100 ],
			RES = [ 090, 100, 090,  120, 100, 100,  100, 100, 100 ],
			race = skill.RACE_MACHINE, aspect = skill.RACEF_MEC,
			defeatMsg = "%s exploded!",
			ai = 0,
			skill = [ ["debug", "shoot"] ]
		}, "debug3": {
			name = "Speed Debugger",
			description = "Combat testing robot specialized in high mobility.",
			statSpread = [[0045, 010, 010, 010, 010, 030, 030], [0500, 100, 100, 100, 100, 300, 300]],
			OFF = [ 100, 100, 100,  100, 100, 100,  100, 100, 100 ],
			RES = [ 090, 100, 090,  120, 100, 100,  100, 100, 100 ],
			race = skill.RACE_MACHINE, aspect = skill.RACEF_MEC,
			defeatMsg = "%s exploded!",
			ai = 0,
			skill = [ ["debug", "slash"], ["debug", "shoot"], ["debug", "decoy"] ]
		},
		"debug4": {
			name = "Repair Debugger",
			description = "Combat testing robot specialized in team maintenance.",
			statSpread = [[0045, 010, 010, 010, 030, 010, 030], [0500, 100, 100, 100, 300, 100, 300]],
			OFF = [ 100, 100, 100,  100, 100, 100,  100, 100, 100 ],
			RES = [ 090, 100, 090,  120, 100, 100,  100, 100, 100 ],
			race = skill.RACE_MACHINE, aspect = skill.RACEF_MEC,
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
			skill = [ ["core", "defend"], ["debug", "heal"], ["enemy", "repair"] ]
		},
		"compiler": {
			name = "Compiler",
			spriteFile = "res://resources/images/compiler.png",
			description = "Combat testing drone. A glorified moving turret. Vanilla scented.",
			statSpread = [
				[0015, 001, 008, 012, 008, 011, 005],
				[0200, 001, 095, 125, 096, 120, 050]
			],
			OFF = [ 100, 100, 100,  100, 100, 100,  100, 100, 100 ],
			RES = [ 100, 100, 100,  150, 100, 100,  100, 100, 100 ],
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
			skill = [ ["debug", "shoot"], ["debug", "sprshot"] ]
		}, "compiler2": {
			name = "Repair Compiler",
			description = "Combat testing drone. A glorified moving turret. Chocolate scented.",
			statSpread = [
				[0015, 001, 008, 012, 008, 011, 005],
				[0200, 001, 095, 125, 096, 120, 050]
			],
			OFF = [ 100, 100, 100,  100, 100, 100,  100, 100, 100 ],
			RES = [ 100, 100, 100,  150, 100, 100,  100, 100, 100 ],
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
			skill = [ ["core", "defend"], ["debug", "shoot"], ["debug", "heal"] ]
		}
	}
}

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING },											#Enemy name
		"spriteFile" : { loader = LIBSTD_STRING, default = "res://resources/images/test.png"},
		"energyColor" : { loader = LIBSTD_STRING, default = "#AAFFFF" },
		"summons" : { loader = LIBSTD_SUMMONS },									#Summon data
		"canResurrect" : { loader = LIBSTD_BOOL, default = true },#If the enemy can be resurrected. If not, it won't be added to the resurrect list.
		"description" : { loader = LIBSTD_STRING },								#Enemy description
		"statSpread" : { loader = LIBSTD_STATSPREAD },						#Stat spread
		"armed" : { loader = LIBSTD_BOOL, default = false },			#If enemy is supposed to be wielding a weapon or not.
		"OFF" : { loader = LIBSTD_ELEMENTDATA },									#Elemental offense
		"RES" : { loader = LIBSTD_ELEMENTDATA },									#Elemental defense
		"race" : { loader = LIBSTD_INT },													#Race type (for "slayer" effects)
		"aspect" : { loader = LIBSTD_INT },										#Race aspects (BIO/MEC/SPI), affects vulnerability to certain effects.
		"defeatMsg" : { loader = LIBSTD_STRING, default = "%s was defeated!" },			#Message to display when defeated. "%s倒した！"
		"ai" : { loader = LIBSTD_INT },														#AI mode
		"aiPattern" : { loader = LIBEXT_AIPATTERN },							#AI pattern
		"skill" : { loader = LIBSTD_SKILL_LIST },									#Skill list
	}


func name(id):
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"

func getStatSpread(id):
	var entry = getIndex(id)
	return entry.statSpread

func loadDebug():
	loadDict(example)
	print("Monster library:")
	#printData()

func parseAISkill(S, defaultTarget = AITARGET_RANDOM) -> Array:
	match typeof(S):
		TYPE_INT:
			return [int(S), defaultTarget]
		TYPE_NIL:
			return [0, defaultTarget]
		TYPE_ARRAY:
			return [int(S[0]), int(S[1])]
		_:
			return [0, defaultTarget]

func parseAIPattern(line) -> Array:
	if line == null or typeof(line) != TYPE_ARRAY:
		return [AIPATTERN_SIMPLE, parseAISkill(0)]
	match line[0]:
		AIPATTERN_SIMPLE:
			return [AIPATTERN_SIMPLE, parseAISkill(line[1])]
		AIPATTERN_PICK_2_IF_WEAK:
			return [AIPATTERN_PICK_2_IF_WEAK, int(line[1]), parseAISkill(line[2]), parseAISkill(line[3])]
		AIPATTERN_PICK_2_IF_RANK:
			return [AIPATTERN_PICK_2_IF_RANK, int(line[1]), parseAISkill(line[2]), parseAISkill(line[3])]
		AIPATTERN_PICK_RANDOMLY:
			return [AIPATTERN_PICK_RANDOMLY, int(line[1]), parseAISkill(line[2]), parseAISkill(line[3])]
		AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY:
			return [AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY, parseAISkill(line[1]), parseAISkill(line[2])]
		AIPATTERN_PICK_2_IF_CAN_REVIVE:
			return [AIPATTERN_PICK_2_IF_CAN_REVIVE, parseAISkill(line[1]), parseAISkill(line[2])]
		_:
			return [AIPATTERN_SIMPLE, parseAISkill(0)]

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
