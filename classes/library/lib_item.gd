extends "res://classes/library/lib_base.gd"

var example = {
	"debug" : {
		"debug" : {
			name = "debug item",
			description = "It does a whole lot of nothing",
			category = 0,
		},
		"potion" : {
			name = "healing potion",
			description = "Restores %s HP",
			value = [00050, 00000, 00000, 00000, 00000,   00000, 00000, 00000, 00000, 00000],
			category = 0,
			maxLevel = 10,
			skill = [001, 000, 000, 000, 000,   000, 000, 000, 000, 000],
			skills = [
				["debug", "potion"],
			]
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
	}
}

func initTemplate():
	return {
		"name": { loader = LIBSTD_STRING },
		"description": { loader = LIBSTD_STRING },
		"value": { loader = LIBSTD_SKILL_ARRAY },
		"category": { loader = LIBSTD_INT },
		"maxLevel": { loader = LIBSTD_INT },
		"skill": { loader = LIBSTD_SKILL_ARRAY },
		"skills": { loader = LIBSTD_SKILL_LIST },
	}

func loadDebug():
	loadDict(example)
	print("Item library:")
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
