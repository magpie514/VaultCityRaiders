extends "res://classes/library/lib_base.gd"
###############################################################################
#[>] TODO: Modifier to healraw to use bonus healing power
#[ ] TODO: Modifier to allow attacks to bypass guard/barrier
#[v] TODO: Chase attack setup.
#[>] TODO: Elodie's Pleine-de-vie skills.
#[ ] TODO: Replace skill constants with strings, replace them on load.
#[ ] TODO: Implement lib_base logic to allow passing "translation dictionaries" so strings can be converted to ints easily.
###############################################################################
var skill = core.skill #Here as a shortcut so I just have to type "skill" for constants.
const LIBEXT_SKILL_CODE         = "loaderSkillCode"
const LIBEXT_SKILL_FILTEREX_ARG = "loaderSkillFilterEXArg"
const LIBEXT_SKILL_MESSAGES     = "loaderMessages"
const LIBEXT_EFFECT_STATBONUS   = "loaderEffectStatBonus"
const LIBEXT_SKILL_LINK         = "loaderSkillLink"
const LIBEXT_ANIM               = "loaderAnim"

var example = {
# Core skills #####################################################################################
	"core": {
		"defend" : {
			name = "Defend",
			description = "",
			animations = { 'main' : "/nodes/FX/basic_charge.tscn" },
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_UNTYPED,
			filter = skill.FILTER_ALIVE,
			ranged = true,
			levels = 10,
			accMod = [100,100,100,100,100, 100,100,100,100,100],
			spdMod = [300,200,200,200,200, 200,200,200,200,200],
			AD =     [050,049,048,047,046, 045,044,043,042,041],
			codeMN = [
				["defend",   000,000,000,000,000, 000,000,000,000,000],
			],
		},
		"defup": {
			name = "DEF up",
			description = "Raises defense.",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_CUT,
			effect = skill.EFFECT_STATS,
			effectIfActive = skill.EFFCOLL_ADD,
			effectType = skill.EFFTYPE_BUFF,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT,
			effectStatBonus = {
				EFFSTAT_BASEMULT = {
					DEF = [150, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
			},
			effectDuration = [002, 002, 002, 002, 003,   003, 003, 003, 003, 004],
			effectPriority = 3,
			accMod =	[100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = 			[100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
		},
		"accel": {
			name = "Accelerate",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_CUT,
			effect = skill.EFFECT_STATS,
			effectIfActive = skill.EFFCOLL_ADD,
			effectType = skill.EFFTYPE_BUFF,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT|skill.EffectStat.EFFSTAT_EVASION,
			effectStatBonus = {
				EFFSTAT_BASEMULT = {
					AGI = [125, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
				EFFSTAT_EVASION = [015,025,025,025,025, 025,025,025,025,025],
			},
			effectDuration = [002, 002, 002, 002, 003,   003, 003, 003, 003, 004],
			effectPriority = 3,
			accMod =	[080, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = 			[110, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[110, 100, 100, 100, 100,   100, 100, 100, 100, 100],
		},
	},
# Story mode skills ###############################################################################
	"story": {
# Jay's skills ####################################################################################
		"plasfeld": {
			name = "EPN Field",
			description = "Extends an Energy Particle Negation field, charging the field with electricity and may prevent enemies from modifying the field.",
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
		"overred": {
			name = "Over Red",
			description = "Force-feeds a powerful burst of Over into a generator, causing it to exceed its limitations. This reaction completely negates conventional physics.",
			category = skill.CAT_OVER,
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
		"overblue": {
			name = "Over Blue",
			description = "Completely overloads a generator with Over. The ensuing reaction shatters all reason, and all resulting energy will bend to the user's will.",
			category = skill.CAT_OVER,
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
			animations = { 'main' : "/nodes/FX/basic_charge.tscn", 'startup' : "/nodes/FX/basic_startup.tscn" },
			chargeAnim = true,
			costOV = 100,
			category = skill.CAT_OVER,
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
				["get_chain",    skill.OPFLAGS_TARGET_SELF],
				["mul",          010,000,000,000,000,   000,000,000,000,000],
				["dmgbonus",     000,000,000,000,000,   000,000,000,000,000, skill.OPFLAGS_USE_SVAL],
				["attack"       ,150,125,132,132,140,   140,147,147,147,160],
				["ef_consume"   ,006,004,004,004,004,   004,004,004,004,004],
			],
		},
		"freerang": {
			name = "Free Range",
			description = "Fire a cluster of seeking missiles with high accuracy.",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SPREAD,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_STRIKE,
			energyDMG = false,
			damageStat = core.stats.STAT.ETK,
			chain = skill.CHAIN_STARTER,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			accMod = [110,110,110,099,099,   099,099,099,099,099],
			spdMod = [085,100,100,100,100,   100,100,100,100,100],
			AD =     [095,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"       ,110,125,132,132,140,   140,147,147,147,160],
			],
		},
# Magpie's skills #################################################################################
		"gravrefl": {
			name = "Graviton Reflow",
			description = "Uses G-Crystal graviton reflow to increase a row's EDF and energy resistance.",
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
			AD = 			[115, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[150, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["if_ef_bonus>=",  001,000,000,000,000,   000,000,000,000,000, skill.OPFLAGS_BLOCK_START],
					["guard",          010,000,000,000,000,   000,000,000,000,000, skill.OPFLAGS_VALUE_PERCENT],
			],
			codePO = [
				["if_ef_bonus>=",  001,000,000,000,000,   000,000,000,000,000],
					["ef_take",        001,000,000,000,000,   000,000,000,000,000],
			]
		},
		"gemshrap": {
			name = "Gem Shrapnel",
			description = "While active, every cut attack will follow with an additional pierce.",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
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
				["follow_el",    001, 001, 001, 000, 000,   000, 000, 000, 000, 000],
				["follow_set",   100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			],
			codeFL = [
				["if_synergy",  001, 033, 033, 033, 033,   033, 033, 033, 033, 033, skill.OPFLAGS_TARGET_SELF],
					["ef_mult",     200, 033, 033, 033, 033,   033, 033, 033, 033, 033],
				["attack",			045, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
			synergy = [["debug", "dncsword"]]
		},
		"spirbost": {
			name = "Spiral Boost",
			description = "Flies at an enemy, using teleportation to dodge incoming attacks. Successful dodges improve damage. The further away the enemy is, the more time it'll take to reach.",
			category = skill.CAT_ATTACK,
			type = skill.TYPE_WEAPON,
			requiresWeapon = skill.WPCLASS_POLEARM,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			energyDMG = false,
			ranged = true,
			spdMod = 	[075,100,100,100,100, 100,100,100,100,100],
			initAD =  [095,095,095,095,095, 090,090,090,090,090],
			AD = 			[125,100,100,100,100, 100,100,100,100,100],
			codePR = [
				["decoy",       100,100,100,100,100,  100,100,100,100,100],
				["dodge",       100,100,100,100,100,  100,100,100,100,100],
				["get_range",   000,000,000,000,000,  000,000,000,000,000],
				["mul",         010,000,000,000,000,  000,000,000,000,000],
				["subi",        100,000,000,000,000,  000,000,000,000,000],
				["agi_mod",     000,000,000,000,000,  000,000,000,000,000, skill.OPFLAGS_VALUE_PERCENT|skill.OPFLAGS_USE_SVAL]
			],
			codeMN = [
				["if_synergy",  001,033,033,033,033,  033,033,033,033,033, skill.OPFLAGS_TARGET_SELF],
				["ef_mult",     240,240,240,240,240,  240,240,240,240,240],
				["get_dodges",  000,000,000,000,000,  000,000,000,000,000, skill.OPFLAGS_TARGET_SELF],
				["mul",         035,035,035,035,035,  035,035,035,035,035],
				["add",         100,100,100,100,100,  100,100,100,100,100],
				["attack",			000,000,000,000,000,  000,000,000,000,000, skill.OPFLAGS_USE_SVAL],
			],
			synergy = [["debug", "dncsword"]]
		},
		"gateslsh": { #Obtained during Fantôme fight in story mode. TODO: Set dummy aclass for character progress in story mode.
			name = "Gate Slasher",
			description = "Powerful slashing technique utilizing the power of the G-Crystal. It's impossible to defend against this attack. ",
			category = skill.CAT_OVER,
			type = skill.TYPE_WEAPON,
			requiresWeapon = skill.WPCLASS_POLEARM,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ULTIMATE,
			energyDMG = true,
			ranged = true,
			spdMod = 	[075,100,100,100,100, 100,100,100,100,100],
			initAD =  [095,095,095,095,095, 090,090,090,090,090],
			AD = 			[125,100,100,100,100, 100,100,100,100,100],
			codeMN = [
				["nomiss",      001],
				["attack",			200,000,000,000,000,  000,000,000,000,000],
			],
			synergy = [["debug", "dncsword"]]
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
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT,
			effectStatBonus = {
				EFFSTAT_BASEMULT = {
					AGI =     [-20,000,000,000,000,   000,000,000,000,000],
					RES_ULT = [030,000,000,000,000,   000,000,000,000,000],
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
				"Crystals detonate inside {TARGET}!",
			],
		},
		"gatebrkr": {
			name = "Gate Breaker",
			description = "Discharges the G-Crystal particles used for dimensional scanning as a burst of energy.",
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
		"codexalt": {
			name = "Code 「EXALT」",
			description = "Releases limiters on the Hollow Engine, allowing temporary access to its full output.",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_ULTIMATE,
			effect = skill.EFFECT_STATS|skill.EFFECT_ONEND,
			effectType = skill.EFFTYPE_BUFF,
			effectIfActive = skill.EFFCOLL_NULLIFY,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT|skill.EffectStat.EFFSTAT_BASE|skill.EffectStat.EFFSTAT_EVASION,
			effectStatBonus = {
				EFFSTAT_BASEMULT = {
					AGI = [020, 000, 000, 000, 000,   000, 000, 000, 000, 000],
					ETK = [020, 000, 000, 000, 000,   000, 000, 000, 000, 000],
				},
				EFFSTAT_BASE = {
					RES_KIN = [-30, 000, 000, 000, 000,   000, 000, 000, 000, 000],
					RES_ENE = [-30, 000, 000, 000, 000,   000, 000, 000, 000, 000],
					OFF_ULT = [030, 000, 000, 000, 000,   000, 000, 000, 000, 000],
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
				"{USER}'s limiter released!",
				"{USER}'s engine overheats!",
			],
			linkSkill = [
				["debug", "selfrepr"],
			],
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
		"gdomini": { #Obtained during King Solarica fight in story mode.
			#TODO: Battle conditions should be able to override a skill based on event settings to allow
			#this attack to have different effects when used in certain battles, or by enemies
			#like King Solarica or Milennium.
			#The regular effect is: Enemy will be unable to act for a turn, and all your characters get
			#a free shot with a boost to Over. At the end of the turn, all enemies are hit by a strong
			#gravity damage blast that ignores defense.
			name = "G-Dominion",
			description = "Unleashes the full power of the G-Crystal. All targets will be sent to an isolated dimension, shaped by the user's will. It can bring unimaginable ruin without destroying the host universe. No enemy can withstand this attack.",
			category = skill.CAT_OVER,
			target = skill.TARGET_ALL,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ULTIMATE,
			energyDMG = true,
			ranged = true,
			spdMod = 	[075,100,100,100,100, 100,100,100,100,100],
			initAD =  [095,095,095,095,095, 090,090,090,090,090],
			AD = 			[125,100,100,100,100, 100,100,100,100,100],
			codeMN = [
				["attack",			200,000,000,000,000,  000,000,000,000,000],
			],
		},
# Anna's skills ###################################################################################
		"savaripp": {
			name = "Savage Ripper",
			description = "Slashes at a single target. If current weapon is out of durability, the slash is much stronger. A last resort.",
			category = skill.CAT_OVER,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_FIRE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			spdMod = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			AD = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeST = [
				["get_weapon_dur"],
				["if_sval<=", 1, skill.OPFLAGS_BLOCK_START],
					["drainlife", 025,125,132,132,140, 140,147,147,147,160],
					["dmgbonus", 100, skill.OPFLAGS_BLOCK_END],
			],
			codeMN = [
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
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT,
			effectStatBonus = {
				EFFSTAT_BASEMULT = {
					ATK =     [020,000,000,000,000, 000,000,000,000,000],
					ETK =     [020,000,000,000,000, 000,000,000,000,000],
					AGI =     [020,000,000,000,000, 000,000,000,000,000],
					OFF_FIR = [030,000,000,000,000, 000,000,000,000,000],
				},
			},
			effectDuration = 2,
			effectPriority = 3,
			spdMod = [100,100,100,100,100,  100,100,100,100,100],
			AD = [100,100,100,100,100,  100,100,100,100,100],
			codeMN = [
				["drainlife", 100,125,132,132,140, 140,147,147,147,160],
				["attack",    100,125,132,132,140, 140,147,147,147,160],
			],
			codeED = [
				["dmgraw", 050, 002, 002, 002, 002,   002, 002, 002, 002, 002, skill.OPFLAGS_VALUE_PERCENT],
			],
		},
		"lunablaz": {
			name = "Lunatic Blaze",
			description = "Uses a temporal distortion to fuel a massive blaze, but can call anomalies from the brink of time if interrupted during charge.\nA risky move.",
			animations = {'main': "/nodes/FX/basic_charge.tscn", 'startup' : "/nodes/FX/basic_startup2.tscn", 1: "/nodes/FX/basic_charge.tscn"},
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_ALL,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_FIRE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			fieldEffectMult = 2,
			fieldEffectAdd = 2,
			targetBlacklist = [["story", "lunablaz"]],
			ranged = true,
			chargeAnim = true,
			spdMod = [001, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			initAD = [025,025,100, 100, 100,   100, 100, 100, 100, 100],
			AD = [100, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["dmg_raw_bonus", 030,125,132,132,140,   140,147,147,147,160],
				["drainlife", 015, 125, 132, 132, 140,   140, 147, 147, 147, 160],
				["attack", 400,125,132,132,140,   140,147,147,147,160],
			],
			codePR = [
				["counter_max", 002,002,002,002,002,   140,147,147,147,160],
				["counter_dec", 000,002,002,002,002,   140,147,147,147,160],
				["counter_set", 100,002,002,002,002,   140,147,147,147,160],
				["decoy",       100,002,002,002,002,   140,147,147,147,160],
			],
			codeFL = [
				["playanim",    001,002,002,002,002,   140,147,147,147,160],
				["ef_push",     000,002,002,002,002,   140,147,147,147,160],
				["enemy_summon",001,002,002,002,002,   140,147,147,147,160],
				["attack",      020,002,002,002,002,   140,147,147,147,160],
			],
			summons = [
				{ tid=["story", "lunablaz"], amount = 2, msg="{name} burst forth!", failmsg="" },
				{ tid=["story", "lunablaz"], amount = 1, msg="{name} burst forth!", failmsg="" },
			],
		},
# Yukiko's skills #################################################################################
		"borealsf": {
			name = "Boreal Shift",
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
	},
# Enemy exclusive skills ##########################################################################
	"enemy": {
		"repair": {
			name = "Repair",
			description = "",
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			energyDMG = true,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			accMod = [100,099,099,099,099,   099,099,099,099,099],
			spdMod = [080,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["enemy_revive" ,100,125,132,132,140, 140,147,147,147,160],
			],
		},
	},
# Story weapon skills #############################################################################
	"sto_wp": {
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
			effectDuration = [003,003,000,000,000, 000,000,000,000,000],
			effectPriority = 1,
			accMod = [100,100,100,100,100, 100,100,100,100,100],
			spdMod = [300,180,180,180,180, 200,200,200,200,200],
			AD = [050,048,046,044,042, 038,036,034,032,030],
			codeEF = [
				["protect",         100,013,016,019,022,  030,032,035,037,040],
				["if_synergy",      001,001,001,001,001,  001,001,001,001,001, skill.OPFLAGS_BLOCK_START|skill.OPFLAGS_TARGET_SELF],
				["counter_max",     002,001,001,001,001,  001,001,001,001,001],
				["counter_dec",     000,001,001,001,001,  001,001,001,001,001],
				["counter_set",     100,001,001,001,001,  001,001,001,001,001, skill.OPFLAGS_TARGET_SELF],
			],
			codeFL = [
				["chain_follow",    001,001,001,001,001,  001,001,001,001,002, skill.OPFLAGS_TARGET_SELF],
				["element",         006,013,016,019,022,  030,032,035,037,040],
				["attack", 					060,013,016,019,022,  030,032,035,037,040],
			],
			synergy = [["story", "plasfeld"]],
		},
		"dualshrs": {
			name = "Dual Shears",
			description = "Powerful cutting attack. Gets its field bonuses from the Strike element.",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			fieldEffectMult = 2,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			chain = skill.CHAIN_FOLLOW,
			ranged = false,
			accMod = [100,099,099,099,099,   099,099,099,099,099],
			spdMod = [100,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"       ,100,125,132,132,140,   140,147,147,147,160],
			],
		},
		"thoukniv": {
			name = "Thousand Knives",
			description = "Uses maximum speed to deliver a powerful sequence of slashes. Gets its field bonuses from the Strike element.",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			fieldEffectMult = 2,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			chain = skill.CHAIN_FINISHER,
			ranged = true,
			accMod = [100,099,099,099,099,   099,099,099,099,099],
			spdMod = [100,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"       ,100,125,132,132,140,   140,147,147,147,160],
			],
		},
		"lighflam": {
			name = "Lightning Flamberge",
			description = "Extends the beam of the FOMALHAUT Blade to a massive size, then slashes at everything in sight.",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_ALL,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ELEC,
			fieldEffectMult = 2,
			costOV = core.skill.OVER_COST_2,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			chain = skill.CHAIN_FOLLOW,
			ranged = true,
			accMod = [100,099,099,099,099,   099,099,099,099,099],
			spdMod = [100,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"       ,100,125,132,132,140,   140,147,147,147,160],
			],
		},
		"ganrei": {
			name = "Ganrei-battouzan",
			description = "Enter a defensive stance, and counter with a powerful slash.",
			animations = { 'main' : "/nodes/FX/basic.tscn", 'onfollow' : "/nodes/FX/basic_test.tscn" },
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetPost = skill.TARGET_SELF_ROW,
			element = core.stats.ELEMENTS.DMG_CUT,
			damageStat = core.stats.STAT.ATK,
			modStat = core.stats.STAT.LUC,
			accMod = [100,099,099,099,099,   099,099,099,099,099],
			spdMod = [095,100,100,100,100,   100,100,100,100,100],
			initAD = [075,100,100,100,100,   100,100,100,100,100],
			AD =     [075,100,100,100,100,   100,100,100,100,100],
			codePR = [
				["counter_max",		002,001,001,001,001,  001,001,001,001,001],
				["counter_dec",		000,001,001,001,001,  001,001,001,001,001],
				["counter_set",		100,001,001,001,001,  001,001,001,001,001],
				["decoy",					010,001,001,001,001,  001,001,001,001,001],
			],
			codeMN = [
				["counter_max",		002,001,001,001,001,  001,001,001,001,001],
				["counter_dec",		000,001,001,001,001,  001,001,001,001,001],
				["counter_set",		100,001,001,001,001,  001,001,001,001,001],
				["decoy",					100,001,001,001,001,  001,001,001,001,001],
				["atk_mod",				120,001,001,001,001,  001,001,001,001,001, skill.OPFLAGS_VALUE_PERCENT],
			],
			codePO = [
				["ad",							-05,-01,-01,-01,-01,  -01,-01,-01,-01,-01],
			],
			codeFL = [
				#["playanim",				001,001,001,019,022,  030,032,035,037,040],
				["attack", 					220,013,016,019,022,  030,032,035,037,040],
			],
		},
		"reienzan": {
			name = "Reienzan",
			description = "Slashes the very soul of the target, setting it ablaze. Specially effective against targets with a spirit.",
			animations = { 'main' : "/nodes/FX/basic_test.tscn" },
			displayElement = [1, 7],
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			damageStat = core.stats.STAT.ATK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			accMod = [100,099,099,099,099,   099,099,099,099,099],
			spdMod = [100,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"        , 100,125,132,132,140,   140,147,147,147,160, skill.OPFLAGS_SILENT_ATTACK],
				["if_race_aspect", 003,003,003,003,003,   003,003,003,003,003],
				["dmgbonus",       100,125,132,132,140,   140,147,147,147,160],
				["energy_dmg",     001,001,132,132,140,   140,147,147,147,160],
				["attack"        , 080,125,132,132,140,   140,147,147,147,160],
			],
		},
		"jigenzan": {
			name = "Jigenzan",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			damageStat = core.stats.STAT.ATK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			accMod = [100,099,099,099,099,   099,099,099,099,099],
			spdMod = [100,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"       ,100,125,132,132,140,   140,147,147,147,160],
			],
		},
		"retugiri": {
			name = "Retsugiri",
			description = "",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_CUT,
			damageStat = core.stats.STAT.ATK,
			modStat = core.stats.STAT.LUC,
			accMod = [100,099,099,099,099,   099,099,099,099,099],
			spdMod = [100,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"       ,100,125,132,132,140,   140,147,147,147,160],
			],
		},
		"solbull":{
			name = "Solar Bullet",
			description = "Fires a barrage of Neo-Heliolite-tipped bullets which explode on impact.",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			damageStat = core.stats.STAT.ATK,
			modStat = core.stats.STAT.LUC,
			accMod = [100,099,099,099,099,   099,099,099,099,099],
			spdMod = [100,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"       ,100,125,132,132,140,   140,147,147,147,160],
			],
		},
		"solbeam":{
			name = "Solar Cannon",
			description = "Fires a barrage of Neo-Heliolite-tipped bullets which explode on impact.",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_PIERCE,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			accMod = [110,099,099,099,099,   099,099,099,099,099],
			spdMod = [075,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"       ,550,125,132,132,140,   140,147,147,147,160],
			],
		},
		"heliosph":{
			name = "Heliosphere",
			description = "Fires a barrage of Neo-Heliolite bullets around the enemy and releases all of the contained energy as heat.",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_ALL,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_FIRE,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			accMod = [110,099,099,099,099,   099,099,099,099,099],
			spdMod = [075,100,100,100,100,   100,100,100,100,100],
			AD =     [105,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"       ,450,125,132,132,140,   140,147,147,147,160],
			],
		},
	},
# Dragon gem skills ###############################################################################
	"gem": {
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
			element = core.stats.ELEMENTS.DMG_STRIKE,
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
			element = core.stats.ELEMENTS.DMG_STRIKE,
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
			animations = {'main' : "/nodes/FX/basic_heal.tscn"},
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
# Testing skills ##################################################################################
	"debug": {
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
			element = core.stats.ELEMENTS.DMG_STRIKE,
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
		"healbio": {
			name = "Healing",
			category = skill.CAT_SUPPORT,
			animations = { 'main': "/nodes/FX/basic_heal.tscn" },
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ALLY,
			ranged = true,
			codeMN = [
				["if_race_aspect", 002,125,132,132,140,  140,147,147,147,160, skill.OPFLAGS_BLOCK_START],
					["heal",          075,125,132,132,140,  140,147,147,147,160, skill.OPFLAGS_VALUE_ABSOLUTE],
					["stop",          001,001,001,001,001,  001,001,001,001,001],
				["heal",          015,125,132,132,140,  140,147,147,147,160, skill.OPFLAGS_VALUE_ABSOLUTE],
			],
		},
		"healmec": {
			name = "Heal Machine",
			category = skill.CAT_SUPPORT,
			animations = { 'main': "/nodes/FX/basic_heal.tscn" },
			target = skill.TARGET_SINGLE,
			targetGroup = skill.TARGET_GROUP_ALLY,
			ranged = true,
			codeMN = [
				["if_race_aspect", 001,125,132,132,140,  140,147,147,147,160, skill.OPFLAGS_BLOCK_START],
					["heal",          085,125,132,132,140,  140,147,147,147,160, skill.OPFLAGS_VALUE_ABSOLUTE],
					["stop",          001,001,001,001,001,  001,001,001,001,001],
				["heal",          015,125,132,132,140,  140,147,147,147,160, skill.OPFLAGS_VALUE_ABSOLUTE],
			],
		},
		"revive": {
			name = "Revive",
			category = skill.CAT_SUPPORT,
			animations = {'main' : "/nodes/FX/basic_heal.tscn"},
			target = skill.TARGET_SINGLE,
			filter = skill.FILTER_DOWN,
			targetGroup = skill.TARGET_GROUP_ALLY,
			ranged = true,
			codeMN = [
				["revive",       015,125,132,132,140,  140,147,147,147,160, skill.OPFLAGS_VALUE_ABSOLUTE],
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
		},
		"solidbun": {
			name = "Solid Bunker",
			description = "",
			category = skill.CAT_SUPPORT,
			type = skill.TYPE_WEAPON,
			requiresWeapon = 1,
			target = skill.TARGET_ROW,
			targetGroup = skill.TARGET_GROUP_ALLY,
			element = core.stats.ELEMENTS.DMG_STRIKE,
			effect = skill.EFFECT_STATS,
			effectIfActive = skill.EFFCOLL_ADD,
			effectType = skill.EFFTYPE_BUFF,
			effectStats = skill.EffectStat.EFFSTAT_BASEMULT,
			effectStatBonus = {
				EFFSTAT_BASEMULT = {
					DEF =     [120,000,000,000,000, 000,000,000,000,000],
					RES_KIN = [120,000,000,000,000, 000,000,000,000,000],
				},
			},
			effectDuration = [000, 002, 002, 002, 003,   003, 003, 003, 003, 004],
			effectPriority = 0,
			AD = 			[110, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[150, 100, 100, 100, 100,   100, 100, 100, 100, 100],
		},
		"alertstc": {
			name = "Situation check",
			description = "",
			animations = { 'main' : "/nodes/FX/basic_charge.tscn" },
			category = skill.CAT_SUPPORT,
			target = skill.TARGET_SELF,
			targetGroup = skill.TARGET_GROUP_ALLY,
			effect = skill.EFFECT_SPECIAL,
			effectIfActive = skill.EFFCOLL_REFRESH,
			effectType = skill.EFFTYPE_BUFF,
			effectStats = skill.EffectStat.EFFSTAT_NONE,
			effectDuration = [000, 002, 002, 002, 003,   003, 003, 003, 003, 004],
			effectPriority = 0,
			AD = 			[075, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			spdMod = 	[200, 100, 100, 100, 100,   100, 100, 100, 100, 100],
			codeMN = [
				["counter_max",   002,000,000,000,000,  000,000,000,000,000],
				["counter_dec",   000,000,000,000,000,  000,000,000,000,000],
				["counter_set",   080,000,000,000,000,  000,000,000,000,000],
			],
			codeFL = [
				["enemy_summon",   001,000,000,000,000,  000,000,000,000,000],
			]
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
				"{USER} takes aim!",
			],
		},
		"focushot": {
			name = "Focus Shot",
			description = "Marks an enemy for a chase attack.",
			category = skill.CAT_ATTACK,
			type = skill.TYPE_WEAPON,
			requiresWeapon = skill.WPCLASS_FIREARM,
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
				["chase_dec",  035, 125, 132, 132, 140,   140, 147, 147, 147, 160],
				["chase_set",  100, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			],
			codeFL = [
				["attack",			045, 125, 132, 132, 140,   140, 147, 147, 147, 160],
			]
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
				"{USER} focuses!",
				"{USER} breaks {TARGET}'s defenses!"
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
			effectStats = skill.EffectStat.EFFSTAT_BASE,
			effectStatBonus = {
				EFFSTAT_BASE = {
					RES_KIN = [025, 000, 000, 000, 000,   000, 000, 000, 000, 000],
					RES_ENE = [025, 000, 000, 000, 000,   000, 000, 000, 000, 000],
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
		"memebeyo": {
			name = "Memento from the Void",
			description = "Self destructs for a dual-elemental ultimate and fire attack.",
			category = skill.CAT_ATTACK,
			target = skill.TARGET_ROW,
			targetGroup = skill.TARGET_GROUP_ENEMY,
			element = core.stats.ELEMENTS.DMG_ULTIMATE,
			energyDMG = true,
			damageStat = core.stats.STAT.ETK,
			modStat = core.stats.STAT.LUC,
			ranged = true,
			accMod = [090,099,099,099,099,   099,099,099,099,099],
			spdMod = [120,100,100,100,100,   100,100,100,100,100],
			AD =     [110,100,100,100,100,   100,100,100,100,100],
			codeMN = [
				["attack"            ,050,125,132,132,140,   140,147,147,147,160],
				["element"           ,004,004,004,004,004,   004,004,004,004,004],
				["attack"            ,050,125,132,132,140,   140,147,147,147,160],
			],
			codePO = [
				["defeat"            ,100,125,132,132,140,   140,147,147,147,160],
			],
			synergy = [["debug", "dncsword"]],
		},
	},
}

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING, default = "Unnamed Skill" },
		"description" : { loader = LIBSTD_STRING, default = "Your ad here!" },
		"displayElement" : { loader = LIBSTD_VARIABLEARRAY },
		"type" : { loader = LIBSTD_INT, default = 0 },
		"category" : { loader = LIBSTD_INT },
		"costWP" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
		"costEP" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
		"costOV" : { loader = LIBSTD_INT, default = core.skill.OVER_COST_1 },
		"requiresPart" : { loader = LIBSTD_INT, default = 0 },
		"requiresWeapon" : { loader = LIBSTD_INT, default = 0 },
		"target" : { loader = LIBSTD_SKILL_ARRAY },
		"targetPost" : {loader = LIBSTD_SKILL_ARRAY },
		"targetGroup" : { loader = LIBSTD_INT },
		"element" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
		"energyDMG" : { loader = LIBSTD_BOOL },
		"damageStat" : { loader = LIBSTD_INT, default = core.stats.STAT.ATK },
		"modStat" : { loader = LIBSTD_INT, default = core.stats.STAT.LUC },
		"inflict" : { loader = LIBSTD_INT },
		"inflictPow" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },

		"fieldEffectMult" : { loader = LIBSTD_SKILL_ARRAY, default = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1] },
		"fieldEffectAdd" : { loader = LIBSTD_SKILL_ARRAY, default = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]},

		"targetBlacklist" : { loader = LIBSTD_TID_ARRAY, default = null},

		"effect" : { loader = LIBSTD_INT },
		"effectType" : { loader = LIBSTD_INT },
		"effectIfActive" : { loader = LIBSTD_INT },
		"effectCancel" : { loader = LIBSTD_INT },
		"effectStats" : { loader = LIBSTD_INT },
		"effectStatBonus" : { loader = LIBEXT_EFFECT_STATBONUS },
		"effectDuration" : { loader = LIBSTD_SKILL_ARRAY },
		"effectPriority" : { loader = LIBSTD_INT },

		"chargeAnim" : { loader = LIBSTD_SKILL_ARRAY, default = [0,0,0,0,0, 0,0,0,0,0] },
		"animations" : { loader = LIBEXT_ANIM, default = { 'main': "/nodes/FX/basic.tscn" } },
		"animFlags" : { loader = LIBSTD_SKILL_ARRAY, default = [0,0,0,0,0, 0,0,0,0,0]},

		"ranged" : { loader = LIBSTD_SKILL_ARRAY, default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
		"levels" : { loader = LIBSTD_INT, default = 10 },
		"accMod" : { loader = LIBSTD_SKILL_ARRAY, default = [090,090,090,090,090, 090,090,090,090,090] },
		"spdMod" : { loader = LIBSTD_SKILL_ARRAY, default = [100,100,100,100,100, 100,100,100,100,100] },
		"critMod": { loader = LIBSTD_SKILL_ARRAY, default = [005,005,005,005,005, 005,005,005,005,005] },
		"AD" : { loader = LIBSTD_SKILL_ARRAY, default =     [100,100,100,100,100,100, 100,100,100,100] },
		"initAD" : { loader = LIBSTD_SKILL_ARRAY, default = [100,100,100,100,100, 100,100,100,100,100] },
		"filter" : { loader = LIBSTD_INT },
		"messages" : { loader = LIBEXT_SKILL_MESSAGES },
		"linkSkill" : { loader = LIBSTD_SKILL_LIST },
		"synergy" : { loader = LIBSTD_SKILL_LIST },
		"chain" : {loader = LIBSTD_INT, default = core.skill.CHAIN_NONE },
		"summons" : {loader = LIBSTD_SUMMONS, default = null},

		"codePR" : { loader = LIBEXT_SKILL_CODE },
		"codePP" : { loader = LIBEXT_SKILL_CODE },
		"codeST" : { loader = LIBEXT_SKILL_CODE },
		"codeMN" : { loader = LIBEXT_SKILL_CODE },
		"codePO" : { loader = LIBEXT_SKILL_CODE },
		"codeFL" : { loader = LIBEXT_SKILL_CODE },
		"codeDN" : { loader = LIBEXT_SKILL_CODE },
		"codeEF" : { loader = LIBEXT_SKILL_CODE },
		"codeEP" : { loader = LIBEXT_SKILL_CODE },
		"codeEE" : { loader = LIBEXT_SKILL_CODE },
		"codeEA" : { loader = LIBEXT_SKILL_CODE },
		"codeEH" : { loader = LIBEXT_SKILL_CODE },
		"codeED" : { loader = LIBEXT_SKILL_CODE },
	}

func loadDebug():
	print("[SKILL][loadDebug] Loading core skills.")
	loadDict(example)
	print("[SKILL][loadDebug] Core skills loaded.")

func name(id):
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"

func loaderSkillFilterEXArg(val):
	if val == null:
		return null
	else:
		return val

func loaderSkillCode(a): #Loads skill codes.
	#TODO: Make template a constant in skill.gd.
	#                SKILL OPCODE        VALUE PER LEVEL         FLAGS               TAG    DGEM TAG
	#   _template = [skill.OPCODE_NULL,  0,0,0,0,0,  0,0,0,0,0,  skill.OPFLAGS_NONE, '',    '']
	var _template = skill.LINE_TEMPLATE
	match(typeof(a)): #Check input type
		TYPE_NIL:
			#Input is null, this skill isn't meant to have code, so we return null back.
			return null
		TYPE_ARRAY:
			#Input is an array. This is the expected input, so we process it further.
			var result = core.newArray(a.size())
			var line = null #Placeholder for the current line.
			for j in a.size():
				line = a[j]
				result[j] = _template.duplicate() #Initialize line as a copy of the template, saves the trouble of keeping sync.
				match(typeof(line)): #Determine line format.
					TYPE_STRING: #Line is just an instruction, usually a 'get' with default values.
						result[j][0] = skill.translateOpCode(line)
					TYPE_ARRAY:  #We have an array, the standard instruction. There are a few variants.
						match(line.size()):
							1:  # Instruction only, in case one wants to keep it as array for consistency.
								result[j][0] = skill.translateOpCode(line[0])
							2:  # Instruction + flags
								result[j][0] = skill.translateOpCode(line[0])
								result[j][11] = int(line[1])
							3:  # Instruction + single value + flags
								result[j][0] = skill.translateOpCode(line[0])
								for i in range(1, 11): result[j][i] = int(line[1])
								result[j][11] = int(line[2])
							11: # Instruction + values for 10 levels
								result[j][0] = skill.translateOpCode(line[0])
								for i in range(1, 11): result[j][i] = int(line[i])
							12: # Instruction + values for 10 levels + flags
								result[j][0] = skill.translateOpCode(line[0])
								for i in range(1, 11): result[j][i] = int(line[i])
								result[j][11] = int(line[11])
							_:  # Unexpected line. Print an error.
								print("\t[!!][SKILL][loaderSkillCode] Line size is not normal, returning null line.")
					_: # Unexpected type. Print an error.
						print("\t[!!][SKILL][loaderSkillCode] Line is neither string or array, returning null line.")
			return result
		_:
			#Input is...something else. Likely user error. Return a line with no effect as a last resort.
			print("\t[!!][SKILL][loaderSkillCode] Provided skill code is not an array. Please verify. ")
			return [ _template.duplicate() ]

func loaderMessages(val): #Loads skill messages.
	match typeof(val):
		TYPE_NIL:   # Input is null. Return null so printing a message can just skip the process.
			return null
		TYPE_ARRAY: # Input is an array. This is the expected input, load all messages.
			var messages = []
			for i in range(val.size()): messages.push_back(str(val[i]))
			return messages
		_:          # Unknown input. Print error and return null.
			print("\t[!!][SKILL][loaderMessages] Unknown input type, returning null.")
			return null

func loaderEffectStatBonus(dict): #Loads effect stat modifiers.
	if dict == null:
		return null
	var stats = core.stats
	var result = {}
	for key in skill.EffectStat:
		if dict.has(key):
			match key:
				"EFFSTAT_BASE":
					result.EFFSTAT_BASE = {}
					for i in dict.EFFSTAT_BASE:
						var I = i.to_upper()
						if I in core.stats.STATS or I in core.stats.ELEMENT_MOD_TABLE:
							result.EFFSTAT_BASE[I] = loaderSkillArray(dict.EFFSTAT_BASE[i])
				"EFFSTAT_BASEMULT":
					result.EFFSTAT_BASEMULT = {}
					for i in dict.EFFSTAT_BASEMULT:
						var I = i.to_upper()
						if I in core.stats.STATS or I in core.stats.ELEMENT_MOD_TABLE:
							result.EFFSTAT_BASEMULT[I] = loaderSkillArray(dict.EFFSTAT_BASEMULT[i])
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

func loaderSkillLink(val): #Loads linked skills.
	return null

func loaderAnim(val): #Loads animations.
	var result = {}
	if val != null:
		for i in val:
			print(i)
			result[i] = "res:/%s" % str(val[i])
		if not 'main' in result:
			result['main'] = "res://nodes/FX/basic.tscn"
		if not 1 in result:
			result[1] = result.main
	return result
