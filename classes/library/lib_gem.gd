extends "res://classes/library/lib_base.gd"
var skill = core.skill

const LIBEXT_BODYBONUS = "loaderBodyBonus"
const LIBEXT_WEAPONBONUS = "loaderWeaponBonus"
const LIBEXT_SKILL_MODIFIER = "loaderSkillModifier"
const LIBEXT_TID = "loaderTID2" #Able to return null

enum {
	GEMSHAPE_NONE,
	GEMSHAPE_DIAMOND,
	GEMSHAPE_CIRCLE,
	GEMSHAPE_SQUARE,
	GEMSHAPE_TRIANGLE,
}

var example = {
	"debug" : {
	 	"debug" : {
			name = "Debug",
			levels = 10,
			desc = "???",
			shape = GEMSHAPE_DIAMOND,
			color = "#FFFF22",
			on_weapon = {
				ATK = [001, 001, 002, 002, 005,   005, 005, 005, 005, 005], #Attack
				ETK = [001, 001, 002, 002, 005,   005, 005, 005, 005, 005], #Energy attack
				WRD = [001, 001, 001, 001, 002,   002, 002, 002, 002, 002], #Weight reduction
				DUR = [010, 011, 012, 013, 015,   002, 002, 002, 002, 002], #Durability increase
				OFF = {
					DMG_ULTIMATE = [010, 011, 012, 013, 015,   002, 002, 002, 002, 002],
				},
				RES = {
					DMG_ULTIMATE = [010, 011, 012, 013, 015,   002, 002, 002, 002, 002],
				},
	 		},
			skill = ["debug", "debug"],
 		},
	},
	"core" : {
		"speed" : {
			name = "Speed",
			levels = 10,
			shape = GEMSHAPE_CIRCLE,
			color = "#5522FF",
			on_weapon = {
				ATK = [-04, -04, -04, -04, -02,   -02, -02, -02, -02, -00],
				ETK = [-04, -04, -04, -04, -02,   -02, -02, -02, -02, -00],
				AGI = [002, 002, 003, 003, 004,   004, 004, 005, 005, 006],
			}
		},
		"endur" : {
			name = "Endurance",
			levels = 10,
			shape = GEMSHAPE_CIRCLE,
			color = "#FF22FF",
			on_weapon = {
				EDF = [-02, -02, -02, -02, -01,   -01, -01, -01, -01, -00],
				DEF = [002, 002, 003, 003, 004,   004, 004, 005, 005, 006],
			}
		},
		"wisdo" : {
			name = "Wisdom",
			levels = 10,
			shape = GEMSHAPE_CIRCLE,
			color = "#FF22FF",
			on_weapon = {
				DEF = [-02, -02, -02, -02, -01,   -01, -01, -01, -01, -00],
				EDF = [002, 002, 003, 003, 004,   004, 004, 005, 005, 006],
			}
		},
		"stren" : {
			name = "Strength",
			levels = 10,
			shape = GEMSHAPE_CIRCLE,
			color = "#FF2222",
			on_weapon = {
				ATK = [002, 002, 003, 003, 004,   004, 004, 005, 005, 006],
				ETK = [-02, -02, -02, -02, -01,   -01, -01, -01, -01, -00],
			}
		},
		"intel" : {
			name = "Intelligence",
			levels = 10,
			shape = GEMSHAPE_CIRCLE,
			color = "#0022FF",
			on_weapon = {
				ETK = [002, 002, 003, 003, 004,   004, 004, 005, 005, 006],
				ATK = [-02, -02, -02, -02, -01,   -01, -01, -01, -01, -00],
			}
		},
		"luck" : {
			name = "Luck",
			levels = 10,
			shape = GEMSHAPE_CIRCLE,
			color = "#0022FF",
			on_weapon = {
				LUC = [002, 002, 003, 003, 004,   004, 004, 005, 005, 006],
			}
		},
		"flame" : {
			name = "Flame",
			levels = 10,
			desc = "Contains the raw essence of fire. Provides the skill Fire Wave.",
			shape = GEMSHAPE_DIAMOND,
			color = "#FF2222",
			on_weapon = {
				ATK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ETK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 007, 010], #Durability increase
				OFF = {
					DMG_FIRE = [002, 002, 003, 003, 005,   005, 005, 006, 006, 008],
				},
				RES = {
					DMG_FIRE = [001, 001, 001, 001, 003,   003, 003, 003, 003, 005],
				},
			},
			skill = ["gem", "firewave"],
		},
		"frost" : {
			name = "Frost",
			levels = 10,
			desc = "Contains the raw essence of cold. Provides the skill Cryoblast.",
			shape = GEMSHAPE_DIAMOND,
			color = "#6ED8E3",
			on_weapon = {
				ATK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ETK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 007, 010], #Durability increase
				OFF = {
					DMG_ICE = [002, 002, 003, 003, 005,   005, 005, 006, 006, 008],
				},
				RES = {
					DMG_ICE = [001, 001, 001, 001, 003,   003, 003, 003, 003, 005],
				},
			},
			skill = ["gem", "cryoblst"],
		},
		"shock" : {
			name = "Shock",
			levels = 10,
			desc = "Contains the raw essence of lightning. Provides the skill Electroburst.",
			shape = GEMSHAPE_DIAMOND,
			color = "#E2E36E",
			on_weapon = {
				ATK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ETK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 007, 010], #Durability increase
				OFF = {
					DMG_ELEC = [002, 002, 003, 003, 005,   005, 005, 006, 006, 008],
				},
				RES = {
					DMG_ELEC = [001, 001, 001, 001, 003,   003, 003, 003, 003, 005],
				},
			},
			skill = ["gem", "eleburst"],
		},
		"wind" : {
			name = "Wind",
			levels = 10,
			desc = "Contains the raw essence of the wind. Provides the skill Gale Blade.",
			shape = GEMSHAPE_DIAMOND,
			color = "#72E36E",
			on_weapon = {
				ATK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ETK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 007, 010], #Durability increase
				OFF = {
					DMG_CUT = [002, 002, 003, 003, 005,   005, 005, 006, 006, 008],
				},
				RES = {
					DMG_CUT = [001, 001, 001, 001, 003,   003, 003, 003, 003, 005],
				},
			},
			skill = ["gem", "galeblde"],
		},
		"cut" : {
			name = "Cut",
			levels = 10,
			desc = "Contains the raw essence of the wind. Provides the skill Slash.",
			shape = GEMSHAPE_DIAMOND,
			color = "#72E36E",
			on_weapon = {
				ETK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ATK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 007, 010], #Durability increase
				OFF = {
					DMG_CUT = [002, 002, 003, 003, 005,   005, 005, 006, 006, 008],
				},
				RES = {
					DMG_CUT = [001, 001, 001, 001, 003,   003, 003, 003, 003, 005],
				},
			},
			skill = ["gem", "slash"],
		},
		"water" : {
			name = "Water",
			levels = 10,
			desc = "Contains the raw essence of water. Provides the skill Aqua Impact.",
			shape = GEMSHAPE_DIAMOND,
			color = "#6EA4E3",
			on_weapon = {
				ATK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ETK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 007, 010], #Durability increase
				OFF = {
					DMG_BLUNT = [002, 002, 003, 003, 005,   005, 005, 006, 006, 008],
				},
				RES = {
					DMG_BLUNT = [001, 001, 001, 001, 003,   003, 003, 003, 003, 005],
				},
			},
			skill = ["gem", "aquabrst"],
		},
		"blunt" : {
			name = "Blunt",
			levels = 10,
			desc = "Contains the raw essence of water. Provides the skill Smash.",
			shape = GEMSHAPE_DIAMOND,
			color = "#6EA4E3",
			on_weapon = {
				ETK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ATK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 007, 010], #Durability increase
				OFF = {
					DMG_BLUNT = [002, 002, 003, 003, 005,   005, 005, 006, 006, 008],
				},
				RES = {
					DMG_BLUNT = [001, 001, 001, 001, 003,   003, 003, 003, 003, 005],
				},
			},
			skill = ["gem", "smash"],
		},
		"earth" : {
			name = "Earth",
			levels = 10,
			desc = "Contains the raw essence of earth. Provides the skill Gem Spear.",
			shape = GEMSHAPE_DIAMOND,
			color = "#E26EE3",
			on_weapon = {
				ATK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ETK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 007, 010], #Durability increase
				OFF = {
					DMG_PIERCE = [002, 002, 003, 003, 005,   005, 005, 006, 006, 008],
				},
				RES = {
					DMG_PIERCE = [001, 001, 001, 001, 003,   003, 003, 003, 003, 005],
				},
			},
			skill = ["gem", "gemspear"],
		},
		"pierce" : {
			name = "Pierce",
			levels = 10,
			desc = "Contains the raw essence of earth. Provides the skill Perforate.",
			shape = GEMSHAPE_DIAMOND,
			color = "#E26EE3",
			on_weapon = {
				ETK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ATK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 007, 010], #Durability increase
				OFF = {
					DMG_PIERCE = [002, 002, 003, 003, 005,   005, 005, 006, 006, 008],
				},
				RES = {
					DMG_PIERCE = [001, 001, 001, 001, 003,   003, 003, 003, 003, 005],
				},
			},
			skill = ["gem", "perfrate"],
		},
		"void" : {
			name = "Void",
			levels = 10,
			desc = "Contains the raw essence of space. Provides the skill Destroy.",
			shape = GEMSHAPE_DIAMOND,
			color = "#000000",
			on_weapon = {
				ATK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ETK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 007, 010], #Durability increase
				OFF = {
					DMG_ULTIMATE = [002, 002, 003, 003, 005,   005, 005, 006, 006, 008],
				},
				RES = {
					DMG_ULTIMATE = [001, 001, 001, 001, 003,   003, 003, 003, 003, 005],
				},
			},
			skill = ["gem", "destroy"],
		},
		"life" : {
			name = "Life",
			levels = 10,
			desc = "Contains the raw essence of life. Provides the skill Revitalize.",
			shape = GEMSHAPE_DIAMOND,
			color = "#DDDDDD",
			on_weapon = {
				ATK = [-001, -001, -001, -001, -001,   -002, -002, -002, -002, -002], #Attack
				ETK = [-001, -001, -001, -001, -001,   -002, -002, -002, -002, -002], #Energy attack
				EDF = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005],
				DUR = [002, 002, 003, 003, 005,   005, 006, 006, 006, 008], #Durability increase
			},
			skill = ["gem", "revitlze"],
		},
		"echo" : {
			name = "Echo",
			levels = 10,
			desc = "Reacts to enviromental energies. Provides the skill Echo Burst.",
			shape = GEMSHAPE_DIAMOND,
			color = "#3F13AF",
			on_weapon = {
				ATK = [-001, -001, -002, -002, -005,   -005, -005, -005, -005, -005], #Attack
				ETK = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005], #Energy attack
				AGI = [+001, +001, +001, +001, +001,   +001, +001, +001, +001, +002], #Energy attack
				DUR = [003, 003, 004, 004, 007,   007, 008, 008, 009, 012], #Durability increase
			},
			skill = ["gem", "echo"],
		},
		"protect" : {
			name = "Protect",
			levels = 10,
			desc = "Reacts to positive emotions. Provides the skill Dragon Shield.",
			shape = GEMSHAPE_DIAMOND,
			color = "#3F13AF",
			on_weapon = {
			ATK = [-001, -001, -001, -001, -001,   -002, -002, -002, -002, -002], #Attack
			ETK = [-001, -001, -001, -001, -001,   -002, -002, -002, -002, -002], #Energy attack
			EDF = [+001, +001, +002, +002, +005,   +005, +005, +005, +005, +005],
			DUR = [001, 001, 002, 002, 003,   003, 003, 004, 004, 005], #Durability increase
			},
			skill = ["gem", "drshield"],
		},
		"power" : {
			name = "Power",
			levels = 10,
			desc = "Raises power and cost of the linked skill.",
			shape = GEMSHAPE_SQUARE,
			color = "#AAAAAA",
			on_weapon = {
				DUR = [003, 003, 004, 004, 005,   005, 006, 006, 007, 008], #Durability increase
			},
			skillMod = {
				power = [110, 113, 115, 119, 125,   128, 130, 136, 142, 150],
			}
		},
		"reson" : {
			name = "Resonance",
			levels = 10,
			desc = "Increases field effect multiplier.",
			shape = GEMSHAPE_SQUARE,
			color = "#8FDFDC",
			on_weapon = {
				DUR = [003, 004, 005, 006, 015,   002, 002, 002, 002, 002], #Durability increase
			},
			skillMod = {
				fieldEffectMult = [001, 001, 001, 001, 002,   002, 002, 002, 002, 003],
			}
		},
		"atunm" : {
			name = "Attunement",
			levels = 10,
			desc = "Increases field effect charge.",
			shape = GEMSHAPE_SQUARE,
			color = "#8FDCBF",
			on_weapon = {
			},
			skillMod = {
				fieldEffectAdd = [001, 001, 001, 001, 002,   002, 002, 002, 002, 003],
			}
		},
		"accel" : {
			name = "Acceleration",
			levels = 10,
			desc = "Makes the linked gem faster.",
			shape = GEMSHAPE_SQUARE,
			color = "#AAAAAA",
			on_weapon = {
			},
			skillMod = {
				spdMod = [102, 102, 103, 103, 105,   105, 107, 107, 108, 110],
			}
		},
		"decel" : {
			name = "Deceleration",
			levels = 10,
			desc = "Makes the linked gem slower.",
			shape = GEMSHAPE_SQUARE,
			color = "#AAAAAA",
			on_weapon = {
			},
			skillMod = {
				spdMod = [090, 085, 085, 080, 070,   070, 065, 065, 060, 050],
			}
		},
		"accrc" : {
			name = "Accuracy",
			levels = 10,
			desc = "Makes the linked gem more accurate, and makes it long range from level 5 and above.",
			shape = GEMSHAPE_SQUARE,
			color = "#AAAAAA",
			on_weapon = {
			},
			skillMod = {
				accMod = [102, 102, 103, 103, 105,   105, 107, 107, 108, 110],
				ranged = [000, 000, 000, 000, 001,   001, 001, 001, 001, 001],
			}
		},
		"expan" : {
			name = "Expansion",
			levels = 10,
			desc = "Increases area effect of linked skill. Levels 1-4 make it have splash damage, levels 5-9 make it target a row, lv.10 targets all.",
			shape = GEMSHAPE_SQUARE,
			color = "#AAAAAA",
			on_weapon = {
			},
			skillMod = {
				target = ['spread', 'spread', 'spread', 'spread', 'row',   'row', 'row', 'row', 'row', 'all']
			}
		},
		"drain" : {
			name = "Drain",
			levels = 10,
			desc = "Makes skill drain some health on hit.",
			shape = GEMSHAPE_SQUARE,
			color = "#111111",
			on_weapon = {
			},
			skillMod = {
				lifeDrain = [002, 003, 004, 005, 008,   009, 010, 011, 012, 015],
			}
		},
		"insig" : {
			name = "Insight",
			levels = 10,
			desc = "Increases EXP obtained from target.",
			shape = GEMSHAPE_SQUARE,
			color = "#C11F66",
			on_weapon = {
			},
			skillMod = {
				exp_bonus = [005, 008, 012, 014, 020,   022, 026, 030, 033, 040],
			}
		},
		"charge" : {
			name = "Focus",
			levels = 10,
			desc = "Makes linked skill slower, and decreases active defense until it activates, but greatly increases its power.",
			shape = GEMSHAPE_SQUARE,
			color = "#018E3E",
			on_weapon = {
			},
			skillMod = {
				spdMod = [010, 015, 020, 025, 035,   040, 045, 050, 055, 070],
				initAD = [200, 200, 200, 200, 200,   200, 200, 200, 200, 200],
				power  = [125, 130, 135, 140, 160,   165, 170, 175, 180, 200],
				chargeAnim = [100, 100, 100, 100, 100, 100, 100, 100, 100, 100],
			}
		},
		"merls" : {
			name = "Cruelty",
			levels = 10,
			desc = "Linked skill does more damage if enemy has a status effect active.",
			shape = GEMSHAPE_SQUARE,
			color = "#04FFEF",
			on_weapon = {
			},
			skillMod = {
				merciless = [050, 055, 060, 065, 080,   085, 090, 095, 100, 110],
			}
		},
		"scttr" : {
			name = "Scatter",
			levels = 10,
			desc = "Linked skill hits multiple times, but at reduced power.",
			shape = GEMSHAPE_SQUARE,
			color = "#FF8000",
			on_weapon = {
			},
			skillMod = {
				numhits = [002, 002, 002, 002, 002,   002, 002, 002, 002, 003],
				power  =  [050, 055, 055, 060, 060,   060, 065, 065, 065, 065],
			}
		},
		"phase" : {
			name = "Phase",
			levels = 10,
			desc = "Linked skill ignores target's guard and barrier after level 5.",
			shape = GEMSHAPE_SQUARE,
			color = "#FF8000",
			on_weapon = {
			},
			skillMod = {
				ignoreDefs = [000, 000, 000, 000, 001,   001, 001, 001, 001, 001],
			}
		},
		"rebifire" : {
			name = "Rebind: Fire",
			levels = 10,
			desc = "Linked skill changes element to fire.",
			shape = GEMSHAPE_SQUARE,
			color = "#FF2222",
			on_weapon = {
			},
			skillMod = {
				element = [004, 004, 004, 004, 004,   004, 004, 004, 004, 004],
			}
		},
		"rebicold" : {
			name = "Rebind: Cold",
			levels = 10,
			desc = "Linked skill changes element to cold.",
			shape = GEMSHAPE_SQUARE,
			color = "#6ED8E3",
			on_weapon = {
			},
			skillMod = {
				element = [005, 005, 005, 005, 005,   005, 005, 005, 005, 005],
			}
		},
		"rebibolt" : {
			name = "Rebind: Bolt",
			levels = 10,
			desc = "Linked skill changes element to bolt.",
			shape = GEMSHAPE_SQUARE,
			color = "#E2E36E",
			on_weapon = {
			},
			skillMod = {
				element = [006, 006, 006, 006, 006,   006, 006, 006, 006, 006],
			}
		},
		"rebiwind" : {
			name = "Rebind: Wind",
			levels = 10,
			desc = "Linked skill changes element to cut.",
			shape = GEMSHAPE_SQUARE,
			color = "#72E36E",
			on_weapon = {
			},
			skillMod = {
				element = [001, 001, 001, 001, 001,   001, 001, 001, 001, 001],
			}
		},
		"rebierth" : {
			name = "Rebind: Earth",
			levels = 10,
			desc = "Linked skill changes element to pierce.",
			shape = GEMSHAPE_SQUARE,
			color = "#E26EE3",
			on_weapon = {
			},
			skillMod = {
				element = [002, 002, 002, 002, 002,   002, 002, 002, 002, 002],
			}
		},
		"rebiwatr" : {
			name = "Rebind: Water",
			levels = 10,
			desc = "Linked skill changes element to blunt.",
			shape = GEMSHAPE_SQUARE,
			color = "#6EA4E3",
			on_weapon = {
			},
			skillMod = {
				element = [003, 003, 003, 003, 003,   003, 003, 003, 003, 003],
			}
		},
		"rebivoid" : {
			name = "Rebind: Gravity",
			levels = 10,
			desc = "Linked skill changes element to void.",
			shape = GEMSHAPE_SQUARE,
			color = "#000022",
			on_weapon = {
			},
			skillMod = {
				element = [007, 007, 007, 007, 007,   007, 007, 007, 007, 007],
			}
		},
	},
	
}


