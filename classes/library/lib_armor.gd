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

enum {
	PARTS_NONE =      0x0000,
	PARTS_ENGINE =    0x0001,
	PARTS_SENSORS =   0x0002,
	PARTS_FCS =       0x0004,
	PARTS_MOBILITY =  0x0008,
	PARTS_COOLING =   0x0010,
	# Frame only
	PARTS_ARMS =      0x0020,
	PARTS_BOOSTER =   0x0040,
}

const VEPARTS = {
	VECLASS_SMALL: PARTS_ENGINE|PARTS_FCS|PARTS_MOBILITY|PARTS_COOLING,
	VECLASS_LARGE: PARTS_ENGINE|PARTS_SENSORS|PARTS_FCS|PARTS_MOBILITY|PARTS_COOLING,
	VECLASS_HEAVY: PARTS_ENGINE|PARTS_SENSORS|PARTS_FCS|PARTS_MOBILITY|PARTS_COOLING,
	VECLASS_AERIAL: PARTS_ENGINE|PARTS_SENSORS|PARTS_FCS|PARTS_COOLING|PARTS_BOOSTER,
	VECLASS_VANGUARD: PARTS_ENGINE|PARTS_SENSORS|PARTS_FCS|PARTS_MOBILITY|PARTS_COOLING|PARTS_ARMS|PARTS_BOOSTER,
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
	}


func loadDebug():
	print("[ARMOR][loadDebug] Loading armor lib.")
	loadDict(example)
	print("[ARMOR][loadDebug] Armor loaded.")

func loaderArmorStats(val) -> Array:
	if val == null:
		return [0, 1]
	if typeof(val) == TYPE_ARRAY and val.size() == 2:
		return [int(val[0]), int(val[1])]
	else:
		return [0, 1]

func loaderVehicle(val):
	if val == null:
		return null
	return null

func loaderFrame(val):
	if val == null:
		return null
	return null
