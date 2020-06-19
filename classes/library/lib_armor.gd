extends "res://classes/library/lib_base.gd"
var skill = core.skill

const LIBEXT_ARMOR_STATS = "loaderArmorStats"
const LIBEXT_PARTS = "loaderParts"
const LIBEXT_DEFAULT_PARTS = "loaderDefaultParts"
const LIBEXT_ARCLASS = "loaderArClass"
const LIBEXT_BONUS_STATS = "loaderBonusStats"

var example = {
	"core" : {
		"perbar" : {
			name = "Personal Barrier", arclass = 'BARRIER',
			description = "Basic personal energy barrier.",
			DEF = [002, 004], EDF = [003, 005],
			weight = [001, 001],
		}
	},
	"story" : {
		"orbitfrm" : {
			name = "ORBITAL Frame", arclass = 'FRAME',
			description = "Jay's choujin frame. Oriented to aerial combat both inside and outside an atmosphere. Can handle tremendous amounts of energy, either from enemy attacks or the full output of the Plasma Drive.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			parts = {
				onboard = 1,
				statSpread = [ [052,009,012,015,012,015,006], [520,100,125,150,165,160,095] ],
			}
		},
		"kssgfrm1" : {
			name = "KSSG Frame", arclass = 'FRAME',
			description = "Magpie's choujin frame. Incomplete, she is unable to access her true form because of power limiters put in place by professor Millennium. It's shielded against dimensional distortions.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			parts = {
				onboard = 1,
				statSpread = [ [042,013,010,014,011,010,010], [460,130,125,140,155,125,135] ],
				default = {
					'ENGINE' : ["story/hollow", 5, 5],
					'FCS'    : ["story/dimeye", 5, 5],
				}
			}
		},
		"KSSGfrm2" : {
			name = "KSSG Frame", arclass = 'FRAME',
			description = "Magpie's choujin frame. Having removed the REACTA limiter on the Hollow Engine gives her full access to her full capabilities. It's shielded against powerful dimensional distortions.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			over = "story/codexalt",
			parts = {
				onboard = 1,
				statSpread = [ [050, 012, 012, 015, 015, 010, 012], [500, 110, 125, 150, 155, 130, 145] ],
			}
		},
		"murafrm" : {
			name = "MURAMASA Frame", arclass = 'FRAME',
			description = "Shiro's choujin frame. The result of transforming using Orihalcon soaked in the blood of multiple victims as the Ganreitou. This sturdy frame is in perfect tune with the Spirit Realm.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			parts = {
				onboard = 0,
				statSpread = [ [065, 013, 015, 010, 013, 008, 008], [700, 140, 165, 100, 150, 090, 115] ],
			}
		},
		"redbrig" : {
			name = "Crimson Brigandine", arclass = 'LIGHT',
			description = "Anna's custom armor. A full-body suit reinforced with lightweight carbon plates, topped off with a heavy blood-red coat made of elastic energy-resistant materials and a personal field generator.",
			DEF =    [005, 020], EDF = [015, 032],
			weight = [002, 000],
			bonus = [ ['RES_FIR', 012, 015] ],
		},
		"ravefrm" : {
			name = "SOLRAVEN Frame", arclass = 'FRAME',
			description = "Anna's choujin frame. Can resist outstanding heat. Transforming as a vampire gave the frame energy-draining abilities and magnified her power even further. The bond with Mr. Raven gives it shielding against temporal anomalies, and a birdlike appearance.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			parts = {
				onboard = 1,
				statSpread = [ [055, 016, 012, 008, 010, 010, 005], [580, 155, 125, 100, 120, 120, 075] ],
			}
		},
		"soulfrm" : {
			name = "MT-SOULINK-2 Frame SHIRAYUKI", arclass = 'FRAME',
			description = "Yukiko's choujin frame. Professor Millennium's artificial choujin frame, designed to take a spirit host. However, as a dead spirit has a weaker synchonization rate with the material world, the frame needs to resemble Yukiko's original form closely, making it fragile, as damage can sever the synchronization.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			parts = {
				onboard = 0,
				statSpread = [ [045, 010, 008, 013, 012, 012, 010], [430, 130, 090, 150, 125, 140, 125] ],
			}
		},
		"soleil" : {
			name = "DND-SOLEIL Custom", arclass = 'VEHICLE',
			description = "Elodie's custom VANGUARD suit. Given to her by Renèe, captain of the Durandal, as a gift for succeeding at her assignment as pilot of the Balmung. She has customized it meticulously for optimal performance.",
			DEF =    [125, 180], EDF = [80, 120],
			weight = [008, 005],
			parts = {
				onboard = 3,
				veclass = core.Inventory.VECLASS_VANGUARD,
				statSpread = [ [015, 002, 005, 000, 001, 000, 002], [070, 020, 048, 000, 012, 004, 016] ],
			}
		}
	},
	"debug" : {
		"debug" : {
			name = "Debug Armor", arclass = 'BARRIER',
			DEF =    [100, 120], EDF = [100, 120],
			weight = [010, 000],
		},
		"vehicle" : {
			name = "Debug Tank", arclass = 'VEHICLE',
			DEF =    [100, 120], EDF = [100, 120],
			parts = {
				onboard = 3,
				veclass = core.Inventory.VECLASS_HEAVY,
				statSpread = [ [005, 002, 005, 000, 001, 000, 002], [050, 020, 048, 000, 012, 004, 016] ],
			}
		},
		"frame" : {
			name = "Debug Frame", arclass = 'FRAME',
			DEF =    [100, 120], EDF = [100, 120],
			frame = {
				onboard = 1,
				statSpread = [ [060, 015, 015, 015, 010, 010, 005], [520, 150, 165, 120, 090, 110, 085] ],
			}
		}
	}
}

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING },
		"arclass": { loader = LIBEXT_ARCLASS, default = core.Inventory.ARCLASS_NONE },
		"description" : { loader = LIBSTD_STRING, default = "???" },
		"DEF" : { loader = LIBEXT_ARMOR_STATS, default = [0, 1] },
		"EDF" : { loader = LIBEXT_ARMOR_STATS, default = [0, 1] },
		"MHP" : { loader = LIBEXT_ARMOR_STATS, default = [0, 0] },
		"bonus" : { loader = LIBEXT_BONUS_STATS, default = null },
		"parts" : { loader = LIBEXT_PARTS, default = null },
		"over" : { loader = LIBSTD_TID_OR_NULL, default = null }
	}

