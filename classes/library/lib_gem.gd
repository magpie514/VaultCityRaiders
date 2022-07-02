extends "res://classes/library/lib_base.gd"
var skill = core.skill

const LIBEXT_BODYBONUS = "loaderBodyBonus"
const LIBEXT_WEAPONBONUS = "loaderWeaponBonus"
const LIBEXT_SKILL_MODIFIER = "loaderSkillModifier"
const LIBEXT_TID = "loaderTID2" #Able to return null

enum {
	GEMSHAPE_NONE,    #Empty slot?
	GEMSHAPE_DIAMOND, #Skill gems
	GEMSHAPE_CIRCLE,  #Stat gems
	GEMSHAPE_SQUARE,  #Modifier gems
	GEMSHAPE_TRIANGLE,#Over gems
	GEMSHAPE_STAR,    #Unique Over gem (Body only)
}

#TODO:
#[ ] Gems for various condition effects.
#[ ] Gem for multiple condition effects in one.
#[v] Gem that adds extra hits (damage opcodes)
#[ ] Gems that add elements to the field of the specified element. (like Field Burst: Wind)
#[v] Gem that makes linked skill a chain starter or starter/follow.
#[ ] Some sort of skill mod to allow chain finishers.
#[ ] Skill mod to "divide" a damage opcode into two. Madness.
#[ ] Allow providing up to 4 skills defined by level (make SKL a 4-bit int to choose?)
#[v] Replace skillmods for an array so order can be preserved.
#[x] Move gem skill factory to its own class, inheriting from skill, I guess.
#Finish the star gem set:
#[ ] Rasalhague, for Serpentarius.
#[ ] Fomalhaut, for Pisces (Jay) One of these things is not like the others.
#[ ] Regulus, for Leo. (Magpie)
#[ ] Antares, for Scorpio (Shiro)
#[ ] Aldebaran, for Taurus (Anna)
#[ ] Polaris (Yukiko)
#[ ] Sol (Elodie)
#[ ] Betelgeuse (King Solarica)
#[ ] Spica, for Virgo.


var example = {
	"debug" : {
		"debug" : {
			name = "Debug",
			levels = 10,
			desc = "???",
			shape = GEMSHAPE_DIAMOND,
			color = "#FFFF22",
			on_weapon = {
				ATK     = [001,001,002,002,005, 005,005,005,005,005], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack
				WRD     = [001,001,001,001,002, 002,002,002,002,002], #Weight reduction
				DUR     = [010,011,012,013,015, 002,002,002,002,002], #Durability increase
				ALL_ULT = [003,003,003,003,005, 005,005,005,005,008], #Ultimate offense/defense bonus
			},
			skill = ["debug", "debug"],
		},
	},
	"story" : {
		"fmalhaut": { #Jay's personal Star. Inherited from Fomalhaut.
			name = "Fomalhaut",
			levels = 10,
			desc = "One of the four Royal Stars, the brightest in the Piscis Austrinus constellation. A bluish white star, inherited from a noble hero.",
			shape = GEMSHAPE_STAR,
		},
		"regulus1": { #Magpie's personal Star. Starts with it equipped. Bad.
			name = "Regulus",
			levels = 0,
			desc = "One of the four Royal Stars, the brightest in the Leo constellation. Signifies the power of a King, but for some reason, it's dormant.",
			shape = GEMSHAPE_STAR,
		},
		"regulus2": { #Magpie's personal Star. Powered up during the final arc.
			name = "Regulus",
			levels = 10,
			desc = "One of the four Royal Stars, the brightest in the Leo constellation. Signifies the power of a King, and grants victory to those with a strong desire for justice.",
			shape = GEMSHAPE_STAR,
		},
		"antares": { #Shiro's personal Star. Inherited from his family line.
			name = "Antares",
			levels = 10,
			desc = "One of the four Royal Stars, the brightest in the Scorpius constellation. A vermillion star that watches over those whose destiny is marked by blood.",
			shape = GEMSHAPE_STAR,
		},
		"aldbaran": { #Anna's personal Star. Given to her by Mister Raven.
			name = "Aldebaran",
			levels = 10,
			desc = "One of the four Royal Stars, the brightest in the Taurus constellation. A red star guiding those seeking revenge for an injustice.",
			shape = GEMSHAPE_STAR,
		},
		"polaris": { #Yukiko's personal Star. Starts with it equipped.
			name = "Polaris",
			levels = 10,
			desc = "Alpha Ursae Minoris. The current Northern Polar Star in Earth's firmament. A yellow star that watches over the planet.",
			shape = GEMSHAPE_STAR,
		},
		"primblue": { #Yukiko's second personal Star. Created by herself during the final arc.
			name = "Prime Blue",
			levels = 10,
			desc = "A fragment of hope. Resonates with the power of Over energy.",
			shape = GEMSHAPE_STAR,
		},
		"sol": { #Elodie's personal Star. Belonged to her uncle.
			name = "Sol",
			levels = 10,
			desc = "The brightest star in our solar system. A yellow star that unites all life.",
			shape = GEMSHAPE_STAR,
		},
		"beetleju": { #King Solarica's personal Star. Obtained at birth.
			name = "Betelgeuse",
			levels = 10,
			desc = "One of the brightest stars in the sky. A gigantic red star of bloody conquest.",
			shape = GEMSHAPE_STAR,
		}

	},
	"core" : {
# Triangle (special) gems #####################################################
		"growth" : {
			name = "Growth",
			levels = 10,
			shape = GEMSHAPE_TRIANGLE,
			color = "#5522FF",
			on_weapon = {
				GEM = [020,040,060,080,100, 120,140,160,180,200], #Gem growth%
			}
			#TODO: EXP modifier for all equipped gems.
		},
# Round (stat) gems ###########################################################
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
				ETK = [002,002,003,003,004, 004,004,005,005,006],
				ATK = [-02,-02,-02,-02,-01, -01,-01,-01,-01,-00],
			}
		},
		"luck" : {
			name = "Luck",
			levels = 10,
			shape = GEMSHAPE_CIRCLE,
			color = "#0022FF",
			on_weapon = {
				LUC = [002,002,003,003,004, 004,004,005,005,006],
			}
		},
		"hope" : {
			name = "Hope",
			levels = 10,
			shape = GEMSHAPE_CIRCLE,
			color = "#0022FF",
			on_weapon = {
				OVR = [001,002,003,004,005, 006,007,008,009,010],
			}
		},
