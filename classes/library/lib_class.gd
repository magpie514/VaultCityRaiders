extends "res://classes/library/lib_base.gd"

var example = {
	"debug" : {
		"debug" : {
			name = "DEBUG",
			description = "Debug class with high stat growth.",
			statSpread = [ [004, 001, 001, 001, 001, 001, 001], [052, 032, 032, 032, 032, 032, 032] ],
			skills = [
				["debug", "debug"],
				["debug", "debugi"],
				["debug", "debugi2"],
			],
		},
		"ofight" : {
			name = "Orbital Fighter",
			description = "A technical class specializing in exploiting enemy actions and status.",
			statSpread = [ [005, 000, 000, 003, 002, 004, 001], [032, 000, 006, 032, 024, 052, 018] ],
			skills = [
				["story", "plasfeld"],
				["story", "thunswrd"],
				["debug", "restshrd"],
				["debug", "nrgshild"],
				["debug", "gmissile"],
				["debug", "gatebrkr"],
				["debug", "codexalt"],
				["debug", "blddance"],
			],
		},
		"gdriver" : {
			name = "G-Driver",
			description = "A technical class specializing in exploiting enemy actions and status.",
			statSpread = [ [004, 000, 000, 003, 002, 003, 001], [032, 000, 006, 032, 024, 040, 018] ],
			skills = [
				["debug", "trikshot"],
				["debug", "focushot"],
				["debug", "restshrd"],
				["debug", "nrgshild"],
				["debug", "gmissile"],
				["debug", "gatebrkr"],
				["debug", "codexalt"],
				["debug", "blddance"],
			],
		},
		"akashic" : {
			name = "Akashic Knight",
			description = "A technical class specializing in exploiting enemy actions and status.",
			statSpread = [ [004, 000, 000, 003, 002, 003, 001], [032, 000, 006, 032, 024, 040, 018] ],
			skills = [
				["debug", "defdown"],
				["debug", "speedup"],
				["debug", "srnauror"],
				["debug", "elemshot"],
				["debug", "heatngtr"],
				["debug", "dncsword"],
				["debug", "kamaita"],
			],
		},
		"esper" : {
			name = "ESPer",
			description = "A balanced fighter with powerful psychic abilities.",
			statSpread = [ [002, 000, 000, 003, 000, 002, 003], [018, 002, 002, 048, 024, 022, 028] ],
			skills = [
				["debug", "illusion"],
				["debug", "rosegrdn"],
			],
		},
		"bard" : {
			name = "bard",
			description = "Ooh, spoony!",
			statSpread = [ [002, 000, 000, 001, 002, 003, 003], [016, 004, 008, 016, 024, 048, 032] ],
			skills = [
				["debug", "defdown"],
				["debug", "speedup"],
			],
		},
		"defender" : {
			name = "Defender",
			description = "A highly durable fighter capable of withstanding the mightiest of blows.",
			statSpread = [ [005, 002, 005, 000, 001, 000, 002], [050, 020, 048, 000, 012, 004, 016] ],
			skills = [
				["debug", "barricad"],
				["debug", "solidbun"],
			],
		},
		"medic" : {
			name = "Medic",
			description = "Specialized healers trying to keep the party alive.",
			statSpread = [ [002, 001, 001, 002, 004, 000, 002], [020, 016, 008, 022, 048, 008, 024] ],
			skills = [
				["debug", "heal"],
				["debug", "rowheal"],
				["debug", "prtyheal"],
			],
		},
		"incinera" : {
			name = "Incinerator",
			description = "Brutal fighter using the power of flames and time.",
			statSpread = [ [004, 004, 001, 002, 001, 000, 002], [040, 048, 008, 022, 008, 008, 024] ],
			skills = [
				["debug", "vampdran"],
				["debug", "overclck"],
				["debug", "lunablaz"],
			],
		}
	}
}

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING },
		"description" : { loader = LIBSTD_STRING },
		"statSpread" : { loader = LIBSTD_STATSPREAD },
		"skills" : { loader = LIBSTD_SKILL_LIST },
	}

func loadDebug():
	loadDict(example)
	print("Class library:")
#	printData()

func name(id):
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"

func getStatSpread(id):
	var entry = getIndex(id)
	return entry.statSpread

func printData():
	var entry = null
	for key1 in data:
		print("[%8s]" % key1)
		for key2 in data[key1]:
			entry = data[key1][key2]
			print(" [%8s]Name: %12s, Stats[HP:%03d-%03d|ATK:%03d-%03d|DEF:%03d-%03d|ETK:%03d-%03d|EDF:%03d-%03d|AGI:%03d-%03d|LUC:%03d-%03d]" %
				[
					key2,
					entry.name,
					entry.statSpread[0][0], entry.statSpread[1][0],
					entry.statSpread[0][1], entry.statSpread[1][1],
					entry.statSpread[0][2], entry.statSpread[1][2],
					entry.statSpread[0][3], entry.statSpread[1][3],
					entry.statSpread[0][4], entry.statSpread[1][4],
					entry.statSpread[0][5], entry.statSpread[1][5],
					entry.statSpread[0][6], entry.statSpread[1][6],
			  ])
