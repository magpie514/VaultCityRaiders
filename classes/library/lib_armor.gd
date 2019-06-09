extends "res://classes/library/lib_base.gd"
var skill = core.skill

const LIBEXT_ARMOR_STATS = "loaderArmorStats"
const LIBEXT_VEHICLE = "loaderVehicle"
const LIBEXT_FRAME = "loaderFrame"

enum { #Armor classes
	ARCLASS_NONE = 0,
	ARCLASS_LIGHT,
	ARCLASS_HEAVY,
	ARCLASS_BARRIER,
	ARCLASS_VEHICLE,
	ARCLASS_FRAME,
}

enum { #Vehicle classes
	VECLASS_NONE = 0,
	VECLASS_SMALL,
	VECLASS_LARGE,
	VECLASS_HEAVY,
	VECLASS_AERIAL,
	VECLASS_VANGUARD,
}

enum { #Vehicle parts. (Frames need no check, they use all)
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

const VEPARTS = {
	VECLASS_SMALL:    [ PARTS_ENGINE,PARTS_FCS,PARTS_MOBILITY,PARTS_COOLING ],
	VECLASS_LARGE:    [ PARTS_ENGINE,PARTS_SENSORS,PARTS_FCS,PARTS_MOBILITY,PARTS_COOLING ],
	VECLASS_HEAVY:    [ PARTS_ENGINE,PARTS_SENSORS,PARTS_FCS,PARTS_MOBILITY,PARTS_COOLING ],
	VECLASS_AERIAL:   [ PARTS_ENGINE,PARTS_SENSORS,PARTS_FCS,PARTS_COOLING,PARTS_BOOSTER ],
	VECLASS_VANGUARD: [ PARTS_ENGINE,PARTS_SENSORS,PARTS_FCS,PARTS_MOBILITY,PARTS_COOLING,PARTS_ARMS,PARTS_BOOSTER ],
}

const armortypes = {
	ARCLASS_NONE :    { name = "???",     icon = "" },
	ARCLASS_LIGHT :   { name = "Light",   icon = "" },
	ARCLASS_HEAVY :   { name = "Heavy",   icon = "" },
	ARCLASS_BARRIER : { name = "Barrier", icon = "" },
	ARCLASS_VEHICLE : { name = "Vehicle", icon = "" },
	ARCLASS_FRAME :   { name = "Frame",   icon = "" },
}

var example = {
	"story" : {
		"orbitfrm" : {
			name = "ORBITAL Frame", arclass = ARCLASS_FRAME,
			description = "Jay's choujin frame. Oriented to aerial combat both inside and outside an atmosphere. Can handle tremendous amounts of energy, either from enemy attacks or the full output of the Plasma Drive.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			frame = {
				onboard = 1,
				statSpread = [ [052, 009, 012, 015, 012, 015, 006], [520, 100, 125, 150, 165, 160, 095] ],
			}
		},
		"KSSGfrm1" : {
			name = "KSSG Frame", arclass = ARCLASS_FRAME,
			description = "Magpie's choujin frame. Incomplete, she is unable to access her true form because of power limiters put in place by professor Millennium. It's shielded against dimensional distortions.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			frame = {
				onboard = 1,
				statSpread = [ [042, 010, 010, 014, 011, 010, 010], [460, 090, 125, 140, 155, 125, 135] ],
				defaultParts = {
					"engine" : { tid = ["story", "hollow"], level = 1 },
					"sensor" : { tid = ["story", "dimeye"], level = 1 }
				}
			}
		},
		"KSSGfrm2" : {
			name = "KSSG Frame", arclass = ARCLASS_FRAME,
			description = "Magpie's choujin frame. Having removed the REACTA limiter on the Hollow Engine gives her full access to her full capabilities. It's shielded against powerful dimensional distortions.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			frame = {
				onboard = 1,
				statSpread = [ [050, 012, 012, 015, 015, 010, 012], [500, 110, 125, 150, 155, 130, 145] ],
			}
		},
		"murafrm" : {
			name = "MURAMASA Frame", arclass = ARCLASS_FRAME,
			description = "Shiro's choujin frame. The result of transforming using Orihalcon soaked in the blood of multiple victims as the Ganreitou. This sturdy frame is in perfect tune with the Spirit Realm.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			frame = {
				onboard = 0,
				statSpread = [ [065, 013, 015, 010, 013, 008, 008], [700, 140, 165, 100, 150, 090, 115] ],
			}
		},
		"redbrig" : {
			name = "Crimson Brigandine", arclass = ARCLASS_LIGHT,
			description = "Anna's custom armor. A full-body suit reinforced with lightweight carbon plates, topped off with a heavy blood-red coat made of elastic energy-resistant materials and a personal field generator.",
			DEF =    [005, 020], EDF = [015, 032],
			weight = [002, 000],
		},
		"ravefrm" : {
			name = "SOLRAVEN Frame", arclass = ARCLASS_FRAME,
			description = "Anna's choujin frame. Can resist outstanding heat. Transforming as a vampire gave the frame energy-draining abilities and magnified her power even further. The bond with Mister Raven gives it shielding against temporal anomalies, and a birdlike appearance.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			frame = {
				onboard = 1,
				statSpread = [ [055, 016, 012, 008, 010, 010, 005], [580, 155, 125, 100, 120, 120, 075] ],
			}
		},
		"soulfrm" : {
			name = "MT-SOULINK-2 Frame Custom", arclass = ARCLASS_FRAME,
			description = "Yukiko's choujin frame. Professor Millennium's artificial choujin frame, designed to take a spirit host. However, as a dead spirit has a weaker synchonization rate with the material world, the frame needs to resemble Yukiko's original form closely, making it fragile, as damage can sever the synchronization.",
			DEF =    [004, 020], EDF = [012, 032],
			weight = [003, 001],
			frame = {
				onboard = 0,
				statSpread = [ [045, 010, 008, 013, 012, 012, 010], [430, 130, 090, 150, 125, 140, 125] ],
			}
		},
	},
	"debug" : {
		"debug" : {
			name = "Debug Armor", arclass = ARCLASS_BARRIER,
			DEF =    [100, 120], EDF = [100, 120],
			weight = [010, 000],
		},
		"vehicle" : {
			name = "Debug Tank", arclass = ARCLASS_VEHICLE,
			DEF =    [100, 120], EDF = [100, 120],
			vehicle = {
				onboard = 3,
				veclass = VECLASS_HEAVY,
			}
		},
		"frame" : {
			name = "Debug Frame", arclass = ARCLASS_FRAME,
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
		"description" : { loader = LIBSTD_STRING, default = "???" },
		"DEF" : { loader = LIBEXT_ARMOR_STATS, default = [0, 1] },
		"EDF" : { loader = LIBEXT_ARMOR_STATS, default = [0, 1] },
		"vehicle" : { loader = LIBEXT_VEHICLE, default = null },
		"frame" : { loader = LIBEXT_FRAME, default = null },
		"over" : { loader = LIBSTD_TID_OR_NULL, default = null }
	}

func vehicleTemplate():
	return {
		"onboard" : { loader = LIBSTD_INT },
		"description" : { loader = LIBSTD_STRING, default = "???" },
		"veclass" : { loader = LIBSTD_INT }
	}

func frameTemplate():
	return {
		"onboard" : { loader = LIBSTD_INT },
		"description" : { loader = LIBSTD_STRING, default = "???" },
		"statSpread" : { loader = LIBSTD_STATSPREAD }
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

func loaderVehicle(val):
	if val == null: return null
	return parseSubTemplate(vehicleTemplate(), val)

func loaderFrame(val):
	if val == null: return null
	return parseSubTemplate(frameTemplate(), val)