func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING, default = "Unknown" },
		"levels" : { loader = LIBSTD_INT, default = int(10) },
		"growth" : { loader = LIBSTD_INT, default = 0 },
		"desc" : { loader = LIBSTD_STRING, default = "???" },
		"shape" : { loader = LIBSTD_INT, default = GEMSHAPE_NONE},
		"color" : { loader = LIBSTD_STRING, default = "FFFF22" },
		"unique" : { loader = LIBSTD_BOOL, default = false },
		"on_weapon" : { loader = LIBEXT_WEAPONBONUS },
		"on_body" : { loader = LIBEXT_BODYBONUS },
		"skill" : { loader = LIBEXT_TID, default = null },
		"skillMod" : { loader = LIBEXT_SKILL_MODIFIER, default = null },
	}

func loadDebug():
	loadDict(example)
	print("[LIB] Dragon Gem library loaded.")

func name(id):
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"


func loaderSkillModifier(val):
	return null if val == null else val.duplicate()

func loaderWeaponBonus(val):
	if val == null:
		return null
	else:
		var result = {}
		for i in ['WRD', 'DUR', 'CRI', 'ATK', 'DEF', 'ETK', 'EDF', 'AGI', 'LUC']:
			if i in val:
				result[i] = core.newArray(10)
				for j in range(10):
					result[i][j] = int(val[i][j])
		for i in ['OFF', 'RES']:
			result[i] = {}
			if i in val:
				var temp = val[i]
				for j in core.stats.ELEMENTS:
					result[i][j] = loaderSkillArray(temp[j] if j in temp else [0,0,0,0,0, 0,0,0,0,0])
			else:
				for j in core.stats.ELEMENTS:
					result[i][j] = loaderSkillArray([0,0,0,0,0, 0,0,0,0,0])

		return result
		
func loaderTID2(val):
	if val == null:
		return null
	else:
		return core.tid.create(val[0], val[1])

func loaderBodyBonus(val):
	if val == null:
		return null
	else:
		var result = {}
		for i in ['MHP', 'MEP', 'ATK', 'DEF', 'ETK', 'EDF', 'AGI', 'LUC']:
			if i in val:
				result[i] = int(val[i])
		return result
