extends "res://classes/library/lib_base.gd"

enum {
	COUNTER_NONE =          0x0000, #No counter.
	COUNTER_BUFF =          0x0001, #Counter a buff.
	COUNTER_DEBUFF =        0x0002, #Counter a debuff.
	COUNTER_CRITICAL =      0x0004, #Counter a critical hit.

	COUNTER_DMG_CUT =       0x0008, #Counter a cut/wind hit.
	COUNTER_DMG_PIERCE =    0x0010, #Counter a pierce/earth hit.
	COUNTER_DMG_BLUNT =     0x0020, #Counter a blunt/water hit.
	COUNTER_DMG_FIRE =      0x0040, #Counter a fire hit.
	COUNTER_DMG_COLD =      0x0080, #Counter a cold hit.
	COUNTER_DMG_ELEC =      0x0100, #Counter an electric hit.
	COUNTER_DMG_UNKNOWN =   0x0200, #Counter a time/light/spirit hit.
	COUNTER_DMG_ULTIMATE =  0x0400, #Counter a gravity/dark/ultimate hit.

	COUNTER_DISABLE =       0x0800, #Counter a disable arm/leg/head effect.

	COUNTER_STATUS_PARA =   0x1000, #Counter paralysis effect.
	COUNTER_STATUS_STUN =   0x2000, #Counter stun effect.
	COUNTER_STATUS_DEFEAT = 0x4000, #Counter defeat effect.

}

var ELEMENT_CONV = {
	core.stats.ELEMENTS.DMG_CUT :      COUNTER_DMG_CUT,
	core.stats.ELEMENTS.DMG_PIERCE :   COUNTER_DMG_PIERCE,
	core.stats.ELEMENTS.DMG_BLUNT :    COUNTER_DMG_BLUNT,

	core.stats.ELEMENTS.DMG_FIRE :     COUNTER_DMG_FIRE,
	core.stats.ELEMENTS.DMG_ICE :      COUNTER_DMG_COLD,
	core.stats.ELEMENTS.DMG_ELEC :     COUNTER_DMG_ELEC,

	8 :                          COUNTER_DMG_UNKNOWN, #Placeholder for what will become element 7.
	core.stats.ELEMENTS.DMG_ULTIMATE : COUNTER_DMG_ULTIMATE,
}

var STATUS_CONV = { #TODO: Very much to do.
	1: COUNTER_STATUS_PARA,
}



var example = {
	"debug" : {
		"debug" : {
			name = "debug item",
			description = "It does a whole lot of nothing",
			category = 0,
		},
		"grenade" : {
			name = "Grenade",
			description = "Goes boom on stuff",
			value = [00150,00300,00600,01200,02400, 04800,09600,19200,38400,76800],
			category = 0,
			maxLevel = 10,
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [
				["debug", "firebrst"],
			]
		}
	},
	"core": {
		"nostrum" : {
			name = "Nostrum",
			description = "Over the counter medicine for adventurers. Works in a pinch, but it's barely effective on machines.",
			value = [00150,00300,00600,01200,02400, 04800,09600,19200,38400,76800],
			category = 0,
			maxLevel = 10,
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [
				["debug", "healbio"],
			]
		},
		"repair1" : {
			name = "Frame Repair Kit",
			description = "Basic nanorepair kit for machines.",
			value = [00150,00300,00600,01200,02400, 04800,09600,19200,38400,76800],
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = [020,025,025,025,025, 025,025,025,025,025],
			chargeUse =  [025,025,025,025,025, 025,025,025,025,025],
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [
				["debug", "healmec"],
			]
		},
		"repair2" : {
			name = "Frame Repair Kit test",
			description = "Basic nanorepair kit for machines.",
			value = [00150,00300,00600,01200,02400, 04800,09600,19200,38400,76800],
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = [010,025,025,025,025, 025,025,025,025,025],
			chargeUse =  [020,025,025,025,025, 025,025,025,025,025],
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [ ["debug", "healmec"]	],
		},
		"lifeshrd" : {
			name = "Life Shard",
			description = "Can bring even machines and spirits from the brink of death.",
			value = [00150,00300,00600,01200,02400, 04800,09600,19200,38400,76800],
			category = 0,
			maxLevel = 10,
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [ ["debug", "revive"] ],
		},
		"defshrd": {
			name = "Defense Shard",
			description = "Increases DEF for one ally.",
			value = [00150,00300,00600,01200,02400, 04800,09600,19200,38400,76800],
			category = 0,
			maxLevel = 10,
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [ ["core", "defup"] ],
		},
		"erthward": {
			name = "Earth Ward",
			description = "Fully protects a party member from one Pierce attack.",
			value = [00150,00300,00600,01200,02400, 04800,09600,19200,38400,76800],
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = [025,025,025,025,025, 025,025,025,025,025],
			chargeUse =  [100,100,100,100,100, 100,100,100,100,100],
			counter = true,
			counters = COUNTER_DMG_PIERCE,
		},
		"fireward": {
			name = "Fire Ward",
			description = "Fully protects a party member from one Fire attack.",
			value = [00150,00300,00600,01200,02400, 04800,09600,19200,38400,76800],
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = [025,025,025,025,025, 025,025,025,025,025],
			chargeUse =  [100,100,100,100,100, 100,100,100,100,100],
			counter = true,
			counters = COUNTER_DMG_FIRE,
		},
		"fortcoin": {
			name = "Fortune Coin",
			description = "A lucky charm from a legendary gambler. Completely negates a critical hit.",
			value = [00150,00300,00600,01200,02400, 04800,09600,19200,38400,76800],
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = [020,020,025,025,025, 025,025,025,025,025],
			chargeUse =  [100,100,100,100,100, 100,100,100,100,100],
			counter = true,
			counters = COUNTER_CRITICAL,
		}
	}
}

func initTemplate():
	return {
		"name": { loader = LIBSTD_STRING },
		"description": { loader = LIBSTD_STRING },
		"value": { loader = LIBSTD_SKILL_ARRAY },
		"category": { loader = LIBSTD_INT }, #TODO: Find out what this meant. Keep it for now, might be reusable for field/battle stuff?
		"maxLevel": { loader = LIBSTD_INT },
		"charge": { loader = LIBSTD_BOOL, default = false },
		"chargeRate" : { loader = LIBSTD_SKILL_ARRAY },
		"chargeUse"  : { loader = LIBSTD_SKILL_ARRAY },
		"counter": { loader = LIBSTD_BOOL, default = false },
		"counters": { loader = LIBSTD_SKILL_ARRAY, default = [0,0,0,0,0, 0,0,0,0,0]},
		"skill": { loader = LIBSTD_SKILL_ARRAY },
		"skills": { loader = LIBSTD_SKILL_LIST },
	}

func loadDebug():
	loadDict(example)
	print("[LIB][ITEM] Loaded data:")
	printData()

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
			print(key2)
