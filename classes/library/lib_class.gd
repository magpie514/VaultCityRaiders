extends "res://classes/library/lib_base.gd"
var skill = core.skill

var example = {
	"debug" : {
		"debug" : {
			name = "DEBUG",
			description = "Debug class with high stat growth.",
			statSpread = [ [004, 001, 001, 001, 001, 001, 001], [052, 032, 032, 032, 032, 032, 032] ],
			weapons = [skill.WPCLASS_HANDGUN],
			skills = [
				["debug", "debug"],
				["debug", "debugi"],
				["debug", "debugi2"],
			],
		},
		"ofight" : { #Jay Hawking's story mode base class.
			name = "Orbital Fighter",
			description = "A technical class specializing in exploiting enemy actions and status.",
			statSpread = [ [005, 000, 000, 003, 002, 004, 001], [032, 000, 006, 032, 024, 052, 018] ],
			weapons = [skill.WPCLASS_ARTILLERY, skill.WPCLASS_FIREARM, skill.WPCLASS_SHIELD, skill.WPCLASS_LONGSWORD],
			skills = [
				["story", "plasfeld"],
				["story", "thunswrd"], #Move to ORBITAL Cannon.
				# Core skills #########
				["debug", "restshrd"],
				["story", "freerang"],
				#Filler
				["debug", "gmissile"],
				["debug", "gatebrkr"],
				["debug", "codexalt"],
				["debug", "blddance"],
			],
		},
		"gdriver" : { #0a0a-DT-KSSG "Magpie" Miller's story mode base class.
			name = "G-Driver",
			description = "A technical class specializing in exploiting enemy actions and status.",
			statSpread = [ [004, 000, 000, 003, 002, 003, 001], [032, 000, 006, 032, 024, 040, 018] ],
			weapons = [skill.WPCLASS_ARTILLERY, skill.WPCLASS_FIREARM, skill.WPCLASS_SHIELD, skill.WPCLASS_POLEARM],
			skills = [
				# Gun skills ##########
				["debug", "trikshot"],
				["debug", "focushot"],
				# Core skills #########
				["debug", "restshrd"],
				["story", "gravrefl"],
				["story", "gmissile"],
				["story", "gatebrkr"], #Make an Over skill?
				["story", "codexalt"], #Make an Over skill?
				# Glaive/Auger skills #
				["story", "gemshrap"], #Move to Boost Glaive.
				["story", "spirbost"],
			],
		},
		"akashic" : { #Aohana Yukiko's story mode base class.
			name = "Akashic Knight",
			description = "A technical class specializing in exploiting enemy actions and status.",
			statSpread = [ [004, 000, 000, 003, 002, 003, 001], [032, 000, 006, 032, 024, 040, 018] ],
			weapons = [skill.WPCLASS_HANDGUN, skill.WPCLASS_SHORTSWORD, skill.WPCLASS_SHIELD],
			skills = [
				["debug", "defdown"],
				["debug", "speedup"],
				["debug", "srnauror"],
				["debug", "elemshot"],
				["debug", "heatngtr"],
				["story", "dncsword"],
				["debug", "kamaita"],
			],
		},
		"muramasa" : { #Kurohara Shiro's story mode base class.
			name = "Muramasa",
			description = "A defensive class specializing in high defensive maneuvers, counters, and ghostly abilities",
			statSpread = [ [004, 000, 000, 003, 002, 003, 001], [032, 000, 006, 032, 024, 040, 018] ],
			weapons = [skill.WPCLASS_SHIELD, skill.WPCLASS_SHORTSWORD, skill.WPCLASS_LONGSWORD],
			skills = [
				#Needs huge rework. I need a Japanese dictionary pronto.
				["debug", "defdown"],
				["debug", "barricad"],
				["debug", "solidbun"],
				["debug", "decoy"],
			],
		},
		"incinera" : { #Anna Westenra's story mode base class.
			name = "Incinerator",
			description = "Brutal fighter using the power of flames and time.",
			weapons = [skill.WPCLASS_ARTILLERY, skill.WPCLASS_SHORTSWORD, skill.WPCLASS_POLEARM],
			statSpread = [ [004, 004, 001, 002, 001, 000, 002], [040, 048, 008, 022, 008, 008, 024] ],
			skills = [
				#Define Anna's roles better.
				["debug", "vampdran"],
				["debug", "overclck"],
				["debug", "lunablaz"],
				["debug", "savaripp"],
			],
		},
		"esper" : {
			name = "ESPer",
			description = "A physically weak fighter but with powerful psychic abilities. Their physical fragility makes them better on the back row.",
			weapons = [skill.WPCLASS_HANDGUN, skill.WPCLASS_SHIELD, skill.WPCLASS_SHORTSWORD],
			statSpread = [ [002, 000, 000, 003, 000, 002, 003], [018, 002, 002, 048, 024, 022, 028] ],
			skills = [
				["debug", "illusion"],
			],
		},
		"riot" : {
			name = "Riot",
			description = "A heavily defensive fighter with heavy armor and defenses, ideal for the front lines, but their skill with firearms makes them usable at the back, too.",
			weapons = [skill.WPCLASS_FIREARM, skill.WPCLASS_SHIELD, skill.WPCLASS_HAMMER],
			statSpread = [ [005, 002, 005, 000, 001, 000, 002], [050, 020, 048, 000, 012, 004, 016] ],
			skills = [
				["debug", "barricad"],
				["debug", "solidbun"],
			],
		},
		"idol" : {
			name = "Idol",
			description = "Support class designed to assist the whole team. The agility required for their cheerful dances can allow them to be efficient fighters, too.",
			weapons = [skill.WPCLASS_FIREARM, skill.WPCLASS_SHIELD, skill.WPCLASS_HAMMER],
			statSpread = [ [005, 002, 005, 000, 001, 000, 002], [050, 020, 048, 000, 012, 004, 016] ],
			skills = [
				["debug", "speedup"],
			],
		},
		"fengshui" : {
			name = "Feng-Shui",
			description = "Adept fighters that can utilize environmental energies for a variety of skills. They are usually better suited for the back row.",
			weapons = [skill.WPCLASS_FIREARM, skill.WPCLASS_SHIELD, skill.WPCLASS_HAMMER],
			statSpread = [ [005, 002, 005, 000, 001, 000, 002], [050, 020, 048, 000, 012, 004, 016] ],
			skills = [
				["debug", "elemshot"],
			],
		},
		"rider" : {
			name = "Rider",
			description = "Adventurers that compensate their lack of combat skills with various machines to ride. While their growth is fully dependent on their ride, that makes them highly versatile.",
			weapons = [skill.WPCLASS_FIREARM, skill.WPCLASS_SHIELD],
			statSpread = [ [000, 000, 000, 000, 000, 000, 000], [010, 000, 000, 000, 000, 000, 008] ],
			skills = [
			],
		},
		"salarymn" : {
			name = "Salaryman",
			description = "Untrained adventurers unsatisfied with their office jobs. However, the spirit of adventure burns strong within them, and are full of potential.",
			weapons = [skill.WPCLASS_FIREARM, skill.WPCLASS_SHIELD, skill.WPCLASS_HAMMER],
			statSpread = [ [005, 002, 005, 000, 001, 000, 002], [050, 020, 048, 000, 012, 004, 016] ],
			skills = [
			],
		},
		"medic" : {
			name = "Medic",
			description = "Specialized healers trying to keep the party alive.",
			weapons = [skill.WPCLASS_HANDGUN, skill.WPCLASS_SHIELD],
			statSpread = [ [002, 001, 001, 002, 004, 000, 002], [020, 016, 008, 022, 048, 008, 024] ],
			skills = [
				["debug", "heal"],
				["debug", "rowheal"],
				["debug", "prtyheal"],
			],
		},
	}
}

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING },
		"description" : { loader = LIBSTD_STRING },
		"weapons" : { loader = LIBSTD_VARIABLEARRAY, default = [ core.skill.WPCLASS_SHIELD ] },
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
