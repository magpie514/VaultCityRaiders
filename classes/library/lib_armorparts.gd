extends "res://classes/library/lib_base.gd"
var skill = core.skill

#TODO: How it should work.
# Parts should have a -5===0===5 slider. You can upgrade the part up to +5 to allow moving the slider up to -X===+X.
# 0 is a balanced state.

enum { #Vehicle parts. (Frames need no check, they use all)
	#TODO: This should be in some common area to avoid desync as changes happen. Where, though?
	PARTS_ENGINE = 1,
	PARTS_SENSORS,
	PARTS_FCS,
	PARTS_MOBILITY,
	PARTS_COOLING,
	# Frame only
	PARTS_ARMS,
	PARTS_BOOSTER,
	# Goes in extra slot
	PARTS_EXTRA,
}

const LOAD_TRANSLATE = {
	"ENGINE":   PARTS_ENGINE,
	"SENSOR":   PARTS_SENSORS,
	"FCS":      PARTS_FCS,
	"MOBILITY": PARTS_MOBILITY,
	"COOLING":  PARTS_COOLING,
	"ARMS":     PARTS_ARMS,
	"BOOSTER":  PARTS_BOOSTER,
	"EXTRA":    PARTS_EXTRA,
}

const PARTS = {
	PARTS_ENGINE:   { name = "Engine" },
	PARTS_SENSORS:  { name = "Sensors" },
	PARTS_FCS:      { name = "FCS" },
	PARTS_MOBILITY: { name = "Mobility" },
	PARTS_COOLING:  { name = "Cooling" },
	PARTS_ARMS:     { name = "Arms" },
	PARTS_BOOSTER:  { name = "Booster" },
	PARTS_EXTRA:    { name = "Extra" },
}

const LIBEXT_PARTSTAT_ARRAY = "loaderPartStatArray"

var example = {
	"story" : {
		"hollow" : {
			name = "Hollow Engine",
			description = "Magpie's engine. Uses the properties of the G-Crystal to generate energy from the flow of gravitons. A safety limiter prevents Magpie from using her full power.",
			slot = PARTS_ENGINE,
			stat1 = ['RES_ULT',            000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = [["debug","codexalt"], 010,008,006,004,002, 001, 001,001,000,000,000],
		},
		"reacta" : {
			name = "G-Pulse Drive Mk.III REACTA",
			description = "Magpie's true engine. With the REACTA limiter released, it's able to harness the full power of the G-Crystal, allowing Magpie to manipulate space.",
			slot = PARTS_ENGINE,
			stat1 = ['RES_ULT',            000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = [["debug","codexalt"], 010,008,006,004,002, 001, 001,001,000,000,000], #TODO: Change to G-Dominion and assign Code「EXALT」to KSSGfrm2 instead.
		},
		"dimeye" : {
			name = "Dimension Eye",
			description = "A perfect replica of Professor Millennium's advanced dimensional sensor system. It's the only successful replica ever developed, and only Magpie can use it properly.",
			slot = PARTS_SENSORS,
			stat1 = ['OFF_ULT',            000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = [["debug","gatebrkr"], 010,008,006,004,002, 001, 001,001,000,000,000],
		},
	},
	"debug" : {
		"debug" : {
			name = "Debug Part",
			slot = PARTS_EXTRA,
			value = [0, 1, 2, 3, 4],
			stat1 = ['ATK', 012,010,009,008,007, 005, 003,002,001,000,000 ],
			stat2 = ['DEF', 000,000,001,002,003, 005, 007,008,009,010,012 ],
		},
	}
}

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING },
		"description" : { loader = LIBSTD_STRING, default = "Sponsored by Ryuutei Corporation."},
		"slot" : { loader = LIBSTD_INT },
		"value" : {loader = LIBSTD_VARIABLEARRAY, default = [1, 1, 1, 1, 1] },
		'stat1' : { loader = LIBEXT_PARTSTAT_ARRAY },
		'stat2' : { loader = LIBEXT_PARTSTAT_ARRAY },
	}

func loadDebug():
	loadDict(example)

func loaderPartStatArray(val) -> Array:
	var result = ['NONE', 0,0,0,0,0, 0, 0,0,0,0,0]
	if val == null: return result
	if typeof(val) != TYPE_ARRAY: return result
	match typeof(val[0]):
		TYPE_ARRAY:
			result[0] = core.tid.fromArray(val[0])
		TYPE_STRING:
			result[0] = str(val[0])
	for i in range(1, 12):
		result[i] = int(val[i])
	return result