# Diamond (skill) gems ########################################################
		"flame" : {
			name = "Flame",
			levels = 10,
			desc = "Contains the raw essence of fire. Provides the skill Fire Wave.",
			shape = GEMSHAPE_DIAMOND,
			color = "#FF2222",
			on_weapon = {
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increase
				OFF_FIR = [002,002,003,003,005, 005,005,006,006,008],
				RES_FIR = [001,001,001,001,003, 003,003,003,003,005],
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
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increase
				OFF_ICE = [002,002,003,003,005, 005,005,006,006,008],
				RES_ICE = [001,001,001,001,003, 003,003,003,003,005],
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
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increase
				OFF_ELE = [002,002,003,003,005, 005,005,006,006,008],
				RES_ELE = [001,001,001,001,003, 003,003,003,003,005],
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
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increase
				OFF_CUT = [002,002,003,003,005, 005,005,006,006,008],
				RES_CUT = [001,001,001,001,003, 003,003,003,003,005],
			},
			skill = "gem/galeblde",
		},
		"cut" : {
			name = "Cut",
			levels = 10,
			desc = "Contains the raw essence of the wind. Provides the skill Slash.",
			shape = GEMSHAPE_DIAMOND,
			color = "#72E36E",
			on_weapon = {
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increase
				OFF_CUT = [002,002,003,003,005, 005,005,006,006,008],
				RES_CUT = [001,001,001,001,003, 003,003,003,003,005],
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
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increase
				OFF_STK = [002,002,003,003,005, 005,005,006,006,008],
				RES_STK = [001,001,001,001,003, 003,003,003,003,005],
			},
			skill = ["gem", "aquabrst"],
		},
		"blunt" : {
			name = "Strike",
			levels = 10,
			desc = "Contains the raw essence of water. Provides the skill Smash.",
			shape = GEMSHAPE_DIAMOND,
			color = "#6EA4E3",
			on_weapon = {
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increase
				OFF_STK = [002,002,003,003,005, 005,005,006,006,008],
				RES_STK = [001,001,001,001,003, 003,003,003,003,005],
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
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack-005], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack+005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increaserability increase
				OFF_PIE = [002,002,003,003,005, 005,005,006,006,008],
				RES_PIE = [001,001,001,001,003, 003,003,003,003,005],
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
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack-005], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack+005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increaserability increase
				OFF_PIE = [002,002,003,003,005, 005,005,006,006,008],
				RES_PIE = [001,001,001,001,003, 003,003,003,003,005],
			},
			skill = ["gem", "perfrate"],
		},
		"radiance" : {
			name   = "Radiance",
			levels = 10,
			desc   = "Contains the raw essence of the unknown. Provides the skill Time Crash.",
			shape  = GEMSHAPE_DIAMOND,
			color  = "#EEEECC",
			on_weapon = {
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increase
				OFF_UNK = [002,002,003,003,005, 005,005,006,006,008],
				RES_UNK = [001,001,001,001,003, 003,003,003,003,005],
			},
			skill = ["gem", "destroy"],
		},
		"void" : {
			name = "Void",
			levels = 10,
			desc = "Contains the raw essence of space. Provides the skill Destroy.",
			shape = GEMSHAPE_DIAMOND,
			color = "#000000",
			on_weapon = {
				ATK     = [-01,-01,-02,-02,-05, -05,-05,-05,-05,-05], #Attack
				ETK     = [001,001,002,002,005, 005,005,005,005,005], #Energy attack
				DUR     = [002,002,003,003,005, 005,006,006,007,010], #Durability increase
				OFF_ULT = [002,002,003,003,005, 005,005,006,006,008],
				RES_ULT = [001,001,001,001,003, 003,003,003,003,005],
			},
			skill = "gem/destroy",
		},
		"life" : {
			name = "Life",
			levels = 10,
			desc = "Contains the raw essence of life. Provides the skill Revitalize.",
			shape = GEMSHAPE_DIAMOND,
			color = "#CCDDCC",
			on_weapon = {
				ATK = [-01,-01,-01,-01,-01, -02,-02,-02,-02,-02], #Attack
				ETK = [-01,-01,-01,-01,-01, -02,-02,-02,-02,-02], #Energy attack
				EDF = [001,001,002,002,005, 005,005,005,005,005],
				DUR = [002,002,003,003,005, 005,006,006,006,008], #Durability increase
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
		"chaos" : {
			name = "Chaos",
			levels = 10,
			desc = "Raw essence of chaos. Provides the skill Prismatic Light.",
			shape = GEMSHAPE_DIAMOND,
			color = "#FFFFFF",
			on_weapon = {
				ATK = [001,001,002,002,003, 003,004,004,005,005],
				ETK = [001,001,002,002,003, 003,004,004,005,005],
				DEF = [-03,-03,-03,-03,-02, -02,-02,-02,-02,-01],
				EDF = [-03,-03,-03,-03,-02, -02,-02,-02,-02,-01],
			},
			skill = "gem/prism",
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
				EDF = [001,001,002,002,005, 005,005,005,005,005],
				DUR = [001, 001, 002, 002, 003,   003, 003, 004, 004, 005], #Durability increase
			},
			skill = "gem/drshield",
		},
# Square (mod) gems ###########################################################
		"power" : {
			name = "Power",
			levels = 10,
			desc = "Raises power and cost of the linked skill.",
			shape = GEMSHAPE_SQUARE,
			color = "#AAAAAA",
			skillMod = [
				[ skill.DGEM_POWER, 110,113,115,119,125, 128,130,136,142,150 ],
			]
		},
		"reson" : {
			name = "Resonance",
			levels = 10,
			desc = "Increases field effect multiplier.",
			shape = GEMSHAPE_SQUARE,
			color = "#8FDFDC",
			skillMod = [
				[ skill.DGEM_EF_MUL, 001,001,001,001,002, 002,002,002,002,003 ],
			]
		},
		"atunm" : {
			name = "Attunement",
			levels = 10,
			desc = "Increases field effect charge.",
			shape = GEMSHAPE_SQUARE,
			color = "#8FDCBF",
			skillMod = [
				[ skill.DGEM_EF_ADD, 001,001,001,001,002, 002,002,002,002,003 ],
			]
		},
		"accel" : {
			name = "Acceleration",
			levels = 10,
			desc = "Makes the linked gem's skill faster.",
			shape = GEMSHAPE_SQUARE,
			color = "#AAAAAA",
			skillMod = [
				[ skill.DGEM_SPD, 102,102,103,103,105, 105,107,107,108,110 ],
			]
		},
		"decel" : {
			name = "Deceleration",
			levels = 10,
			desc = "Makes the linked gem's skill slower.",
			shape = GEMSHAPE_SQUARE,
			color = "#AAAAAA",
			skillMod = [
				[ skill.DGEM_SPD, 090,085,085,080,070, 070,065,065,060,050 ],
			]
		},
		"accrc" : {
			name = "Accuracy",
			levels = 10,
			desc = "Makes the linked gem's skill more accurate, and makes it long range from level 5 and above.",
			shape = GEMSHAPE_SQUARE,
			color = "#AAAAAA",
			skillMod = [
				[ skill.DGEM_ACC  , 102,102,103,103,105, 105,107,107,108,110 ],
				[ skill.DGEM_RANGE, 000,000,000,000,001, 001,001,001,001,001 ]
			]
		},
		"expan" : {
			name = "Expansion",
			levels = 10,
			desc = "Increases area effect of linked gem's skill. Levels 1-4 make it have splash damage, levels 5-9 make it target a row, lv.10 targets all.",
			shape = GEMSHAPE_SQUARE,
			color = "#AAAAAA",
			skillMod = [
				[ skill.DGEM_TARGET, 001,001,001,001,002, 002,002,002,002,003 ],
				[ skill.DGEM_POWER , 080,087,090,095,075, 083,090,095,100,090 ]
			]
		},
		"drain" : {
			name = "Drain",
			levels = 10,
			desc = "Makes linked gem's skill drain some health on hit.",
			shape = GEMSHAPE_SQUARE,
			color = "#111111",
			skillMod = [
				[ skill.DGEM_LIFEDRAIN, 002,003,004,005,008, 009,010,011,012,015 ],
			]
		},
		"insig" : {
			name = "Insight",
			levels = 10,
			desc = "Increases EXP obtained from target.",
			shape = GEMSHAPE_SQUARE,
			color = "#C11F66",
			skillMod = [
				[ skill.DGEM_EXP_BONUS, 005,008,012,014,020, 022,026,030,033,040 ],
			]
		},
		"charge" : {
			name = "Focus",
			levels = 10,
			desc = "Makes linked gem's skill slower, and decreases Active Defense until it activates, but greatly increases its power.",
			shape = GEMSHAPE_SQUARE,
			color = "#018E3E",
			on_weapon = {
			},
			skillMod = [
				[ skill.DGEM_INITAD   , 200 ],
				[ skill.DGEM_SPD      , 010,015,020,025,035, 040,045,050,055,070 ],
				[ skill.DGEM_POWER    , 125,130,135,140,160, 165,170,175,180,200 ],
				[ skill.DGEM_CHARGE_FX, 001 ],
			]
		},
		"merls" : {
			name = "Cruelty",
			levels = 10,
			desc = "Linked gem's skill gets a damage bonus if target has a condition effect active. Cancels nonlethal effect.",
			shape = GEMSHAPE_SQUARE,
			color = "#EFFF04",
			skillMod = [
				[ skill.DGEM_COND_BONUS, 050,055,060,065,080, 085,090,095,100,110],
				[ skill.DGEM_NONLETHAL , 000 ],
			]
		},
		"mercy" : {
			name   = "Mercy",
			levels = 10,
			desc   = "Linked gem's skill becomes non-lethal.",
			shape  = GEMSHAPE_SQUARE,
			color  = "#04FFEF",
			on_weapon = {
				EDF = [000,000,000,000,001, 001,001,001,001,002],
			},
			skillMod = [
				[ skill.DGEM_NONLETHAL, 001 ],
				[ skill.DGEM_POWER    , 105,105,105,105,110, 110,110,110,110,120 ]
			]
		},
		"phase" : {
			name = "Phase",
			levels = 10,
			desc = "Linked skill ignores target's guard and barrier after level 5.",
			shape = GEMSHAPE_SQUARE,
			color = "#FF8000",
			skillMod = [
				[skill.DGEM_IGNOREBARRIER, 000,000,000,000,001 ],
				[skill.DGEM_POWER        , 080,084,088,092,098 ],
			]
		},
		"rebinull" : {
			name = "Rebind: Null",
			levels = 10,
			desc = "Linked skill changes element to none.",
			shape = GEMSHAPE_SQUARE,
			color = "#999999",
			skillMod = [ [ skill.DGEM_ELEMENT, 000 ] ]
		},
		"rebifire" : {
			inherits = "core/rebinull",
			name = "Rebind: Fire",
			desc = "Linked skill changes element to fire.",
			color = "#FF2222",
			skillMod = [ [ skill.DGEM_ELEMENT, 004 ] ]
		},
		"rebicold" : {
			inherits = "core/rebinull",
			name = "Rebind: Cold",
			desc = "Linked skill changes element to cold.",
			color = "#6ED8E3",
			skillMod = [ [ skill.DGEM_ELEMENT, 005 ] ]
		},
		"rebibolt" : {
			inherits = "core/rebinull",
			name = "Rebind: Bolt",
			desc = "Linked skill changes element to bolt.",
			color = "#E2E36E",
			skillMod = [ [ skill.DGEM_ELEMENT, 006 ] ]
		},
		"rebiwind" : {
			inherits = "core/rebinull",
			name = "Rebind: Wind",
			desc = "Linked skill changes element to cut.",
			color = "#72E36E",
			skillMod = [ [ skill.DGEM_ELEMENT, 001 ] ]
		},
		"rebierth" : {
			inherits = "core/rebinull",
			name = "Rebind: Earth",
			desc = "Linked skill changes element to pierce.",
			color = "#E26EE3",
			skillMod = [ [ skill.DGEM_ELEMENT, 002 ] ]
		},
		"rebiwatr" : {
			inherits = "core/rebinull",
			name = "Rebind: Water",
			desc = "Linked skill changes element to blunt.",
			color = "#6EA4E3",
			skillMod = [ [ skill.DGEM_ELEMENT, 003 ] ]
		},
		"rebilite" : {
			inherits = "core/rebinull",
			name = "Rebind: Light",
			desc = "Linked skill changes element to unknown.",
			color = "#000022",
			skillMod = [ [ skill.DGEM_ELEMENT, 007 ] ]
		},
		"rebivoid" : {
			inherits = "core/rebinull",
			name = "Rebind: Gravity",
			desc = "Linked skill changes element to ultimate.",
			color = "#000022",
			skillMod = [ [ skill.DGEM_ELEMENT, 008 ] ]
		},
	},
}


