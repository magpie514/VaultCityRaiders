extends "res://classes/library/lib_base.gd"

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
			value = [00050, 00000, 00000, 00000, 00000,   00000, 00000, 00000, 00000, 00000],
			category = 0,
			maxLevel = 10,
			skill = [001, 000, 000, 000, 000,   000, 000, 000, 000, 000],
			skills = [
				["debug", "firebrst"],
			]
		}
	},
	"core": {
		"nostrum" : {
			name = "Nostrum",
			description = "Over the counter medicine for adventurers. Works in a pinch, but it's barely effective on machines.",
			value = [00050, 00000, 00000, 00000, 00000,   00000, 00000, 00000, 00000, 00000],
			category = 0,
			maxLevel = 10,
			skill = [001, 000, 000, 000, 000,   000, 000, 000, 000, 000],
			skills = [
				["debug", "potion"],
			]
		},
		"repair1" : {
			name = "Repair Kit",
			description = "Basic nanorepair kit for machines.",
			value = [00050, 00000, 00000, 00000, 00000,   00000, 00000, 00000, 00000, 00000],
			category = 0,
			maxLevel = 10,
			skill = [001, 000, 000, 000, 000,   000, 000, 000, 000, 000],
			skills = [
				["debug", "potion"],
			]
		},
		"lifeshrd" : {
			name = "Life Shard",
			description = "Can bring even machines and spirits from the brink of death.",
			value = [00050, 00000, 00000, 00000, 00000,   00000, 00000, 00000, 00000, 00000],
			category = 0,
			maxLevel = 10,
			skill = [001, 000, 000, 000, 000,   000, 000, 000, 000, 000],
			skills = [
				["debug", "revive"],
			]
		},
	}
}

func initTemplate():
	return {
		"name": { loader = LIBSTD_STRING },
		"description": { loader = LIBSTD_STRING },
		"value": { loader = LIBSTD_SKILL_ARRAY },
		"charge": { loader = LIBSTD_BOOL, default = false }, #TODO: Items that recharge with a given rate per hour (up to 100) and consume an amount of charge on use.
		"chargeRate" : { loader = LIBSTD_SKILL_ARRAY },
		"chargeUse"  : { loader = LIBSTD_SKILL_ARRAY },
		"counter": { loader = LIBSTD_BOOL, default = false }, #TODO: Implement "counter" items, allows to intercept an element or status, but consumes itself or uses charge.
		"category": { loader = LIBSTD_INT }, #TODO: Find out what this meant.
		"maxLevel": { loader = LIBSTD_INT },
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