func partsTemplate():
	return {
		"onboard" : { loader = LIBSTD_INT },
		"veclass" : { loader = LIBSTD_INT },
		"statSpread" : { loader = LIBSTD_STATSPREAD },
		"default" : { loader = LIBEXT_DEFAULT_PARTS },
	}

func loadDebug():
	print("[ARMOR][loadDebug] Loading armor lib.")
	loadDict(example)
	print("[ARMOR][loadDebug] Armor loaded.")
	printData()

func loaderArmorStats(val) -> Array:
	if val == null:
		return [0, 1]
	if typeof(val) == TYPE_ARRAY and val.size() == 2:
		return [int(val[0]), int(val[1])]
	else:
		return [0, 1]

func loaderParts(val):
	if val == null: return null
	return parseSubTemplate(partsTemplate(), val)

func loaderArClass(val):
	if val == null: return core.Inventory.ARCLASS_NONE
	if val.to_upper() in core.Inventory.ARCLASS_TRANSLATE:
		return val.to_upper()
	return core.Inventory.ARCLASS_NONE

func loaderBonusStats(val):
	if val == null: return null
	if typeof(val) != TYPE_ARRAY: return null
	if val.empty(): return null
	var result:Array = []
	var valsize = 3 if val.size() > 3 else val.size()
	for i in range(valsize):
		var current = val[i]
		if typeof(current) == TYPE_ARRAY:
			result.push_back([str(current[0]).to_upper(), int(current[1]), int(current[2])])
	if result.size() > 0:
		return result
	else:
		return null



func loaderDefaultParts(val):
	if val == null: return null
	var result:Dictionary = {}
	for i in val:
		var current = val[i]
		var I = i.to_upper()
		if I in core.Inventory.ARMORPARTS_TRANSLATE:
			result[I] = [core.tid.from(current[0]), int(current[1]), int(current[2])]
			print("[LIBARMORPARTS] %s (%s): %s" % [ I, i, result[I] ])
	return result
