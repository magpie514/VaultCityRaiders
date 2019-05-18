extends "res://classes/library/lib_base.gd"

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
				slots = 8,
			}
		},
		"frame" : {
			name = "Debug Frame", arclass = ARCLASS_FRAME,
			DEF =    [100, 120], EDF = [100, 120],
			frame = {
				onboard = 2,
				veclass = VECLASS_HEAVY,
				slots = 8,
			}
		}

}
