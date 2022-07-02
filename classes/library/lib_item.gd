extends "res://classes/library/lib_base.gd"

enum {
	COUNTER_NONE         = 0b000000000000000000000000000, #No counter.
	COUNTER_BUFF         = 0b000000000000000000000000001, #Counter a buff.
	COUNTER_DEBUFF       = 0b000000000000000000000000010, #Counter a debuff.
	COUNTER_CRITICAL     = 0b000000000000000000000000100, #Counter a critical hit.
	COUNTER_DEFEAT       = 0b000000000000000000000001000, #Counter a defeat with 1%Vital.
	COUNTER_DMG_CUT      = 0b000000000000000000000010000, #Counter a cut/wind hit.
	COUNTER_DMG_PIERCE   = 0b000000000000000000000100000, #Counter a pierce/earth hit.
	COUNTER_DMG_STRIKE   = 0b000000000000000000001000000, #Counter a blunt/water hit.
	COUNTER_DMG_FIRE     = 0b000000000000000000010000000, #Counter a fire hit.
	COUNTER_DMG_COLD     = 0b000000000000000000100000000, #Counter a cold hit.
	COUNTER_DMG_ELEC     = 0b000000000000000001000000000, #Counter an electric hit.
	COUNTER_DMG_UNKNOWN  = 0b000000000000000010000000000, #Counter a time/light/spirit hit.
	COUNTER_DMG_ULTIMATE = 0b000000000000000100000000000, #Counter a gravity/dark/ultimate hit.
	COUNTER_COND_PARA    = 0b000000000000001000000000000, #Counter paralysis effect.
	COUNTER_COND_STUN    = 0b000000000000010000000000000, #Counter stun effect.
	COUNTER_COND_DOWN    = 0b000000000000100000000000000, #Counter defeat effect.
	COUNTER_COND_CRYO    = 0b000000000001000000000000000, #Counter cryostasis effect.
	COUNTER_COND_PANIC   = 0b000000000010000000000000000, #Counter panic effect.
	COUNTER_COND_ARMS    = 0b000000010000000000000000000, #Counter disable arms effect.

}

var COND_COUNTER_CONV = {
	core.stats.COND_PARALYSIS    : COUNTER_COND_PARA,
	core.stats.COND_STUN         : COUNTER_COND_STUN,
	core.stats.COND_DEFEAT       : COUNTER_COND_DOWN,
	core.stats.COND_CRYO         : COUNTER_COND_CRYO,
	core.stats.COND_DISABLE_ARMS : COUNTER_COND_ARMS,
	core.stats.COND_PANIC        : COUNTER_COND_PANIC,
}

var ELEMENT_CONV = {
	core.stats.ELEMENTS.DMG_CUT      : COUNTER_DMG_CUT,
	core.stats.ELEMENTS.DMG_PIERCE   : COUNTER_DMG_PIERCE,
	core.stats.ELEMENTS.DMG_STRIKE   : COUNTER_DMG_STRIKE,

	core.stats.ELEMENTS.DMG_FIRE     : COUNTER_DMG_FIRE,
	core.stats.ELEMENTS.DMG_ICE      : COUNTER_DMG_COLD,
	core.stats.ELEMENTS.DMG_ELEC     : COUNTER_DMG_ELEC,

	core.stats.ELEMENTS.DMG_UNKNOWN  : COUNTER_DMG_UNKNOWN,
	core.stats.ELEMENTS.DMG_ULTIMATE : COUNTER_DMG_ULTIMATE,
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
			description = "Over the counter medicine for adventurers. Works in a pinch, but it's not effective on machines.",
			category = 0,
			maxLevel = 10,
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [
				["debug", "healbio"],
			]
		},
		"panacea" : {
			name = "Panacea",
			description = "A medicine capable of restoring any ailments.",
			category = 0,
			maxLevel = 10,
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [
				["debug", "healbio"],
			]
		},
		"luopan" : {
			name = "Luopan",
			description = "An enchanted luopan, a feng shui compass. Use it to shift the elements in the field: Cut to Fire, Pierce to Elec and Strike to Cold.",
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = 020,
			chargeUse =  020,
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [
				"core/elemshft",
			]
		},
		"repair1" : {
			name = "Frame Repair Kit",
			description = "Basic nanorepair kit for machines.",
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
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = [010,025,025,025,025, 025,025,025,025,025],
			chargeUse =  [020,025,025,025,025, 025,025,025,025,025],
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [ ["debug", "healmec"]	],
		},
		"scfcshrd" : {
			name = "Shard of Sacrifice",
			description = "The user's Vital is reduced to 1. Target is healed for user's max Vital.",
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = [025,025,025,025,025, 025,025,025,025,025],
			chargeUse =  [025,025,025,025,025, 025,025,025,025,025],
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [
				"debug/sacrific",
			]
		},
		"lifeshrd" : {
			name = "Time Shard",
			description = "Revive any fallen party member.",
			category = 0,
			maxLevel = 10,
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [ ["debug", "revive"] ],
		},
		"defshrd": {
			name = "Defense Shard",
			description = "Increases DEF for one ally.",
			category = 0,
			maxLevel = 10,
			skill = [001,001,001,001,001, 001,001,001,001,001],
			skills = [ ["core", "defup"] ],
		},
		"erthward": {
			name = "Earth Ward",
			description = "Fully protects a party member from one Pierce attack.",
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
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = [025,025,025,025,025, 025,025,025,025,025],
			chargeUse =  [100,100,100,100,100, 100,100,100,100,100],
			counter = true,
			counters = COUNTER_DMG_FIRE,
		},
		"everflam": {
			name = "Everlasting Flame",
			description = "Crystal with a small, warm flame. Protects a party member from Cryostasis condition.",
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = [025,025,025,025,025, 025,025,025,025,025],
			chargeUse =  [100,100,100,100,100, 100,100,100,100,100],
			counter = true,
			counters = COUNTER_COND_CRYO,
		},
		"flamshrd": {
			name = "Shard of Flame",
			description = "Small shard with a small, warm flame. Protects a party member from Cryostasis condition.",
			category = 0,
			maxLevel = 10,
			counter = true,
			counters = COUNTER_COND_CRYO,
		},
		"fortcoin": {
			name = "Fortune Coin",
			description = "A lucky charm from a legendary gambler. Completely negates a critical hit.",
			category = 0,
			maxLevel = 10,
			charge = true,
			chargeRate = [020,020,025,025,025, 025,025,025,025,025],
			chargeUse =  [100,100,100,100,100, 100,100,100,100,100],
			counter = true,
			counters = COUNTER_CRITICAL,
		},
		"blaklotu": {
			name = "Black Lotus",
			description = "A very valuable flower, ripe with energy. It can prevent a party member from passing out at zero health.",
			category = 0,
			maxLevel = 10,
			counter = true,
			counters = COUNTER_COND_DOWN,
		}
	}
}

func initTemplate():
	return {
		"name": { loader = LIBSTD_STRING },
		"description": { loader = LIBSTD_STRING },
		"value": { loader = LIBSTD_SKILL_ARRAY, default = [00150,00300,00600,01200,02400, 04800,09600,19200,38400,76800] },
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
