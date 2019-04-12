extends "res://classes/library/lib_base.gd"

const LIBEXT_SKILL_LIST = "loaderSkillList"




var example = {
	"debug" : {
		"debug": {
			name = "Unarmed", wclass = core.skill.WPCLASS_FIST,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "bash"], ["debug", "debug"] ],
			over = ["debug", "debug"],
		},
		"debugg": {
			name = "Debug Gun", wclass = core.skill.WPCLASS_HANDGUN,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "shoot"], ["debug", "debugi"] ],
			over = ["debug", "debug"]
		},
		"debugs": {
			name = "Debug Shield", wclass = core.skill.WPCLASS_SHIELD,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "kiragrd"], ["debug", "kiraprtc"] ],
			over = ["debug", "debug"]
		},
		"spllcard": {
			name = "Spell Card", wclass = core.skill.WPCLASS_GRIMOIRE,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "debugi2"], ["debug", "unanlove"] ],
			over = ["debug", "debug"]
		},
		"soldrifl": {
			name = "MTM-GA23 Solid Rifle", wclass = core.skill.WPCLASS_FIREARM,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "trikshot"], ["debug", "hyprshot"] ],
			over = ["debug", "debug"]
		},
		"boostbld": {
			name = "MTM-GA12 Boost Glaive", wclass = core.skill.WPCLASS_POLEARM,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "shckstab"], ["debug", "wideslsh"] ],
			over = ["debug", "debug"]
		},
		"hellfngr": {
			name = "Hellfanger", wclass = core.skill.WPCLASS_LONGSWORD,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "fireslsh"], ["debug", "wideslsh"] ],
			over = ["debug", "debug"]
		},
	},
	"story" : {
		"orbicann": {
			name = "ORBITAL Cannon", wclass = core.skill.WPCLASS_ARTILLERY,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["sto_wp", "sever"], ["sto_wp", "orbishld"] ],
			over = ["debug", "debug"]
		},
	}
}

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING },
		"desc" : { loader = LIBSTD_STRING },
		"wclass" : { loader = LIBSTD_INT, default = core.skill.WPCLASS_NONE },
		"ATK" : { loader = LIBSTD_SKILL_ARRAY },
		"ETK" : { loader = LIBSTD_SKILL_ARRAY },
		"weight" : { loader = LIBSTD_SKILL_ARRAY },
		"durability" : { loader = LIBSTD_SKILL_ARRAY },
		"skill" : { loader = LIBEXT_SKILL_LIST },
		"over" : { loader = LIBSTD_TID },
	}


func loadDebug():
	loadDict(example)
	print("Weapon library:")
	printData()

func name(id):
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"

func loaderSkillList(val):
	if val == null:
		return [ null, null ]
	else:
		var result = [
			core.tid.create(val[0][0], val[0][1]) if val[0] != null else null,
			core.tid.create(val[1][0], val[1][1]) if val[1] != null else null,
		]
		return result
