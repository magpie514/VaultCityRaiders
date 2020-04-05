extends "res://classes/library/lib_base.gd"
var skill = core.skill

# Parts should have a -5===0===5 slider (which translates to 1==6==11 internally).
# You can upgrade the part up to +5 to allow moving the slider up to -X===+X.
# 0(6) is a balanced state and default.

const LIBEXT_PARTSTAT_ARRAY = "loaderPartStatArray"

var example = {
	"core" : {
		"stplate" : {
			name = "Steel Plating", slot = "ARMOR",
			description = "Heavy steel plating.",
			stat1 = ['AGI',                -02,-03,-04,-05,-06, -07, -08,-09,-10,-11,-12],
			stat2 = ['DEF',                002,003,004,005,006, 007, 008,009,010,011,012],
		}
	},
	"story" : {
		"plasdr" : {
			name = "Plasma Driver", slot = "ENGINE",
			description = "Jay's generator. A powerful generator capable of converting Jay's Over into an EPN field that can directly negate conventional physics for a limited time.",
			stat1 = ['OFF_ELE',            000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = ['AGI',                012,008,006,004,002, 001, 001,001,000,000,000],
		},
		"hollow" : {
			name = "Hollow Engine", slot = "ENGINE",
			description = "Magpie's engine. Uses the properties of the G-Crystal to generate energy from the flow of gravitons. A safety limiter prevents Magpie from using her full power, as the engine could be rendered unstable and destroy the fabric of reality.",
			stat1 = ['RES_ULT',            000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = [["story","codexalt"], 010,008,006,004,002, 001, 001,001,001,001,001],
		},
		"reacta" : {
			name = "G-Pulse Drive Mk.III REACTA", slot = "ENGINE",
			description = "Magpie's true engine. With the REACTA limiter released, it's able to harness the full power of the G-Crystal, allowing Magpie to create and manipulate full dimensions through G-Dominion. Its efficiency peaks near the presence of Over.",
			stat1 = ['ALL_ULT',            000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = [["story","codexalt"], 010,008,006,004,002, 001, 001,001,001,001,001], #TODO: Change to G-Dominion and assign Code「EXALT」to KSSGfrm2 instead.
		},
		"dimeye" : {
			name = "Dimension Eye", slot = "FCS",
			description = "A perfect replica of Professor Millennium's advanced dimensional sensor system. It's the only successful replica ever developed, and only Magpie can use it properly. Someone not attuned to dimensional scouting will be instantly driven mad by the sights beyond space.",
			stat1 = ['OFF_ULT',            000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = [["story","gatebrkr"], 010,008,006,004,002, 001, 001,001,001,001,001],
		},
		"kokurei" : {
			name = "Kokureiro", slot = "ENGINE",
			description = "Shiro's engine, 酷霊炉, the \"Cruel Spirit Furnace\". It feeds on the negative energies of those cut by the Ganreitou. The process is said to be like witnessing a legion of hungry spirits, drawing closer and closer every cut.",
			stat1 = ['RES_KIN',            000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = ['RES_ENE',            020,012,009,007,005, 005, 005,004,002,001,000],
		},
		"tindal" : {
			name = "Tindalos Furnace", slot = "ENGINE",
			description = "Anna's engine, powered by the temporal anomalies accumulated by Mister Raven's constant time travel. Receives energy from all points in time simultaneously, and will keep running after time has ended.",
			stat1 = ['AGI',            000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = ['STR',            020,012,009,007,005, 005, 005,004,002,001,000],
		},
		"shira" : {
			name = "Shirayuki", slot = "ENGINE",
			description = "Yukiko's reactor, crafted from a modified G-Crystal. It's unable to generate more energy than she normally would, but it can store excess energy, allowing for higher stamina and power in bursts. Losing synchronization with her body can temporarily halt energy production.",
			stat1 = ['RES_ENE',        000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = ['WIS',            020,012,009,007,005, 005, 005,004,002,001,000],
		},
		"shira2" : {
			name = "Shirayuki PERFECT BLUE", slot = "ENGINE",
			description = "Yukiko's modified reactor. Linked with the Prime Blue, it produces a staggering amount of energy by gathering Over, specially that born from feelings of hope. It won't desynch anymore as long as Yukiko keeps altering the Akashic Records to adapt to potential damage.",
			stat1 = ['OFF_ENE',        000,001,002,004,005, 005, 005,007,009,012,020],
			stat2 = ['MEP',            020,012,009,007,005, 005, 005,004,002,001,000],
		},
	},
	"debug" : {
		"debug" : {
			name = "Debug Part",
			description = "You should not be seeing this part normally, this means something went wrong.",
			slot = "EXTRA",
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
		"value" : {loader = LIBSTD_INT, default = 1000 },
		'stat1' : { loader = LIBEXT_PARTSTAT_ARRAY },
		'stat2' : { loader = LIBEXT_PARTSTAT_ARRAY },
	}

func loadDebug():
	loadDict(example)
	printData()

func loaderPartStatArray(val) -> Array:
	var result = ['NONE', 0,0,0,0,0, 0, 0,0,0,0,0]
	if val == null: return result
	if typeof(val) != TYPE_ARRAY: return result
	match typeof(val[0]):
		TYPE_ARRAY:
			result[0] = core.tid.fromArray(val[0])
		TYPE_STRING:
			result[0] = str(val[0]).to_upper() #We want this to be LOUD for Stats.elementalModStringConvert
	for i in range(1, 12):
		result[i] = int(val[i])
	return result
