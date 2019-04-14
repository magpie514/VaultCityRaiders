extends "res://classes/library/lib_base.gd"

var skill = core.skill
const LIBEXT_SKILL_CODE = "loaderSkillCode"
const LIBEXT_SKILL_FILTEREX_ARG = "loaderSkillFilterEXArg"
const LIBEXT_SKILL_MESSAGES = "loaderMessages"
const LIBEXT_EFFECT_STATBONUS = "loaderEffectStatBonus"
const LIBEXT_SKILL_LINK = "loaderSkillLink"
const LIBEXT_ANIM = "loaderAnim"

var example = {
	"core" : {
		"defend" : {
			name = "Defend",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			energyDMG = false,
			damageStat = core.stats.STAT.ATK,
			modStat = core.stats.STAT.LUC,
			inflict = skill.STATUS_NONE,
			effect = skill.EFFECT_NONE,
			effectType = 0,
			effectStats = 0,
			effectStatBonus = null,
			effectDuration = [000, 000, 000, 000, 000,   000, 000, 000, 000, 000],
			effectPriority = 0,
			filter = skill.FILTER_ALIVE,
			ranged = true,
			levels = 10,
			accMod = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = [300, 200, 200, 200, 200,   200, 200, 200, 200, 200],
			AD = [050, 049, 048, 047, 046,   045, 044, 043, 042, 041],
			codeMN = [
				["printmsg", 001, 002, 002, 002, 002,   002, 002, 002, 002, 002],
			],
			codePR = null,
			messages = [
				["%s defends!", skill.MSG_USER]
			],
		}
	},
	"story" : {
		"plasfeld": {
			name = "Plasma Field",
			description = "Emit a plasma wave that charges the field with electricity.",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_ELEC,
			effect = skill.EFFECT_SPECIAL,
			effectType = skill.EFFTYPE_BUFF,
			effectIfActive = skill.EFFCOLL_REFRESH,
			effectDuration = 3,
			effectPriority = 3,
			ranged = true,
			accMod =	[100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[005, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = 			[100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeEF = [
				["ef_push",   000, 033, 033, 033, 033,   033, 033, 033, 033, 033],
			],
		},
		"thunswrd": {
			name = "Thunder Sword",
			description = "Release a powerful energy beam using all the surrounding energy for heightened damage.",
			category = skill.CAT_ATTACK,
			type = skill.TYPE_WEAPON,
			requiresWeapon = core.skill.WPCLASS_ARTILLERY,
			target = skill.TARGET_SPREAD,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ELEC,
			fieldEffectMult = 2,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			chain = skill.CHAIN_FINISHER,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			accMod = [099,099,099,099,099,   099,099,099,099,099],
			spdMod = [085,100,100,100,100,   100,100,100,100,100],
			AD =     [095,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["get_chain",    000,000,000,000,000,   000,000,000,000,000, skill.OPFLAGS_TARGET_SELF],
				["mul",          010,000,000,000,000,   000,000,000,000,000],
				["dmgbonus",     000,000,000,000,000,   000,000,000,000,000, skill.OPFLAGS_USE_SVAL],
				["attack"       ,150,125,132,132,140,   140,147,147,147,160],
				["ef_consume"   ,006,004,004,004,004,   004,004,004,004,004],
			],
		},
	},
	"sto_wp" : {
		"sever": {
			name = "Sever",
			description = "Fires a laser beam with high accuracy. If it hits, the target receives additional piercing damage.",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ELEC,
			fieldEffectMult = 2,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			chain = skill.CHAIN_STARTER_AND_FOLLOW,
			ranged = true,
			accMod = [100,099,099,099,099,   099,099,099,099,099],
			spdMod = [100,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"       ,100,125,132,132,140,   140,147,147,147,160],
			],
		},
		"orbishld" : {
			name = "ORBITAL Shield",
			description = "Protects a party member with a powerful shield.",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SINGLE_NOT_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			effect = skill.EFFECT_SPECIAL,
			effectType = skill.EFFTYPE_BUFF,
			effectStats = skill.EffectStat.EFFSTAT_NONE,
			effectDuration = [003, 003, 000, 000, 000,   000, 000, 000, 000, 000],
			effectPriority = 1,
			accMod = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = [300, 180, 180, 180, 180,   200, 200, 200, 200, 200],
			AD = [050, 048, 046, 044, 042,   038, 036, 034, 032, 030],
			codeEF = [
				["protect",         100,013,016,019,022,  030,032,035,037,040],
				["if_synergy",      001,001,001,001,001,  001,001,001,001,001, skill.OPFLAGS_BLOCK_START|skill.OPFLAGS_TARGET_SELF],
				["counter_max",     002,001,001,001,001,  001,001,001,001,001],
				["counter_dec",     000,001,001,001,001,  001,001,001,001,001],
				["counter_set",     100,001,001,001,001,  001,001,001,001,001, skill.OPFLAGS_TARGET_SELF],
			],
			codeFL = [
				["element",         006,013,016,019,022,  030,032,035,037,040],
				["attack", 					060,013,016,019,022,  030,032,035,037,040],
			],
			synergy = [["story", "plasfeld"]],
		}
	},
	"gem" : {
		"firewave": {
			name = "Fire Wave",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_FIRE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			codeMN = [
				["attack", 060, 063, 065, 068, 075,   078, 080, 083, 086, 090],
			],
		},
		"cryoblst": {
			name = "Cryoblast",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ICE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			codeMN = [
				["attack", 060, 063, 065, 068, 075,   078, 080, 083, 086, 090],
			],
		},
		"eleburst": {
			name = "Electroburst",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ELEC,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			codeMN = [
				["attack", 060, 063, 065, 068, 075,   078, 080, 083, 086, 090],
			],
		},
		"galeblde": {
			name = "Gale Blade",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			codeMN = [
				["attack", 060, 063, 065, 068, 075,   078, 080, 083, 086, 090],
			],
		},
		"slash": {
			name = "Slash",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			energyDMG = false,
			damageStat = core.stats.STAT.ATK,
			ranged = false,
			codeMN = [
				["attack", 060, 063, 065, 068, 075,   078, 080, 083, 086, 090],
			],
		},
		"aquabrst": {
			name = "Aqua Impact",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_BLUNT,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			codeMN = [
				["attack", 060, 063, 065, 068, 075,   078, 080, 083, 086, 090],
			],
		},
		"smash": {
			name = "Smash",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_BLUNT,
			energyDMG = false,
			damageStat = core.stats.STAT.ATK,
			ranged = false,
			codeMN = [
				["attack", 060, 063, 065, 068, 075,   078, 080, 083, 086, 090],
			],
		},
		"gemspear": {
			name = "Gem Spear",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			codeMN = [
				["attack", 060, 063, 065, 068, 075,   078, 080, 083, 086, 090],
			],
		},
		"perfrate": {
			name = "Perforate",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			energyDMG = false,
			damageStat = core.stats.STAT.ATK,
			ranged = false,
			codeMN = [
				["attack", 060, 063, 065, 068, 075,   078, 080, 083, 086, 090],
			],
		},
		"destroy": {
			name = "Destroy",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ULTIMATE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			codeMN = [
				["attack", 060, 063, 065, 068, 075,   078, 080, 083, 086, 090],
			],
		},
		"revitlze": {
			name = "Revitalize",
			description = "",
			animations = "/nodes/FX/basic_heal.tscn",
			animFlags = skill.ANIMFLAGS_COLOR_FROM_ELEMENT,
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			energyDMG = true,
			damageStat = core.stats.STAT.EDF,
			ranged = true,
			codeMN = [
				["heal_raw_bonus", 020,023,025,028,075,   078,080,083,086,090],
				["heal",           060,063,065,068,075,   078,080,083,086,090],
			],
		},
		"drshield": {
			name = "Dragon Shield",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			energyDMG = true,
			damageStat = core.stats.STAT.EDF,
			ranged = true,
			spdMod = [135, 135, 135, 135, 135,   135, 135, 135, 135, 135],
			codeMN = [
				["guard", 025, 025, 025, 025, 025,   025, 025, 025, 025, 025, skill.OPFLAGS_VALUE_PERCENT],
				["guard", 025, 025, 025, 025, 025,   025, 025, 025, 025, 025],
				["AD",    -15, -15, -15, -15, -15,   -15, -15, -15, -15, -15]
			],
		},
		"echo": {
			name = "Echo Burst",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			codeMN = [
				["ef_el_setdomi", 000, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				["attack"       , 050, 055, 060, 065, 075,   080, 085, 090, 095, 110],
			],
		},
	},
	"debug" : {
		"debug": {
			name = "Debug Strike",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			energyDMG = false,
			ranged = true,
			accMod = [100, 099, 099, 099, 099,   099, 099, 099, 099, 099],
			codeMN = [
				["attack", 100, 105, 110, 115, 125,   130, 135, 140, 145, 160],
			],
		},
		"bash": {
			name = "Bash",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_BLUNT,
			energyDMG = false,
			ranged = false,
			codeMN = [
				["attack", 100, 105, 110, 115, 125,   130, 135, 140, 145, 160],
			],
		},
		"slash": {
			name = "Slash",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			energyDMG = false,
			ranged = false,
			codeMN = [
				["attack", 100, 105, 110, 115, 125,   130, 135, 140, 145, 160],
			],
		},
		"fireslsh": {
			name = "Burning Slash",
			displayElement = [1, 4],
			description = "",
			costWP = 5,
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			energyDMG = false,
			ranged = false,
			codeMN = [
				["attack", 040, 105, 110, 115, 125,   130, 135, 140, 145, 160, skill.OPFLAGS_SILENT_ATTACK],
				["element", 004, 105, 110, 115, 125,   130, 135, 140, 145, 160],
				["attack", 060, 105, 110, 115, 125,   130, 135, 140, 145, 160],
			],
		},
		"shckstab": {
			name = "Shock Stab",
			description = "",
			displayElement = [2, 6],
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			energyDMG = false,
			ranged = false,
			inflict = skill.STATUS_PARA,
			codeMN = [
				["attack", 040, 105, 110, 115, 125,   130, 135, 140, 145, 160],
				["element", 006, 105, 110, 115, 125,   130, 135, 140, 145, 160],
				["inflict", 025, 035, 035, 040, 040,   050, 050, 050, 055, 060],
				["attack", 050, 105, 110, 115, 125,   130, 135, 140, 145, 160],
			],
		},

		"stab": {
			name = "Stab",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			energyDMG = false,
			ranged = false,
			codeMN = [
				["attack", 100, 105, 110, 115, 125,   130, 135, 140, 145, 160],
			],
		},
		"shoot": {
			name = "Shoot",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			energyDMG = false,
			ranged = true,
			codeMN = [
				["attack", 100, 105, 110, 115, 125,   130, 135, 140, 145, 160],
			],
		},
		"elemshot": {
			name = "Elemental Shot",
			description = "",
			category = skill.CAT_ATTACK,
			type = skill.TYPE_WEAPON,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			energyDMG = false,
			ranged = true,
			codeMN = [
				["ef_el_setdomi", 0, 0, 0, 0, 0,  0, 0, 0, 0, 0],
				["attack", 100, 105, 110, 115, 125,   130, 135, 140, 145, 160],
				["ef_consume", 0, 0, 0, 0, 0,  0, 0, 0, 0, 0],
				["ef_replace", 0, 0, 0, 0, 0,  0, 0, 0, 0, 0],
			],
		},
		"sprshot": {
			name = "Spread Shot",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_ROW,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			energyDMG = false,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			accMod = [085, 099, 099, 099, 099,   099, 099, 099, 099, 099],
			spdMod = [065, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [105, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["attack", 075, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
		},
		"debugi": {
			name = "Debug Blast",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			levels = 10,
			codeMN = [
				["attack", 100, 105, 110, 115, 125,   130, 135, 140, 145, 160],
			],
		},
		"debugi2": {
			name = "Debug Blast 2",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SPREAD,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			levels = 10,
			codeMN = [
				["attack", 100, 105, 110, 115, 125,   130, 135, 140, 145, 160],
			],
		},
		"heal": {
			name = "Heal",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ALLY,
			ranged = true,
			accMod = [100, 099, 099, 099, 099,   099, 099, 099, 099, 099],
			spdMod = [080, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [105, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["heal", 125, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
		},
		"rowheal": {
			name = "Row Heal",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_ROW,
			targetGroup = skill.TARGET_GROUP_ALLY,
			ranged = true,
			accMod = [100, 099, 099, 099, 099,   099, 099, 099, 099, 099],
			spdMod = [080, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [105, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["heal", 125, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
		},
		"prtyheal": {
			name = "Party Heal",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_ALL,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			energyDMG = false,
			damageStat = core.stats.STAT.ATK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			levels = 10,
			accMod = [100, 099, 099, 099, 099,   099, 099, 099, 099, 099],
			spdMod = [075, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [105, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["heal", 080, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
		},
		"srnauror": {
			name = "Serene Winds",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_ALL,
			fieldEffectMult = 2,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_CUT,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			levels = 10,
			spdMod = [075, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [105, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeST = [
				["ef_replace2", 015, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			],
			codeMN = [
				["heal", 080, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
		},
		"restshrd": {
			name = "Restoration Shard",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_ROW,
			fieldEffectMult = 2,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_ELEC,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			levels = 10,
			spdMod = [075,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codePR = [
				["ef_replace2",   005,100,100,100,100,  100,100,100,100,100],
			],
			codeMN = [
				["heal",          080,125,132,132,140,  140,147,147,147,160],
				["if_ef_bonus>=", 005,125,132,132,140,  140,147,147,147,160, skill.OPFLAGS_QUIT_ON_FALSE],
				["heal",          080,125,132,132,140,  140,147,147,147,160],
			],
		},
		"potion": {
			name = "Healing Potion",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ALLY,
			ranged = true,
			codeMN = [
				["heal", 075, 125, 132, 132, 140,   140, 147, 147, 147, 160, skill.OPFLAGS_VALUE_ABSOLUTE],
			],
		},
		"illusion": {
			name = "Illusion",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_ALL,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			inflict = skill.STATUS_PARA,
			inflictPow = [120, 105, 110, 115, 125,   130, 135, 140, 145, 160],
			ranged = true,
			accMod = [095, 099, 099, 099, 099,   099, 099, 099, 099, 099],
			spdMod = [080, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [090, 095, 095, 095, 095,   090, 090, 090, 090, 090],
			codeMN = [
				["attack", 015, 080, 080, 080, 090,   090, 090, 090, 090, 100],
			],
		},
		"barricad": {
			name = "Barricade",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			effect = skill.EFFECT_STATS,
			effectType = skill.EFFTYPE_BUFF,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT,
			effectStatBonus = {
				EFFSTAT_BASEMULT = {
					DEF = [020, 000, 000, 000, 000,   000, 000, 000, 000, 000],
					AGI = [-50, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				}
			},
			effectDuration = [003, 003, 000, 000, 000,   000, 000, 000, 000, 000],
			effectPriority = 1,
			accMod = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = [150, 180, 180, 180, 180,   200, 200, 200, 200, 200],
			AD = [050, 048, 046, 044, 042,   038, 036, 034, 032, 030],
			codeMN = [
				["guard", 012, 013, 016, 019, 022,   030, 032, 035, 037, 040, skill.OPFLAGS_VALUE_PERCENT],
			],
			messages = null,
		},
		"solidbun": {
			name = "Solid Bunker",
			description = "",
			category = skill.CAT_SUPPORT,
			type = skill.TYPE_WEAPON,
			requiresWeapon = 1,
			target = skill.TARGET_ROW,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_BLUNT,
			effect = skill.EFFECT_STATS,
			effectIfActive = skill.EFFCOLL_ADD,
			effectType = skill.EFFTYPE_BUFF,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT|skill.EffectStat.EFFSTAT_RES,
			effectStatBonus = {
				EFFSTAT_BASEMULT = {
					DEF = [120, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
				EFFSTAT_RES = {
					DMG_KINETIC =	[-30, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
			},
			effectDuration = [000, 002, 002, 002, 003,   003, 003, 003, 003, 004],
			effectPriority = 0,
			AD = 			[110, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[150, 100, 100, 100, 100,   100, 100, 100, 100, 100],
		},
		"nrgshild": {
			name = "Energy Shield",
			description = "",
			category = skill.CAT_SUPPORT,
			type = skill.TYPE_BODY,
			target = skill.TARGET_ROW,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_ULTIMATE,
			effect = skill.EFFECT_STATS,
			effectIfActive = skill.EFFCOLL_ADD,
			effectType = skill.EFFTYPE_BUFF,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT|skill.EffectStat.EFFSTAT_RES,
			effectStatBonus = {
				EFFSTAT_BASEMULT = {
					EDF = [120, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
				EFFSTAT_RES = {
					DMG_ENERGY =	[-30, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
			},
			effectDuration = [000, 002, 002, 002, 003,   003, 003, 003, 003, 004],
			effectPriority = 0,
			AD = 			[110, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[150, 100, 100, 100, 100,   100, 100, 100, 100, 100],
		},
		"decoy": {
			name = "Decoy",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			effect = skill.EFFECT_STATS,
			effectType = skill.EFFTYPE_BUFF,
			effectStats = skill.EffectStat.EFFSTAT_DECOY,
			effectStatBonus = {
				EFFSTAT_DECOY = [100, 000, 000, 000, 000,   000, 000, 000, 000, 000],
			},
			effectDuration = [001, 000, 000, 000, 000,   000, 000, 000, 000, 000],
			effectPriority = 1,
			spdMod = [180, 180, 180, 180, 180,   200, 200, 200, 200, 200],
			AD = [050, 048, 046, 044, 042,   038, 036, 034, 032, 030],
			codeMN = [
				["guard", 010, 013, 016, 019, 022,   030, 032, 035, 037, 040, skill.OPFLAGS_VALUE_PERCENT],
			],
			messages = null,
		},
		"trikshot": {
			name = "Trick Shot",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			energyDMG = false,
			damageStat = core.stats.STAT.ATK,
			ranged = true,
			accMod = [095, 099, 099, 099, 099,   099, 099, 099, 099, 099],
			spdMod = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD =     [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["if_status",		000, 125, 132, 132, 140,   140, 147, 147, 147, 160],
				["dmgbonus",		095, 125, 132, 132, 140,   140, 147, 147, 147, 160],
				["attack",			065, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
			codePR = [
				["printmsg", 001, 002, 002, 002, 002,   002, 002, 002, 002, 002],
				["wait", 100, 002, 002, 002, 002,   002, 002, 002, 002, 002],
			],
			messages = [
				["%s takes aim!", skill.MSG_USER],
			],
		},
		"focushot": {
			name = "Focus Shot",
			description = "Marks an enemy for a combo sequence.",
			category = skill.CAT_ATTACK,
			type = skill.TYPE_WEAPON,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			energyDMG = false,
			damageStat = core.stats.STAT.ATK,
			ranged = true,
			spdMod = [150, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD =     [110, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["attack",			045, 125, 132, 132, 140,   140, 147, 147, 147, 160],
				["if_connect",  000, 000, 000, 000, 000,   000, 000, 000, 000, 000, skill.OPFLAGS_QUIT_ON_FALSE],
				["combo_dec",  035, 125, 132, 132, 140,   140, 147, 147, 147, 160],
				["combo_set",  100, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
			codeFL = [
				["attack",			045, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			]
		},
		"gmissile": {
			name = "G-Crystal Missile",
			description = "",
			displayElement = [2, 7],
			category = skill.CAT_ATTACK,
			target = skill.TARGET_ROW,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			ranged = true,
			effect = skill.EFFECT_STATS|skill.EFFECT_ONEND,
			effectType = skill.EFFTYPE_DEBUFF,
			effectIfActive = skill.EFFCOLL_FAIL,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT|skill.EffectStat.EFFSTAT_RES,
			effectStatBonus = {
				EFFSTAT_RES = {
					DMG_ULTIMATE =	[030,000,000,000,000,   000,000,000,000,000],
				},
				EFFSTAT_BASEMULT = {
					AGI = [-20,000,000,000,000,   000,000,000,000,000],
				},
			},
			effectDuration = [002,003,003,003,004,   004,004,004,004,005],
			effectPriority = 3,
			accMod = [099, 099, 099, 099, 099,   099, 099, 099, 099, 099],
			spdMod = [080, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD =     [095, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["element",     007,007,007,007,007,   007,007,007,007,007],
				["attack",		  045,125,132,132,140,   140,147,147,147,160],
			],
			codeED = [
				["playanim",    001,001,001,001,001,   001,001,001,001,001],
				["printmsg",    001,001,001,001,001,   001,001,001,001,001],
				["element",     007,007,007,007,007,   007,007,007,007,007],
				["ef_replace2", 015,015,015,015,015,   015,015,015,015,015],
				["attack",		  035,125,132,132,140,   140,147,147,147,160],
			],
			messages = [
				["Crystals detonate inside %s!", skill.MSG_TARGET],
			],
		},
		"hyprshot": {
			name = "Gateway Shot",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			energyDMG = false,
			damageStat = core.stats.STAT.ATK,
			ranged = true,
			spdMod = [090,100,100,100,100,   100,100,100,100,100],
			AD =     [090,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["if_chance", 020,125,132,132,140,   140,147,147,147,160, skill.OPFLAGS_BLOCK_START],
				["printmsg",  002,002,002,002,002,   002,002,002,002,002],
				["element",   007,002,002,002,002,   002,002,002,002,002],
				["attack",    220,125,132,132,140,   140,147,147,147,160, skill.OPFLAGS_BLOCK_END],
				["attack",    080,125,132,132,140,   140,147,147,147,160],
			],
			messages = [
				["%s focuses!", skill.MSG_USER],
				["%s breaks in!", skill.MSG_USER]
			],
		},
		"wideslsh": {
			name = "Wide Slash",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SPREAD,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			energyDMG = false,
			damageStat = core.stats.STAT.ATK,
			modStat = core.stats.STAT.LUC,
			ranged = false,
			spdMod = [095, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [105, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["attack", 105, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
		},
		"firebrst": {
			name = "Fire Burst",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SPREAD,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_FIRE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			spdMod = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["attack", 100, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
		},
		"vampdran": {
			name = "Vampiric Drain",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ULTIMATE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			spdMod = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["drainlife", 100, 125, 132, 132, 140,   140, 147, 147, 147, 160],
				["attack", 100, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
		},
		"overclck": {
			name = "Overclock",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_FIRE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			effect = skill.EFFECT_STATS|skill.EFFECT_ONEND,
			effectType = skill.EFFTYPE_BUFF,
			effectIfActive = skill.EFFCOLL_NULLIFY,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT|skill.EffectStat.EFFSTAT_OFF,
			effectStatBonus = {
				EFFSTAT_OFF = {
					DMG_FIRE =	[030, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
				EFFSTAT_BASEMULT = {
					ATK = [020, 000, 000, 000, 000,   000, 000, 000, 000, 000],
					ETK = [020, 000, 000, 000, 000,   000, 000, 000, 000, 000],
					AGI = [020, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
			},
			effectDuration = 2,
			effectPriority = 3,
			spdMod = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["drainlife", 100, 125, 132, 132, 140,   140, 147, 147, 147, 160],
				["attack", 100, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
			codeED = [
				["dmgraw", 050, 002, 002, 002, 002,   002, 002, 002, 002, 002, skill.OPFLAGS_VALUE_PERCENT],
			],
		},
		"lunablaz": {
			name = "Lunatic Blaze",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_ALL,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_FIRE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			spdMod = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["drainlife", 005, 125, 132, 132, 140,   140, 147, 147, 147, 160],
				["attack", 100, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
		},
		"heatngtr": {
			name = "Thermodynamic Reversal",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_ALL,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ICE,
			fieldEffectMult = 2,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			spdMod = [100,100,100,100,100,   100,100,100,100,100],
			AD =     [095,100,100,100,100,   100,100,100,100,100],
			codeST = [
				["get_ef_bonus" ,004,004,004,004,004,   004,004,004,004,004],
				["mul"          ,002,004,004,004,004,   004,004,004,004,004],
				["ef_consume"   ,004,004,004,004,004,   004,004,004,004,004],
				["ef_replace"   ,000,004,004,004,004,   004,004,004,004,004],
				["dmgbonus"     ,000,004,004,004,004,   004,004,004,004,004, skill.OPFLAGS_USE_SVAL],
			],
			codeMN = [
				["attack"       ,050,125,132,132,140,   140,147,147,147,160],
			],
		},
		"kamaita": {
			name = "Kamaitachi",
			description = "Unleashes a barrage of ice blades against the enemy. Effect is enhanced by any active Dancing Swords.",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_ROW,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ICE,
			fieldEffectMult = 2,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			accMod = [098,099,099,099,099,   099,099,099,099,099],
			spdMod = [080,100,100,100,100,   100,100,100,100,100],
			AD =     [110,100,100,100,100,   100,100,100,100,100],
			codeST = [
				["get_synergies"     ,001,004,004,004,004,   004,004,004,004,004, skill.OPFLAGS_TARGET_SELF],
				["mul"               ,015,004,004,004,004,   004,004,004,004,004],
				["cap"               ,050,004,004,004,004,   004,004,004,004,004],
				["dmgbonus"          ,000,004,004,004,004,   004,004,004,004,004, skill.OPFLAGS_USE_SVAL],
			],
			codeMN = [
				["attack"            ,080,125,132,132,140,   140,147,147,147,160],
			],
			synergy = [["debug", "dncsword"]],
		},
		"gatebrkr": {
			name = "Gate Breaker",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_ALL,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ULTIMATE,
			fieldEffectMult = 4,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			filter = skill.FILTER_ALIVE_OR_STASIS,
			ranged = true,
			accMod = [100, 099, 099, 099, 099,   099, 099, 099, 099, 099],
			spdMod = [110, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [110, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["if_synergy_party", 001,001,001,001,001,   001, 001, 001, 001, 001, skill.OPFLAGS_BLOCK_START|skill.OPFLAGS_TARGET_SELF],
				["ef_push",		       006,125,132,132,140,   140, 147, 147, 147, 160],
				["playanim",	       001,125,132,132,140,   140, 147, 147, 147, 160],
				["dmgbonus",		     015,125,132,132,140,   140, 147, 147, 147, 160, skill.OPFLAGS_BLOCK_END],
				["attack",		       085,125,132,132,140,   140, 147, 147, 147, 160],
			],
			synergy = [ ["story", "plasfeld"] ],
		},
			"selfrepr": {
			name = "System Repair",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			filter = skill.FILTER_ALIVE,
			codeMN = [
				["heal", 999, 999, 999, 999, 999,   999, 999, 999, 999, 999, skill.OPFLAGS_VALUE_ABSOLUTE],
			],
		},
		"defdown": {
			name = "Defense Down",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_ALL,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			effect = skill.EFFECT_STATS,
			effectType = skill.EFFTYPE_DEBUFF,
			effectStats = skill.EffectStat.EFFSTAT_RES,
			effectStatBonus = {
				EFFSTAT_RES = {
					DMG_KINETIC = [025, 000, 000, 000, 000,   000, 000, 000, 000, 000],
					DMG_ENERGY = [025, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
			},
			effectDuration = [002, 002, 002, 002, 003,   003, 003, 003, 003, 004],
			effectPriority = 3,
			accMod =	[075, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = 			[120, 100, 100, 100, 100,   100, 100, 100, 100, 100],
		},
		"speedup": {
			name = "Quicken",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_ROW,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_CUT,
			effect = skill.EFFECT_STATS,
			effectIfActive = skill.EFFCOLL_ADD,
			effectType = skill.EFFTYPE_BUFF,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT,
			effectStatBonus = {
				EFFSTAT_BASEMULT = {
					AGI = [150, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
			},
			effectDuration = [002, 002, 002, 002, 003,   003, 003, 003, 003, 004],
			effectPriority = 3,
			accMod =	[080, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = 			[110, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[110, 100, 100, 100, 100,   100, 100, 100, 100, 100],
		},
		"blddance": {
			name = "Blade Dance",
			description = "While active, every cut attack will follow with an additional cut.",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_CUT,
			effect = skill.EFFECT_SPECIAL,
			effectType = skill.EFFTYPE_BUFF,
			effectIfActive = skill.EFFCOLL_ADD,
			effectDuration = 3,
			effectPriority = 3,
			accMod =	[100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[005, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = 			[100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeEF = [
				["follow_dec",   033, 033, 033, 033, 033,   033, 033, 033, 033, 033],
				["follow_el",    000, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				["follow_set",   100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			],
			codeFL = [
				["if_synergy",  001, 033, 033, 033, 033,   033, 033, 033, 033, 033, skill.OPFLAGS_TARGET_SELF],
				["ef_mult",     002, 033, 033, 033, 033,   033, 033, 033, 033, 033],
				["attack",			045, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
			synergy = [["debug", "dncsword"]]
		},
		"dncsword": {
			name = "Dancing Sword",
			description = "Enchant a party member, giving it a blade of wind that follows their attacks.",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_CUT,
			effect = skill.EFFECT_SPECIAL,
			effectType = skill.EFFTYPE_BUFF,
			effectIfActive = skill.EFFCOLL_ADD,
			effectDuration = 3,
			effectPriority = 3,
			ranged = true,
			accMod =	[100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[005, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = 			[100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeEF = [
				["follow_dec",   033, 033, 033, 033, 033,   033, 033, 033, 033, 033],
				["follow_set",   100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			],
			codeFL = [
				["attack",			045, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			]
		},
			"codexalt": {
			name = "Code 「EXALT」",
			description = "The limiter in the hollow engine will be released, allowing temporary access to its full output.",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_ULTIMATE,
			effect = skill.EFFECT_STATS|skill.EFFECT_ONEND,
			effectType = skill.EFFTYPE_BUFF,
			effectIfActive = skill.EFFCOLL_NULLIFY,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT|skill.EffectStat.EFFSTAT_OFF|skill.EffectStat.EFFSTAT_RES|skill.EffectStat.EFFSTAT_EVASION,
			effectStatBonus = {
				EFFSTAT_OFF = {
					DMG_ULTIMATE =	[030, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
				EFFSTAT_RES = {
					DMG_KINETIC =	[-30, 000, 000, 000, 000,   000, 000, 000, 000, 000],
					DMG_ENERGY =	[-30, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
				EFFSTAT_BASEMULT = {
					AGI = [020, 000, 000, 000, 000,   000, 000, 000, 000, 000],
					ETK = [020, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
				EFFSTAT_EVASION = [025, 000, 000, 000, 000,   000, 000, 000, 000, 000],
			},
			effectDuration = [002, 003, 003, 003, 004,   004, 004, 004, 004, 005],
			effectPriority = 3,
			spdMod = 	[005, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = 			[100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["printmsg", 001, 002, 002, 002, 002,   002, 002, 002, 002, 002],
			],
			codeED = [
				["printmsg", 002, 002, 002, 002, 002,   002, 002, 002, 002, 002],
				["linkskill", 001, 002, 002, 002, 002,   002, 002, 002, 002, 002],
				["playanim", 001, 002, 002, 002, 002,   002, 002, 002, 002, 002],
			],
			messages = [
				["%s's limiter released!", skill.MSG_USER],
				["%s overheats!", skill.MSG_USER],
			],
			linkSkill = [
				["debug", "selfrepr"],
			],
		},
	}
}

#TODO: Modifier to healraw to use bonus healing power
#TODO: Modifier to allow attacks to bypass guard/barrier
#TODO: Chase attack setup.

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING, default = "Unnamed Skill" },
		"description" : { loader = LIBSTD_STRING, default = "Your ad here!" },
		"displayElement" : { loader = LIBSTD_VARIABLEARRAY },
		"type" : { loader = LIBSTD_INT, default = 0 },
		"category" : { loader = LIBSTD_INT },
		"costWP" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
		"costEP" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
		"costOV" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
		"requiresPart" : { loader = LIBSTD_INT, default = 0 },
		"requiresWeapon" : { loader = LIBSTD_INT, default = 0 },
		"target" : { loader = LIBSTD_SKILL_ARRAY },
		"targetGroup" : { loader = LIBSTD_INT },
		"element" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
		"energyDMG" : { loader = LIBSTD_BOOL },
		"damageStat" : { loader = LIBSTD_INT, default = core.stats.STAT.ATK },
		"modStat" : { loader = LIBSTD_INT, default = core.stats.STAT.LUC },
		"inflict" : { loader = LIBSTD_INT },
		"inflictPow" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },

		"fieldEffectMult" : { loader = LIBSTD_SKILL_ARRAY, default = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1] },
		"fieldEffectAdd" : { loader = LIBSTD_SKILL_ARRAY, default = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]},

		"effect" : { loader = LIBSTD_INT },
		"effectType" : { loader = LIBSTD_INT },
		"effectIfActive" : { loader = LIBSTD_INT },
		"effectCancel" : { loader = LIBSTD_INT },
		"effectStats" : { loader = LIBSTD_INT },
		"effectStatBonus" : { loader = LIBEXT_EFFECT_STATBONUS },
		"effectDuration" : { loader = LIBSTD_SKILL_ARRAY },
		"effectPriority" : { loader = LIBSTD_INT },

		"chargeAnim" : { loader = LIBSTD_SKILL_ARRAY, default = [0,0,0,0,0, 0,0,0,0,0] },
		"animations" : { loader = LIBEXT_ANIM, default = "/nodes/FX/basic.tscn" },
		"animFlags" : { loader = LIBSTD_SKILL_ARRAY, default = [0,0,0,0,0, 0,0,0,0,0]},

		"ranged" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
		"levels" : { loader = LIBSTD_INT, default = 10 },
		"accMod" : { loader = LIBSTD_SKILL_ARRAY, default = [090, 090, 090, 090, 090,   090, 090, 090, 090, 090] },
		"spdMod" : { loader = LIBSTD_SKILL_ARRAY, default = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100] },
		"critMod": { loader = LIBSTD_SKILL_ARRAY, default = [005, 005, 005, 005, 005,   005, 005, 005, 005, 005] },
		"AD" : { loader = LIBSTD_SKILL_ARRAY, default = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100] },
		"initAD" : { loader = LIBSTD_SKILL_ARRAY, default = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100] },
		"filter" : { loader = LIBSTD_INT },
		"messages" : { loader = LIBEXT_SKILL_MESSAGES },
		"linkSkill" : { loader = LIBSTD_SKILL_LIST },
		"synergy" : { loader = LIBSTD_SKILL_LIST },
		"chain" : {loader = LIBSTD_INT, default = core.skill.CHAIN_NONE },

		"codeST" : { loader = LIBEXT_SKILL_CODE },
		"codeMN" : { loader = LIBEXT_SKILL_CODE },
		"codeFL" : { loader = LIBEXT_SKILL_CODE },
		"codePR" : { loader = LIBEXT_SKILL_CODE },
		"codeDN" : { loader = LIBEXT_SKILL_CODE },
		"codeEF" : { loader = LIBEXT_SKILL_CODE },
		"codeEE" : { loader = LIBEXT_SKILL_CODE },
		"codeEA" : { loader = LIBEXT_SKILL_CODE },
		"codeEH" : { loader = LIBEXT_SKILL_CODE },
		"codeED" : { loader = LIBEXT_SKILL_CODE },
	}



func loadDebug():
	loadDict(example)
	print("Skill library loaded.")
	#printData()

func name(id):
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"


func loaderSkillFilterEXArg(val):
	if val == null:
		return null
	else:
		return val

func loaderSkillCode(a):
	match(typeof(a)):
		TYPE_NIL:
			return null
		TYPE_ARRAY:
			var result = core.newArray(a.size())
			var line = null
			for j in a.size():
				line = a[j]
				result[j] = core.newArray(12)
				result[j][0] = skill.translateOpCode(line[0])
				for i in range(1, 11):
					result[j][i] = int(line[i])
				if line.size() == 12:
					result[j][11] = int(line[11])
				else:
					result[j][11] = int(skill.OPFLAGS_NONE)
			return result
		_:
			return [[skill.OPCODE_NULL, 0,0,0,0,0,  0,0,0,0,0, skill.OPFLAGS_NONE]]

func loaderMessages(a):
	if a == null:
		return null
	var messages = []
	for i in range(a.size()):
		messages.push_back([str(a[i][0]), int(a[i][1])])
	return messages


func loaderEffectStatBonus(dict):
	if dict == null:
		return null
	var stats = core.stats
	var result = {}
	for key in skill.EffectStat:
		if dict.has(key):
			match key:
				"EFFSTAT_BASE":
					result.EFFSTAT_BASE = {}
					for i in stats.STATS:
						if dict.EFFSTAT_BASE.has(i):
							result.EFFSTAT_BASE[i] = loaderSkillArray(dict.EFFSTAT_BASE[i])
				"EFFSTAT_BASEMULT":
					result.EFFSTAT_BASEMULT = {}
					for i in stats.STATS:
						if dict.EFFSTAT_BASEMULT.has(i):
							result.EFFSTAT_BASEMULT[i] = loaderSkillArray(dict.EFFSTAT_BASEMULT[i])
				"EFFSTAT_OFF":
					result.EFFSTAT_OFF = {}
					for i in stats.ELEMENTS:
						if dict.EFFSTAT_OFF.has(i):
							result.EFFSTAT_OFF[i] = loaderSkillArray(dict.EFFSTAT_OFF[i])
				"EFFSTAT_RES":
					result.EFFSTAT_RES = {}
					for i in stats.ELEMENTS:
						if dict.EFFSTAT_RES.has(i):
							result.EFFSTAT_RES[i] = loaderSkillArray(dict.EFFSTAT_RES[i])
				"EFFSTAT_GUARD":
					result.EFFSTAT_GUARD = loaderSkillArray(dict.EFFSTAT_GUARD)
				"EFFSTAT_BARRIER":
					result.EFFSTAT_BARRIER = loaderSkillArray(dict.EFFSTAT_BARRIER)
				"EFFSTAT_DECOY":
					result.EFFSTAT_DECOY = loaderSkillArray(dict.EFFSTAT_DECOY)
				"EFFSTAT_DODGE":
					result.EFFSTAT_DODGE = loaderSkillArray(dict.EFFSTAT_DODGE)
				"EFFSTAT_EVASION":
					result.EFFSTAT_EVASION = loaderSkillArray(dict.EFFSTAT_EVASION)
	return result

func loaderSkillLink(val):
	return null

func loaderAnim(val):
	if val != null:
		return ["res:/%s" % str(val)]
	else:
		return [ null ]
