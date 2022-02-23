extends "res://classes/library/lib_base.gd"
var skill = core.skill

var example = {
	"story" : {
		"cromwell" : { #Cromwell (Guest version) player class.
			name = "Creator",
			description = "A class oriented to focus the powerful abilities of an Originator",
			statSpread = [ [005,004,002,004,002,004,005], [048,050,020,050,020,048,032] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 99, 01, 99, 99, 99, 01, 02, 99, 99, 03],
			weapons = [ core.WPCLASS_LONGSWORD ],
			skills = [
				"story/origilaw",
				"story/terranig",
			],
		},
		"tiamat" : { #Tiamat (Guest version) player class.
			name = "Creator",
			description = "A class oriented to focus the powerful abilities of an Originator",
			statSpread = [ [005,004,002,004,002,004,005], [048,050,020,050,020,048,032] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 99, 01, 99, 99, 99, 01, 02, 99, 99, 03],
			weapons = [ core.WPCLASS_FIST ],
			skills = [
				"story/origilaw",
			],
		},
		"fantome0" : { #Fantôme player class.
			name = "Phantom Thief",
			description = "A true trickster with mysterious abilities and great support.",
			statSpread = [ [005,004,002,004,002,004,005], [048,050,020,050,020,048,032] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 99, 01, 99, 99, 99, 01, 02, 99, 99, 03],
			weapons = [ core.WPCLASS_POLEARM ],
			skills = [
			],
		},
		"fantome1" : { #0A07-DT-PHANTOM player class.
			name = "G-Knight",
			description = "A brutal melee class with some field manipulation abilities.",
			statSpread = [ [005,004,002,004,002,004,005], [048,050,020,050,020,048,032] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 99, 01, 99, 99, 99, 01, 02, 99, 99, 03],
			weapons = [ core.WPCLASS_LONGSWORD ],
			skills = [
				"debug/gatebrkr",
				"story/gdomini0",
			],
		},

		"ash0" : { #Ash (guest version) player class.
			name = "Lone Striker",
			description = "A well-balanced attack class.",
			statSpread = [ [005,004,002,004,002,004,005], [048,050,020,050,020,048,032] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 99, 01, 99, 99, 99, 01, 02, 99, 99, 03],
			weapons = [ core.WPCLASS_FIREARM ],
			skills = [
			],
		},
		"milenium" : { #Professor Millennium (Arthur Bristol Miller) player class.
			name = "G-Crusher",
			description = "A class combining hidden knowledge of time and space with brutal melee combat.",
			lore        = "Professor Millennium's contributions to science were only matched by his cold, calculated and extremely brutal combat abilities.",
			statSpread = [ [005,004,002,004,002,004,005], [048,050,020,050,020,048,032] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 99, 01, 99, 99, 99, 01, 02, 99, 99, 03],
			weapons = [ core.WPCLASS_FIST ],
			skills = [
				"story/gravrefl",
				"story/gmissile",
				"debug/gatebrkr",
				"story/gdomini0",
			],
		},
		"dachief" : { #Chief John Redgrave's player class.
			name = "DGPD Chief",
			description = "A gunner class oriented to high consistent damage.",
			lore        = "He was already known for his ability to win impossible battles before he was pushed beyond mortal limits.",
			statSpread = [ [005,004,002,004,002,004,005], [048,050,020,050,020,048,032] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 99, 01, 99, 99, 99, 01, 02, 99, 99, 03],
			weapons = [ core.WPCLASS_ARTILLERY, core.WPCLASS_FIREARM ],
			skills = [
			],
		},
		"fmalhaut" : { #Nathan "FOMALHAUT" Lancer's player class.
			name = "Stardiver",
			description = "A balanced attack class suited for the front line.",
			lore        = "Dedicated SWAT training polished to a fine art was the base of Fomalhaut's solid career.",
			statSpread = [ [005,004,002,004,002,004,005], [048,050,020,050,020,048,032] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 99, 01, 99, 99, 99, 01, 02, 99, 99, 03],
			weapons = [ core.WPCLASS_ARTILLERY, core.WPCLASS_FIREARM ],
			skills = [
			],
		},

	},
	"debug" : {
		"debug" : {
			name = "DEBUG",
			description = "Debug class with high stat growth.",
			statSpread = [ [004, 001, 001, 001, 001, 001, 001], [052, 032, 032, 032, 032, 032, 032] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 03, 04, 05, 03, 03, 03, 02, 03, 03, 02],
			weapons = [core.WPCLASS_HANDGUN],
			skills = [
				["debug", "debug"],
				["debug", "debugi"],
				["debug", "debugi2"],
			],
		},
		"ofight" : { #Jay Hunter's story mode base class.
			name = "Orbital Fighter",
			description = "A class specializing in fast and strong energy skills and chains.",
			statSpread = [ [005,000,000,003,002,004,001], [032,000,006,032,024,052,018] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 02, 01, 01, 02, 00, 01, 02, 01, 00, 01],
			weapons = [core.WPCLASS_ARTILLERY, core.WPCLASS_FIREARM, core.WPCLASS_SHIELD, core.WPCLASS_LONGSWORD],
			skills = [
				"story/epnfield",
				"story/jshield",
				"story/jhunter",
				"story/jrailgun",
				"story/blueshft",
				"story/brknthun",
				# Core skills #########
				"story/freerang",
				"story/jcraw",
				"story/fastcraw",
				#Filler
				"debug/gmissile",
				"debug/gatebrkr",
			],
		},
		"gdriver" : { #0a0a-DT-KSSG Jake "Magpie" Miller's story mode base class.
			name = "G-Driver",
			description = "A technical class specializing in exploiting enemy actions and status.",
			statSpread = [ [004,001,000,003,002,003,001], [032,018,006,032,024,040,018] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 01, 02, 02, 01, 02, 00, 02, 00, 00, 02],
			weapons = [ core.WPCLASS_FIREARM, core.WPCLASS_SHIELD, core.WPCLASS_POLEARM ],
			skills = [
				# Gun skills ##########
				"debug/trikshot",
				"debug/focushot",
				# Unarmed skills ######
				"debug/restshrd",
				"story/gravrefl",
				"story/gmissile",
				"story/portcutt",
				"story/gravipre",
				# Polearm skills ######
				"story/teleslsh",
				"story/spirbost",
				# Debug ###############
				"story/gdominia",
			],
		},
		"akashic" : { #Aohana Yukiko's story mode base class.
			name = "Akashic Knight",
			description = "A technical class specializing in exploiting enemy actions and status.",
			statSpread = [ [004, 000, 000, 003, 002, 003, 001], [032, 000, 006, 032, 024, 040, 018] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 00, 02, 01, 01, 02, 00, 02, 00, 00, 01],
			weapons = [core.WPCLASS_HANDGUN, core.WPCLASS_SHORTSWORD, core.WPCLASS_SHIELD],
			skills = [
				"debug/defdown",  #Defense down
				"debug/speedup",  #Speed up
				"debug/srnauror", #Serene Aurora
				"debug/elemshot", #Elemental Shot
				"story/borealsf", #Boreal Shift
				"story/dncsword", #Dancing Sword
				"story/kamaita",  #Kamaitachi
				"story/megido",   #Megido
			],
		},
		"muramasa" : { #Kurohara Shiro's story mode base class.
			name = "Muramasa",
			description = "A defensive class specializing in high defensive maneuvers, counters, and ghostly abilities",
			statSpread = [ [004, 000, 000, 003, 002, 003, 001], [032, 000, 006, 032, 024, 040, 018] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 02, 00, 02, 02, 00, 00, 02, 01, 02, 01],
			weapons = [core.WPCLASS_SHIELD, core.WPCLASS_SHORTSWORD, core.WPCLASS_LONGSWORD],
			skills = [
				#Needs huge rework. I need a Japanese dictionary pronto.
				["debug", "defdown"],
				["debug", "barricad"],
				["debug", "solidbun"],
				"story/raijin",
				"story/wanyuudo",
				"story/screams",
				["debug", "decoy"],
			],
		},
		"incinera" : { #Anna Westenra's story mode base class.
			name = "Incinerator",
			description = "Brutal fighter using the power of flames and time.",
			weapons = [core.WPCLASS_ARTILLERY, core.WPCLASS_SHORTSWORD, core.WPCLASS_POLEARM],
			statSpread = [ [004, 004, 001, 002, 001, 000, 002], [040, 048, 008, 022, 008, 008, 024] ],
			#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
			conditionDefs = [ 03, 04, 05, 03, 03, 03, 02, 03, 03, 02],
			skills = [
				#Define Anna's roles better.
				"debug/vampdran",
				"story/enrgdrve",
				"story/bloddrve",
				"story/overclck",
				"story/lunablaz",
				"story/savaripp",
				"story/timetrap",
			],
		},
		"esper" : {
			name = "ESPer",
			description = "A physically weak fighter but with powerful psychic abilities. Their physical fragility makes them better on the back row.",
			weapons = [core.WPCLASS_HANDGUN, core.WPCLASS_SHIELD, core.WPCLASS_SHORTSWORD],
			statSpread = [ [002, 000, 000, 003, 000, 002, 003], [018, 002, 002, 048, 024, 022, 028] ],
			skills = [
				["debug", "illusion"],
			],
		},
		"riot" : {
			name = "Riot",
			description = "A heavily defensive fighter with heavy armor and defenses, ideal for the front lines, but their skill with firearms makes them usable at the back, too.",
			weapons = [core.WPCLASS_FIREARM, core.WPCLASS_SHIELD, core.WPCLASS_HAMMER],
			statSpread = [ [005, 002, 005, 000, 001, 000, 002], [050, 020, 048, 000, 012, 004, 016] ],
			skills = [
				["debug", "barricad"],
				["debug", "solidbun"],
			],
		},
		"idol" : {
			name = "Idol",
			description = "Support class designed to assist the whole team. The agility required for their cheerful dances can allow them to be efficient fighters, too.",
			weapons = [core.WPCLASS_FIREARM, core.WPCLASS_SHIELD, core.WPCLASS_HAMMER],
			statSpread = [ [005, 002, 005, 000, 001, 000, 002], [050, 020, 048, 000, 012, 004, 016] ],
			skills = [
				["debug", "speedup"],
			],
		},
		"fengshui" : {
			name = "Feng-Shui",
			description = "Adept fighters that can utilize environmental energies for a variety of skills. They are usually better suited for the back row.",
			weapons = [core.WPCLASS_FIREARM, core.WPCLASS_SHIELD, core.WPCLASS_HAMMER],
			statSpread = [ [005, 002, 005, 000, 001, 000, 002], [050, 020, 048, 000, 012, 004, 016] ],
			skills = [
				["debug", "elemshot"],
			],
		},
		"rider" : {
			name = "Rider",
			description = "Adventurers that compensate their lack of combat skills with various machines to ride. While their growth is fully dependent on their ride, that makes them highly versatile.",
			weapons = [core.WPCLASS_FIREARM, core.WPCLASS_SHIELD],
			statSpread = [ [003, 000, 000, 000, 000, 000, 000], [010, 000, 000, 000, 000, 000, 008] ],
			skills = [
				"core/accel",
			],
		},
		"salarymn" : {
			name = "Salaryman",
			description = "Untrained adventurers unsatisfied with their office jobs. However, the spirit of adventure burns strong within them, and are full of potential.",
			weapons = [core.WPCLASS_FIREARM, core.WPCLASS_SHIELD, core.WPCLASS_HAMMER],
			statSpread = [ [005, 002, 005, 000, 001, 000, 002], [050, 020, 048, 000, 012, 004, 016] ],
			skills = [
			],
		},
		"medic" : {
			name = "Medic",
			description = "Specialized healers trying to keep the party alive.",
			weapons = [core.WPCLASS_HANDGUN, core.WPCLASS_SHIELD],
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
		"weapons" : { loader = LIBSTD_VARIABLEARRAY, default = [ core.WPCLASS_SHIELD ] },
		"statSpread" : { loader = LIBSTD_STATSPREAD },
		#                                                            PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
		"conditionDefs": { loader = LIBSTD_CONDITIONDEFS, default = [ 00, 00, 00, 00, 00, 00, 00, 00, 00, 00] },
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