func initTemplate():
	return {
		"name"      : { loader = LIBSTD_STRING        , default = "Unknown" },
		"levels"    : { loader = LIBSTD_INT           , default = int(10) },
		"growth"    : { loader = LIBSTD_INT           , default = 0 },
		"desc"      : { loader = LIBSTD_STRING        , default = "???" },
		"shape"     : { loader = LIBSTD_INT           , default = GEMSHAPE_NONE},
		"color"     : { loader = LIBSTD_STRING        , default = "FFFF22" },
		"unique"    : { loader = LIBSTD_BOOL          , default = false },
		"on_weapon" : { loader = LIBEXT_WEAPONBONUS   , default = {} },
		"on_body"   : { loader = LIBEXT_BODYBONUS     , default = {} },
		"on_mon"    : { loader = LIBEXT_BODYBONUS     , default = {} },
		"skill"     : { loader = LIBEXT_TID           , default = null },
		"skillMod"  : { loader = LIBEXT_SKILL_MODIFIER, default = [] },
	}

func loadDebug():
	loadDict(example)
	print("[LIB] Dragon Gem library loaded.")

func name(id):
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"

func loaderSkillModifier(val) -> Array:
	var SRANGE:Array = range(11)
	var carry:int    = 0
	var result:Array = []
	for mod in val:
		var line:Array = core.valArray(0, 11)
		for i in SRANGE:
			line[i] = mod[i] if i < mod.size() else carry
			carry   = mod[i] if i < mod.size() else carry
		result.push_back(line)
	return result

func loaderWeaponBonus(val):
	if val == null: return null
	else:
		var result = {}
		for i in ['WRD','DUR','ATK','DEF','ETK','EDF','AGI','LUC','CRI','OVR','GEM']:
			if i in val:
				result[i] = loaderSkillArray(val[i])
		for i in core.stats.ELEMENT_MOD_TABLE:
			if i in val:
				result[i] = loaderSkillArray(val[i])
		return result

func loaderTID2(val):
	if val == null: return null
	else:           return core.tid.from(val)

func loaderBodyBonus(val):
	if val == null: return null
	else:
		var result = {}
		for i in ['MHP','MEP','ATK','DEF','ETK','EDF','AGI','LUC','CRI','OVR','GEM']:
			if i in val:
				result[i] = int(val[i])
		for i in core.stats.ELEMENT_MOD_TABLE:
			if i in val:
				result[i] = loaderSkillArray(val[i])
		return result
