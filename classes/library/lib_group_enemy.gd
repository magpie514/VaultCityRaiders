extends "res://classes/library/lib_base.gd"

const ROW_SIZE = 5
const MAX_SIZE = ROW_SIZE * 2
const LIBEXT_FORMATION = "loaderFormation"

var example = {
	"debug" : {
		"debug" : {
			name = "Debugger",
			formation = [
				null, null, {tid = ["debug", "debug"], level = 1, flags = null}, null, null,
				null, null, null, null,	null
			],
		},
		"debug0" : {
			name = "Debug Bots",
			formation = [
				{tid = ["debug", "debug4"], level = 5, flags = null}, null, {tid = ["debug", "debug1"], level = 5, flags = null}, null, {tid = ["debug", "debug"], level = 5, flags = null},
				null, null, null, null,	null
			],
			summons = [
				{tid = ["debug", "compiler"], level = 1, flags = null},
			]
		},
		"debug1" : {
			name = "Debug Bots",
			formation = [
				{tid = ["debug", "debug3"], level = 5, flags = null}, null, {tid = ["debug", "debug1"], level = 5, flags = null}, null, {tid = ["debug", "debug2"], level = 5, flags = null},
				null, {tid = ["debug", "debug"], level = 5, flags = null}, null, {tid = ["debug", "debug"], level = 5, flags = null},	null
			]
		},
		"debug2" : {
			name = "Debug Bots",
			formation = [
				{tid = ["debug", "debug"], level = 5, flags = null}, null, {tid = ["debug", "debug3"], level = 5, flags = null}, null, {tid = ["debug", "debug"], level = 5, flags = null},
				{tid = ["debug", "compiler"], level = 5, flags = null}, {tid = ["debug", "compiler"], level = 5, flags = null}, {tid = ["debug", "compiler"], level = 5, flags = null}, {tid = ["debug", "compiler"], level = 5, flags = null},	{tid = ["debug", "compiler"], level = 5, flags = null}
			]
		}
	}
}


func initTemplate():
	return {
	"name" : { loader = LIBSTD_STRING },
	"formation" : { loader = LIBEXT_FORMATION },
	"summons" : { loader = LIBSTD_SUMMONS },
	}

func name(id):
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"

func loadDebug():
	loadDict(example)
	print("Formation library:")
	printData()

func loaderFormation(val):
	if val == null:
		var result = core.newArray(MAX_SIZE)
		for i in range(MAX_SIZE):
			result[i] = {
				tid = core.tid.fromArray(["debug", "debug"]),
				level = int(5),
			}
		return result
	else:
		var result = core.newArray(MAX_SIZE)
		for i in range(MAX_SIZE):
			if val[i] != null:
				result[i] = {
					tid = core.tid.fromArray(val[i].tid),
					level = int(val[i].level),
				}
		return result
		
