var stats = core.stats
var MAX_DMG = stats.MAX_DMG

const SKILL_MISSED = -1
const SKILL_FAILED = -2
const MAX_LEVEL = 10

enum { #Category
#General category of the attacks. Determines its general context
	CAT_ATTACK = 0,		#Combat actions that target enemies (attacks, debuffs, etc)
	CAT_SUPPORT,			#Combat actions that target allies (heals, buffs, etc) (no acc check)
	CAT_OVER					#Skill is an Over skill and only available in battle, similar to CAT_ATTACK (always hits)
	CAT_STATUP,				#Skill has no combat or passive effects, only raises stats/resists
	CAT_PASSIVE,			#Skill that have passive effects
	CAT_FIELD,				#Skill that can be used for events
}

enum { #Filter
#Whenever any skill activates (for every number of activations), the skill will test based on filter
#If failed, the attack fails (as opposed to missing).
#In menus, only targets that match can be selected.
	FILTER_ALIVE = 0,				#Target must be alive (attacks, heals, pretty much anything)
	FILTER_ALIVE_OR_STASIS, #Target must be alive or in stasis (special case)
	FILTER_DOWN,						#Target must be incapacitated (revives)
	FILTER_STATUS,					#Target must be alive and have a status effect (status recovery, ailment combos)
	FILTER_DISABLE,					#Target must have a disabled body part (body part heal)
	FILTER_STASIS,					#Target must be in stasis (special case)
}

# enum { #Filter Extra #TODO:Remove entirely. Makes more sense to store some args in skill data and use opcodes to check for them.
# #When any skill activates (for every number of activations), the skill will produce an extra effect
# #if it matches the filter. If failed, the extra effect doesn't activate.
# #A single argument is provided.
# 	FILTER_EX_NONE,			#Extra effect is ignored entirely.								arg: null
# 	FILTER_EX_ALIVE, 		#Activates if target is alive.										arg: null
# 	FILTER_EX_DOWN,			#Activates if target is incapacitated. 						arg: null
# 	FILTER_EX_STATUS,		#Activates if target has a specific status ID. 		arg: int
# 	FILTER_EX_ANY_STATUS, #Activates if target has any status ID.					arg: null
# 	FILTER_EX_BUFF,			#Activates if target has a specific buff.					arg: TID
# 	FILTER_EX_DEBUFF,		#Activates if target has a specific debuff.				arg: TID
# 	FILTER_EX_ANY_BUFF,	#Activates if target has any buff.								arg: null
# 	FILTER_EX_ANY_DEBUFF, #Activates if target has any debuff.						arg: null
# 	FILTER_EX_ANY_BUFF_DEBUFF, #Activates if target has any buff/debuff		arg: null
# 	FILTER_EX_DEFEND,		#Activates if target is or isn't defending.				arg: bool
# 	FILTER_EX_ACT_ORDER,#Activates if target acts before/after user.			arg: bool
# 	FILTER_EX_MAINRACE,	#Activates if target matches a general race.			arg: int
# 	FILTER_EX_TID,			#Activates if target is a specific TID.						arg: TID
# }

enum { #General race types
	RACE_NONE,
	RACE_HUMAN,
	RACE_MACHINE,
	RACE_SPIRIT,
	RACE_DEMON,
	RACE_ANGEL,
	RACE_DRAGON,
	RACE_FAIRY,
	RACE_UNDEAD,
	RACE_BEAST,
	RACE_GOD,
	RACE_OUTSIDER,
	RACE_ORIGINATOR,
}

enum { #Weapon classes
	WPCLASS_NONE,
	WPCLASS_FIST,
	WPCLASS_SHORTSWORD,
	WPCLASS_LONGSWORD,
	WPCLASS_POLEARM,
	WPCLASS_HAMMER,
	WPCLASS_AXE,
	WPCLASS_ROD,
	WPCLASS_GRIMOIRE,
	WPCLASS_HANDGUN,
	WPCLASS_FIREARM,
	WPCLASS_ARTILLERY,
	WPCLASS_SHIELD,
}

enum {
	RACEF_BIO = 0x01,
	RACEF_MEC = 0x02,
	RACEF_SPI = 0x04,
}

enum { MODSTAT_NONE, MODSTAT_STR, MODSTAT_END, MODSTAT_INT, MODSTAT_WIS, MODSTAT_AGI, MODSTAT_LUC }
enum {
	REQUIRES_NONE =	0x00,
	REQUIRES_HEAD =	0x01,
	REQUIRES_ARM =	0x02,
	REQUIRES_LEG =	0x04,
}

enum { #Skill type
	TYPE_BODY,
	TYPE_WEAPON,
	TYPE_ITEM,
}

enum { USE_ANYWHERE, USE_COMBAT, USE_FIELD }

enum { EFFTYPE_BUFF, EFFTYPE_DEBUFF, EFFTYPE_SPECIAL }


enum { #Skill effects
	EFFECT_NONE =			0x0000, #No effect
	EFFECT_STATS = 		0x0002, #Alters combat stats
	EFFECT_ATTACK = 	0x0200,	#Runs effect code EA on a successful hit
	EFFECT_ONHIT = 		0x0400, #Runs effect code EH when receiving a hit
	EFFECT_ONEND =		0x0800, #Runs effect code EE when the effect ends
	EFFECT_SPECIAL = 	0x1000, #Runs effect code ES at the start of a turn
}

enum { #What to do in case of effect collision
	EFFCOLL_REFRESH,	#Default, reset effect to maximum duration.
	EFFCOLL_ADD,			#Add maximum duration to current duration.
	EFFCOLL_FAIL,			#Effect fails
	EFFCOLL_NULLIFY,	#Cancels effect
}

enum EffectStat { #Effect stat mods
	EFFSTAT_NONE =			0x0000, #No change
	EFFSTAT_BASE =			0x0001,	#Change (raw) to base stats (STR, INT...)
	EFFSTAT_BASEMULT =	0x0002,	#Change (multiplier) to base stats. Multipliers are additive.
	EFFSTAT_OFF =				0x0004,	#Change to elemental offense stats.
	EFFSTAT_RES =		 		0x0008,	#Change to elemental resistance stats.
	EFFSTAT_STRES = 		0x0010,	#Change to status effect resistances.
	EFFSTAT_AD =		 		0x0020,	#Change to active defense%
	EFFSTAT_GUARD = 		0x0040,	#Change guard value.
	EFFSTAT_BARRIER = 	0x0080,	#Change barrier value.
	EFFSTAT_DECOY = 		0x0100,	#Change attack draw rate%
	EFFSTAT_DODGE =			0x0200,	#Change forced dodge value.
	EFFSTAT_EVASION =		0x0400,	#Change evasion bonus.
}


enum {
	STATUS_NONE,			#All good
	STATUS_DOWN,			#Incapacitated (not quite dead but defeated enough)
	STATUS_STASIS,		#Target is removed from combat for a limited time
	STATUS_CORROSION,	#Target receives damage per turn
	STATUS_CURSE,			#Target is damaged by a factor when it causes damage to others
	STATUS_PARA,			#Target is randomly unable to move
	STATUS_BLIND,			#Target has diminished accuracy
	STATUS_SLEEP,			#Target is unable to act, but being hit will randomly wake them up.
	STATUS_FROZEN,		#Target has been frozen and is unable to act, and weaker to physical moves. Fire unfreezes.
	STATUS_PETRIFY,		#Target has been petrified and is unable to act, and weaker to special moves.
	STATUS_PANIC,			#Target cannot perform actions, instead it'll do a basic attack against a random target of any team.
	STATUS_STUN,			#Target cannot act for the current turn.
}

enum {
	MSG_NONE = 			0x00,
	MSG_USER = 			0x01,
	MSG_TARGET = 		0x02,
	MSG_SKILL = 		0x04,
}

enum { #Chains. Starters init a sequence, follows increase it, and finishers use the chain value as modifier.
	CHAIN_NONE = 0,
	CHAIN_STARTER,
	CHAIN_FOLLOW,
	CHAIN_STARTER_AND_FOLLOW,
	CHAIN_FINISHER,
}

enum { #Parry. Reduces the damage of an attack with a given chance.
	PARRY_NONE = 0,
	PARRY_KINETIC,
	PARRY_ENERGY,
	PARRY_ALL,
}

enum {
	FOLLOW_FOLLOWUP,
	FOLLOW_COMBO,
	FOLLOW_COUNTER,
}

enum {
#To expedite combat, some skills don't show a target prompt.
#Skills only allow targets within range. If only one target is in range, it'll be chosen automatically.
	#No prompt
	TARGET_SELF,							#Targets only self.																		prompt: no
	TARGET_RANDOM1,						#Picks any valid targets, can repeat.									prompt: no
	TARGET_RANDOM2,						#Picks any valid targets, but can't repeat.						prompt: no
	TARGET_SELF_ROW,					#Pics any valid targets on self's row.								prompt: no
	TARGET_SELF_ROW_NOT_SELF,	#Picks any valid targets on self's row but user.			prompt: no
	TARGET_ALL,								#Targets everyone.																		prompt: no
	TARGET_ALL_NOT_SELF,			#Targets everyone but user.														prompt: no

	#Pick single target
	TARGET_SINGLE,						#Targets any member.																	prompt: yes
	TARGET_SINGLE_NOT_SELF,		#Targets any member, except self.											prompt: yes
	TARGET_SPREAD,						#Targets one member, and affects nearby members.			prompt: yes

	#Pick row of targets
	TARGET_ROW,								#Targets a full row.																	prompt: yes
	TARGET_ROW_RANDOM,				#Picks any valid targets on selected row.							prompt: yes

	#Pick two members
	TARGET_LINE,							#Targets one member per row.													prompt: yes
}

enum {
	#Codes
	CODE_ST,  #Setup code: if the skill has multiple targets, run this code to do stuff that should only happen once, not once per target.
	CODE_MN,	#Main code: the main body of the skill.
	CODE_FL,	#Follow code: For actions that cause an extra attack to come out. Keep it simple!
	CODE_PR,	#Priority code: targets self, used to set things up at the start of the turn.
	CODE_DN,  #Down code: run this if the skill defeats a target, for every target.
	CODE_EF,	#Effect code: if the skill provides a buff/debuff with special effect, use this code.
	CODE_EE,	#Effect end code: if the skill provides a buff/debuff, use this code when it ends.
	CODE_EA,  #Effect Attack code: while the skill provides a buff/debuff, use this code when successfuly hitting a target.
	CODE_EH,  #Effect Hurt code: while the skill provides a buff/debuff, use this code when getting successfully hit by an attacker.
	CODE_ED,  #Effect down code: while the skill provides a buff/debuff, use this code when defeating a target.

}

enum {
	OPFLAGS_NONE =           0x0000,  #Default settings.
	OPFLAGS_TARGET_SELF	=    0x0001,  #This opcode will affect the user if applicable.
	OPFLAGS_VALUE_ABSOLUTE = 0x0002,  #This opcode will set a value as absolute, if applicable.
	OPFLAGS_VALUE_PERCENT =  0x0004,  #This opcode will set a value as a percentage, if applicable.
	OPFLAGS_HEAL_BONUS =     0x0008,  #Heal only. Uses bonus healing value.
	OPFLAGS_USE_SVAL =       0x0010,  #Use state stored value instead of passed value.
	OPFLAGS_QUIT_ON_FALSE =  0x0020,  #In a conditional, directly quit instead of skipping next line.
	OPFLAGS_BLOCK_START =    0x0040,  #In a conditional, start a block. Skips everything until a OPFLAGS_BLOCK_END is found.
	OPFLAGS_BLOCK_END =      0x0080,  #Determines end of a code block.
	OPFLAGS_SILENT_ATTACK =  0x0100,  #Makes an attack not output any messages, and passes previous attack as a stack for next non-silent attack.
}

enum {
	#Flags: [@]: Can change target to user. [=]: Forces an absolute value instead of additive.
	#       [%]: Opcode uses a percentage.  [+]: Apply healing bonus.
	#Null
	OPCODE_NULL,							#No effect

	# Standard combat functions ##################################################
	OPCODE_ATTACK,						#Standard attack function with power%. Tries to inflict each hit if capable.
	OPCODE_FORCE_INFLICT,			#[@]Attempt to inflict an ailment independent from attack.
	OPCODE_DAMAGERAW,					#[@%]Reduce target's HP by given value (no check)

	# Followup functions #########################################################
	# Use before OPCODE_FOLLOW
	OPCODE_FOLLOW_DECREMENT,	#Sets follow% decrement per hit. Use before OPCODE_FOLLOW!
	OPCODE_FOLLOW_ELEMENT,		#Sets damage type to limit follows to a specific element. 0 for current element. Do not set to follow any element.
	# Main setter
	OPCODE_FOLLOW,						#Sets "follow" on target. Use this function last to actually set the state.

	# Combo functions ############################################################
	# Use before OPCODE_COMBO
	OPCODE_COMBO_DECREMENT,
	OPCODE_COMBO_ELEMENT,			#Sets damage type to limit chains to a specific element. 0 for current element. Do not set to follow any element.
	# Main setter
	OPCODE_COMBO,

	# Counter functions ##########################################################
	# Use before OPCODE_COUNTER
	OPCODE_COUNTER_MAX,				#Maximum amount of times to counter per turn. Use before OPCODE_COUNTER!
	OPCODE_COUNTER_DECREMENT, #Sets counter decrement per counter.
	OPCODE_COUNTER_ELEMENT,		#Sets to counter only specific element. 0 for current element. Do not set to counter any element.
	OPCODE_COUNTER_FILTER,		#Sets to counter only specific attack types. 0 = none, 1 = kinetic, 2 = energy, 3 = both.
	# Main setter
	OPCODE_COUNTER,						#Sets counter initial X% and sets counter to current skill.


	# Healing functions ##########################################################
	OPCODE_HEAL,							#[@=%+]Standard healing.
	OPCODE_HEALROW,						#[=+]Heal user's row with power X.
	OPCODE_HEALALL,						#[=+]Heal user's party with power X.
	OPCODE_CURE,							#[@]Restores target's status to normal.
	OPCODE_RESTOREPART,				#[@]Restores up to X disabled body parts. 3+ restores them all.
	OPCODE_REVIVE,						#[+]Target is revived with X health.
	OPCODE_OVERHEAL,					#[@]Sets amount of healing allowed to go past maximum health for this turn.

	# Standard effect functions ##################################################
	OPCODE_AD,								#[@=]Set target's active defense% for the rest of the turn.
	OPCODE_DECOY,							#[@=]Set target's decoy% for the rest of the turn.
	OPCODE_BARRIER,						#[@=]Set target's barrier (all incoming damage is reduced by X) for the rest of the turn.
	OPCODE_GUARD,							#[@=%]Set target's guard (a total of X damage is negated) for the rest of the turn.
	OPCODE_PROTECT,						#[@]User protects target with an X% chance until the end of the turn.
	OPCODE_RAISE_OVER,				#[@]Increases Over gauge by X.

	# Standard support functions #################################################
	OPCODE_SCAN,							#Scans target with 1 or 2 power. Anything beyond 2 is reduced to 2, has no effect if 0.
	OPCODE_TRANSFORM,					#[@]Causes target to transform, if possible, if not 0, cancel transformation if 0.

	#Attack modifiers ############################################################
	#These are reset per target and if used in PR code they don't carry over.
	OPCODE_DAMAGEBONUS,				#Bonus% to base power (additive).
	OPCODE_ADD_RAW_DAMAGE,		#Raw damage addition to next attack.
	OPCODE_HEALBONUS,					#Bonus% to heal power (additive).
	OPCODE_ADD_RAW_HEAL,			#Raw healing addtion to next heal.
	OPCODE_INFLICT,						#Infliction rate for the following attacks.
	OPCODE_INFLICT_B,					#Bonus% to status infliction (additive).

	OPCODE_CRITMOD,						#Critical hit mod.
	OPCODE_ELEMENT,						#Sets damage type for the following attacks.
	OPCODE_ELEMENT_WEAK,			#Sets damage type to one target is weakest to.
	OPCODE_ELEMENT_RESIST,		#Sets damage type to one target is most resistant to.
	OPCODE_ELEMENT_LAST,			#If not 0, sets element to the one last used by a party member.

	OPCODE_MINHITS,						#Sets minimum number of hits. Defaults to 1.
	OPCODE_MAXHITS,						#Sets maximum number of hits. Defaults to 1.
	OPCODE_NUMHITS,						#Sets both MINHITS and MAXHITS to the given value.

	OPCODE_NOMISS,						#If 1, following combat effects won't miss.
	OPCODE_NOCAP,							#If 1, damage can go over cap (32000).
	OPCODE_IGNORE_DEFS,				#Attack ignores target's guard, barrier and defender.
	OPCODE_RANGE,							#Switch ranged property to true (if not 0) or false (if 0).
	OPCODE_ENERGY,						#Switch energy property to true (if not 0) or false (if 0).
	OPCODE_DRAINLIFE,					#User is healed for given % of total damage dealt for each hit.

	OPCODE_CHAIN_START,						#If a chain is not started (chain == 0), make it 1.
	OPCODE_CHAIN_FOLLOW,					#Modify current chain value (if >1 only) by X.
	OPCODE_CHAIN_FINISH,					#If chain is not 0, make it 0.
	# Elemental Field ############################################################
	OPCODE_FIELD_PUSH,				#Add specified element to the element field. 0 to use current element.
	OPCODE_FIELD_FILL,				#Fill the element field with the specified element.
	OPCODE_FIELD_REPLACE,			#Replace all elements of the specified type from the field to current element.
	OPCODE_FIELD_REPLACE2,		#With a chance of X, try to replace all elements for current one.
	OPCODE_FIELD_RANDOMIZE,		#Randomize all elements in the field with X changing the randomization strategy.
	OPCODE_FIELD_CONSUME,     #Remove all instances of current element from the field to empty spaces, push the rest to the right.
	OPCODE_FIELD_OPTIMIZE,		#Sort elements so they form chains if more than one exists.
	OPCODE_FIELD_LOCK,        #Lock the element field for X turns. If the wait is already not 0, add X-1 instead.
	OPCODE_FIELD_UNLOCK,      #Unlock the element field now.
	OPCODE_FIELD_GDOMINION,		#Set G-Dominion's "hyper field" property for user's group. All bonuses become x1.5 base.
	OPCODE_FIELD_SETLASTELEM, #Set current element to the last (rightmost) element on the field.
	OPCODE_FIELD_SETDOMIELEM,	#Set current element to the dominant element on the field.
	OPCODE_FIELD_ELEMBLAST,		#For every chain on the field, add its element to queue.
	OPCODE_FIELD_MULT,        #[@]Set current field effect damage multiplier.

	# General specials ###########################################################
	OPCODE_PRINTMSG,					#Print message X of the defined skill messages. Use 0 to print nothing.
	OPCODE_LINKSKILL,					#Uses a provided skill TID with the same level as cast.
	OPCODE_PLAYANIM,					#Plays a given animation. Use 0 to play no animation, 1 to play default animation.
	OPCODE_WAIT,							#Wait for X/100 miliseconds.

	# Player only specials #######################################################
	OPCODE_EXP_BONUS,					#Increases EXP given by enemy at the end of battle.

	# Control flow ###############################################################
	OPCODE_STOP,							#Stop execution.
	OPCODE_JUMP,							#Jump (Continue execution from given line).

	# Gets #######################################################################
	OPCODE_GET_FIELD_BONUS,		#Get field bonus for specified element. Current element if 0.
	OPCODE_GET_FIELD_CHAINS,	#Get amount of element chains.
	OPCODE_GET_FIELD_UNIQUE,	#Get amount of unique elements.
	OPCODE_GET_SYNERGY_PARTY, #Get amount of synergies found in the party.
	OPCODE_GET_TURN,          #Get current turn.
	OPCODE_GET_CHAIN,         #Get current combo value.
	OPCODE_GET_LAST_ELEMENT,  #Get last element used by a party member.
	OPCODE_GET_HEALTH_PERCENT,#Get health percentage from target.
	OPCODE_GET_LAST_HURT,			#Get amount of health lost from last skill.

	# Math #######################################################################
	OPCODE_MATH_ADD,					#Add X to stored value.
	OPCODE_MATH_SUB,					#Substract X from stored value.
	OPCODE_MATH_MUL,					#Multiply stored value by X.
	OPCODE_MATH_DIV,					#Divide stored value by X.
	OPCODE_MATH_MULF,					#Multiply stored value by float(X/1000)
	OPCODE_MATH_DIVF, 				#Divide stored value by float(X/1000)
	OPCODE_MATH_CAP,          #Cap value to the given value.
	OPCODE_MATH_MOD,					#Modulo operation on stored value. sval%X.
	OPCODE_MATH_PERCENT,			#Set stored value to X% of its current value.

	# Conditionals ###############################################################
	OPCODE_IF_TRUE,											#Execute next line if X is not zero.
	OPCODE_IF_CHANCE,                   #Chance% to execute next line.
	OPCODE_IF_STATUS,                   #Execute next line if afflicted.
	OPCODE_IF_SVAL_EQUAL,               #Execute next line if sval == X.
	OPCODE_IF_SVAL_LESSTHAN,            #Execute next line if sval < X.
	OPCODE_IF_SVAL_LESS_EQUAL_THAN,     #Execute next line if sval <= X.
	OPCODE_IF_SVAL_MORETHAN,            #Execute next line if sval > X.
	OPCODE_IF_SVAL_MORE_EQUAL_THAN,     #Execute next line if sval >= X.
	OPCODE_IF_EF_BONUS_LESS_EQUAL_THAN, #Execute next line if bonus for current element <= X.
	OPCODE_IF_EF_BONUS_MORE_EQUAL_THAN, #Execute next line if bonus for current element >= X.
	OPCODE_IF_ACT,                      #Execute next line if target has already acted.
	OPCODE_IF_DAMAGED,                  #Execute next line if target was damaged this turn.
	OPCODE_IF_SELF_DAMAGED,             #Execute next line if user received damage this turn.
	OPCODE_IF_HITCHECK,                 #Execute next line if a standard hit check succeeds.
	OPCODE_IF_CONNECT,                  #Execute next line if last attack command hit.
	OPCODE_IF_SYNERGY_PARTY,
	OPCODE_IF_SYNERGY_TARGET,
}

const opCodesPowerable = [OPCODE_ATTACK, OPCODE_HEAL, OPCODE_BARRIER, OPCODE_GUARD, OPCODE_DAMAGERAW]

const opCode = {
	"null" : OPCODE_NULL,

	"attack" : OPCODE_ATTACK,
	"f_inflict" : OPCODE_FORCE_INFLICT,
	"dmgraw" : OPCODE_DAMAGERAW,

	"follow_set" : OPCODE_FOLLOW,
	"follow_el"  : OPCODE_FOLLOW_ELEMENT,
	"follow_dec" : OPCODE_FOLLOW_DECREMENT,

	"combo_dec"  : OPCODE_COMBO_DECREMENT,
	"combo_el"   : OPCODE_COMBO_ELEMENT,
	"combo_set"  : OPCODE_COMBO,

	"counter_dec" : OPCODE_COUNTER_DECREMENT,
	"counter_max" : OPCODE_COUNTER_MAX,
	"counter_el" : OPCODE_COUNTER_ELEMENT,
	"counter_filter" : OPCODE_COUNTER_FILTER,
	"counter_set" : OPCODE_COUNTER,

	"chain_start" : OPCODE_CHAIN_START,
	"chain_follow" : OPCODE_CHAIN_FOLLOW,
	"chain_finish" : OPCODE_CHAIN_FINISH,

	"heal" : OPCODE_HEAL,
	"heal_row" : OPCODE_HEALROW,
	"heal_all" : OPCODE_HEALALL,
	"cure" : OPCODE_CURE,
	"healpart" : OPCODE_RESTOREPART,
	"revive" : OPCODE_REVIVE,
	"overheal" : OPCODE_OVERHEAL,


	"AD" : OPCODE_AD,
	"decoy" : OPCODE_DECOY,
	"barrier" : OPCODE_BARRIER,
	"guard" : OPCODE_GUARD,
	"protect" : OPCODE_PROTECT,
	"over" : OPCODE_RAISE_OVER,

	"scan" : OPCODE_SCAN,
	"transform" : OPCODE_TRANSFORM,

	"dmgbonus" : OPCODE_DAMAGEBONUS,
	"healbonus" : OPCODE_HEALBONUS,
	"inflict" : OPCODE_INFLICT,
	"inflictbonus" : OPCODE_INFLICT_B,

	"critmod" : OPCODE_CRITMOD,
	"element" : OPCODE_ELEMENT,
	"weaktype" : OPCODE_ELEMENT_WEAK,
	"restype" : OPCODE_ELEMENT_RESIST,

	"minhits" : OPCODE_MINHITS,
	"maxhits" : OPCODE_MAXHITS,
	"numhits" : OPCODE_NUMHITS,

	"nomiss" : OPCODE_NOMISS,
	"nocap" : OPCODE_NOCAP,
	"ignore_defs" : OPCODE_IGNORE_DEFS,
	"energy_dmg" : OPCODE_ENERGY,
	"drainlife" : OPCODE_DRAINLIFE,

	"ef_push" : OPCODE_FIELD_PUSH,
	"ef_fill" : OPCODE_FIELD_FILL,
	"ef_replace" : OPCODE_FIELD_REPLACE,
	"ef_replace2" : OPCODE_FIELD_REPLACE2,
	"ef_rando" : OPCODE_FIELD_RANDOMIZE,
	"ef_consume" : OPCODE_FIELD_CONSUME,
	"ef_optimize" : OPCODE_FIELD_OPTIMIZE,
	"ef_lock" : OPCODE_FIELD_LOCK,
	"ef_unlock" : OPCODE_FIELD_UNLOCK,
	"ef_hyper" : OPCODE_FIELD_GDOMINION,
	"ef_el_setdomi" : OPCODE_FIELD_SETDOMIELEM,
	"ef_el_setlast" : OPCODE_FIELD_SETLASTELEM,
	"ef_elemblast" : OPCODE_FIELD_ELEMBLAST,
	"ef_mult" : OPCODE_FIELD_MULT,

	"exp_bonus" : OPCODE_EXP_BONUS,

	"printmsg" : OPCODE_PRINTMSG,
	"linkskill" : OPCODE_LINKSKILL,
	"playanim" : OPCODE_PLAYANIM,
	"wait" : OPCODE_WAIT,

	"stop" : OPCODE_STOP,
	"jump" : OPCODE_JUMP,

	"get_ef_bonus" :  OPCODE_GET_FIELD_BONUS,
	"get_ef_chains" : OPCODE_GET_FIELD_CHAINS,
	"get_ef_unique" : OPCODE_GET_FIELD_UNIQUE,
	"get_synergies" : OPCODE_GET_SYNERGY_PARTY,
	"get_turn" :      OPCODE_GET_TURN,
	"get_chain" :     OPCODE_GET_CHAIN,

	"add" :  OPCODE_MATH_ADD,
	"sub" :  OPCODE_MATH_SUB,
	"mul" :  OPCODE_MATH_MUL,
	"div" :  OPCODE_MATH_DIV,
	"mulf" : OPCODE_MATH_MULF,
	"divf" : OPCODE_MATH_DIVF,
	"cap" :  OPCODE_MATH_CAP,
	"mod" :  OPCODE_MATH_MOD,

	"if_true" : OPCODE_IF_TRUE,
	"if_chance" : OPCODE_IF_CHANCE,
	"if_status" : OPCODE_IF_STATUS,
	"if_sval==" : OPCODE_IF_SVAL_EQUAL,
	"if_sval<" :  OPCODE_IF_SVAL_LESSTHAN,
	"if_sval<=" : OPCODE_IF_SVAL_LESS_EQUAL_THAN,
	"if_sval>" :  OPCODE_IF_SVAL_MORETHAN,
	"if_sval>=" : OPCODE_IF_SVAL_MORE_EQUAL_THAN,
	"if_ef_bonus<=" : OPCODE_IF_EF_BONUS_LESS_EQUAL_THAN,
	"if_ef_bonus>=" : OPCODE_IF_EF_BONUS_MORE_EQUAL_THAN,
	"if_act" : OPCODE_IF_ACT,
	"if_damaged" : OPCODE_IF_DAMAGED,
	"if_self_damaged" : OPCODE_IF_SELF_DAMAGED,
	"if_hitcheck" : OPCODE_IF_HITCHECK,
	"if_connect" : OPCODE_IF_CONNECT,
	"if_synergy_party" : OPCODE_IF_SYNERGY_PARTY,
	"if_synergy" : OPCODE_IF_SYNERGY_TARGET,
}

var opcodeInfo = {
	OPCODE_NULL: {
		name = "NULL", flags = OPFLAGS_NONE, cat = "null",
		desc = "Does nothing.",
		expl = "ERROR",
	},
	OPCODE_ATTACK: {
		name = "Attack", flags = OPFLAGS_NONE, cat = "combat",
		desc = "Standard attack function, tries to inflict for each hit, if capable.",
		expl = "hits for %s damage"
	},
	OPCODE_FORCE_INFLICT: {
		name = "Force inflict", flags = OPFLAGS_TARGET_SELF, cat = "combat",
		desc = "Attempt to inflict an ailment, independent from attack.",
		expl = "may inflict %s"
	},
	OPCODE_DAMAGERAW: {
		name = "Raw damage", flags = OPFLAGS_TARGET_SELF|OPFLAGS_VALUE_PERCENT, cat = "combat",
		desc = "Causes X damage.\nIf VALUE_PERCENT is set, does a percentage of target's max health.",
		expl = "deals %s %s direct damage"
	},
	OPCODE_HEAL: {
		name = "Heal", flags = OPFLAGS_TARGET_SELF|OPFLAGS_VALUE_ABSOLUTE|OPFLAGS_VALUE_PERCENT, cat = "healing",
		desc = "Heals a target.\nIf VALUE_ABSOLUTE is set, it heals a fixed amount.\n If VALUE_PERCENT is set, heals X% of target's max health.\nVALUE_ABSOLUTE takes precedence.",
		expl = "heals %s for %s"
	},
	OPCODE_CURE: {
		name = "Cure", flags = OPFLAGS_TARGET_SELF, cat = "healing",
		dest = "Restores target's status to normal, no questions asked.",
		expl = "restores %s status"
	},
	OPCODE_RESTOREPART: {
		name = "Restore part", flags = OPFLAGS_TARGET_SELF, cat = "healing",
		dest = "Restores up to X disabled body parts for the target. 3+ restores all parts.",
		expl = "restores body parts (%s)"
	},
	OPCODE_REVIVE: {
		name = "Revive", flags = OPFLAGS_VALUE_PERCENT, cat = "healing",
		dest = "Removes a target's DOWN status and sets health to X. If VALUE_PERCENT is set, sets it to X% of target's max health.",
		expl = "revives the target at %s health"
	},
	OPCODE_OVERHEAL: {
		name = "Overheal", flags = OPFLAGS_VALUE_ABSOLUTE, cat = "healing",
		dest = "Allows healing over max health for the rest of the turn up to MHP+X, additive. If VALUE_ABSOLUTE is set, set it exactly to X. If VALUE_PERCENT is set, set it to X% of max health. If both are present, set it to X% of max health.",
		expl = "allows %s to heal past maximum health (+%s)"
	},
	OPCODE_AD: {
		name = "Set AD", flags = OPFLAGS_TARGET_SELF|OPFLAGS_VALUE_ABSOLUTE, cat = "stats",
		desc = "Raises target's Active Defense by X.\nIf VALUE_ABSOLUTE is set, it sets it to X.",
		expl = "%s AD to %s"
	},
	OPCODE_DECOY: {
		name = "Decoy", flags = OPFLAGS_TARGET_SELF|OPFLAGS_VALUE_ABSOLUTE, cat = "stats",
		dest = "Raises target's decoy by X.\nIf VALUE_ABSOLUTE is set, it sets it to X.",
		expl = "%s draw attack rate by %s"
	},
	OPCODE_BARRIER: {
		name = "Barrier", flags = OPFLAGS_TARGET_SELF|OPFLAGS_VALUE_ABSOLUTE, cat = "stats",
		dest = "Raises target's barrier by X.\nIf VALUE_ABSOLUTE is set, it sets it to X.",
	},
	OPCODE_GUARD: {
		name = "Guard", flags = OPFLAGS_TARGET_SELF|OPFLAGS_VALUE_ABSOLUTE|OPFLAGS_VALUE_PERCENT, cat = "stats",
		dest = "Raises target's guard by X.\nIf VALUE_ABSOLUTE is set, it sets it to X.\nIf VALUE_PERCENT is set, sets it to X% of target's max health.\nVALUE_ABSOLUTE takes precedence."
	},
	OPCODE_PROTECT: {
		name = "Protect target", flags = OPFLAGS_TARGET_SELF, cat = "stats",
		dest = "User protects target with a X% chance of taking damage for the target.\nIf TARGET_SELF is set, this makes the target protect the user.",
		expl = "%s protects %s (%s%% chance)"
	},
	OPCODE_RAISE_OVER: {
		name = "Raise Over", flags = OPFLAGS_TARGET_SELF, cat = "stats",
		dest = "Adds X to target's Over gauge. Does nothing on enemies.",
		expl = "raises %s Over by %s"
	},
	OPCODE_SCAN: {
		name = "Scan", flags = OPFLAGS_NONE, cat = "misc",
		dest = "Scans target with power 1 or 2. Does nothing if zero.",
		expl = "%s draw attack rate by %s"
	},
	OPCODE_TRANSFORM: {
		name = "Transform", flags = OPFLAGS_TARGET_SELF, cat = "misc",
		dest = "If not 0, transforms target if possible. If 0, cancel transformation.",
		expl = "transform"
	},
	OPCODE_DAMAGEBONUS: {
		name = "Damage bonus", flags = OPFLAGS_VALUE_ABSOLUTE, cat = "modifiers",
		dest = "Increases damage bonus for next attack. If VALUE_ABSOLUTE is set, set it to X."
	},
	OPCODE_HEALBONUS: {
		name = "Healing bonus", flags = OPFLAGS_VALUE_ABSOLUTE, cat = "modifiers",
		dest = "Increases healing bonus for following heals. If VALUE_ABSOLUTE is set, set it to X."
	},
	OPCODE_INFLICT: {
		name = "Inflict power", flags = OPFLAGS_VALUE_ABSOLUTE, cat = "modifiers",
		dest = "Sets base status inflict% bonus for next attack. If VALUE_ABSOLUTE is set, set it to X."
	},
	OPCODE_INFLICT_B: {
		name = "Inflict bonus", flags = OPFLAGS_VALUE_ABSOLUTE, cat = "modifiers",
		dest = "Increases status inflict% bonus for next attack. If VALUE_ABSOLUTE is set, set it to X."
	},
	OPCODE_CRITMOD: {
		name = "Critical modifier", flags = OPFLAGS_VALUE_ABSOLUTE, cat = "modifiers",
		dest = "Increases critical hit bonus for next attack. If VALUE_ABSOLUTE is set, set it to X."
	},
	OPCODE_ELEMENT: {
		name = "Set element", flags = OPFLAGS_NONE, cat = "modifiers",
		dest = "Sets element of following attacks."
	},
	OPCODE_ELEMENT_WEAK: {
		name = "Set element to weakness", flags = OPFLAGS_NONE, cat = "modifiers",
		dest = "Sets element of following attacks to the one the target is most weak to."
	},
	OPCODE_ELEMENT_RESIST: {
		name = "Set element to resisted", flags = OPFLAGS_NONE, cat = "modifiers",
		dest = "Sets element of following attacks to the one the target is most resistant to."
	},
	OPCODE_MINHITS: {
		name = "Set minimum hits", flags = OPFLAGS_NONE, cat = "modifiers",
		dest = "Sets minimum amount of hits for next attack command. Total number of hits is a random number between min and max."
	},
	OPCODE_MAXHITS: {
		name = "Set maximum hits", flags = OPFLAGS_NONE, cat = "modifiers",
		dest = "Sets minimum amount of hits for next attack command. Total number of hits is a random number between min and max."
	},
	OPCODE_NUMHITS: {
		name = "Set min/max hits", flags = OPFLAGS_NONE, cat = "modifiers",
		dest = "Sets both minimum and maximum amount of hits for the attack, effectively hitting X times."
	},
	OPCODE_NOMISS: {
		name = "No miss", flags = OPFLAGS_NONE, cat = "modifiers",
		dest = "Next attack will never miss."
	},
	OPCODE_IGNORE_DEFS: {
		name = "Ignore defenses", flags = OPFLAGS_NONE, cat = "modifiers",
		dest = "If not 0, sets current attack to ignore guard, barrier or protect.",
		expl = "ignore defenses"
	},
	OPCODE_RANGE: {
		name = "Attack range", flags = OPFLAGS_NONE, cat = "modifiers",
		dest = "Changes attack to ranged if not 0, if 0 remove range property.",
		expl = "%s draw attack rate by %s"
	},
	OPCODE_ENERGY: {
		name = "Energy damage", flags = OPFLAGS_NONE, cat = "modifiers",
		dest = "Changes attack to energy damage if not 0, to kinetic damage if 0.",
		expl = "%s draw attack rate by %s"
	},
	OPCODE_DRAINLIFE: {
		name = "Drain life", flags = OPFLAGS_TARGET_SELF, cat = "modifiers",
		dest = "Sets both minimum and maximum amount of hits for the attack, effectively hitting X times."
	},
	OPCODE_PRINTMSG: {
		name = "Print message", flags = OPFLAGS_NONE, cat = "action",
		dest = "Prints a message, defined in the messages section."
	},
	OPCODE_LINKSKILL: {
		name = "Link skill", flags = OPFLAGS_NONE, cat = "action",
		dest = "Discards current state and runs a new skill. It must be defined in the TID section"
	},
	OPCODE_PLAYANIM: {
		name = "Play animation", flags = OPFLAGS_NONE, cat = "action",
		dest = "Plays animation X. It must be defined in the animations section."
	},
	OPCODE_STOP: {
		name = "Stop", flags = OPFLAGS_NONE, cat = "control",
		dest = "Aborts execution."
	},
	OPCODE_JUMP: {
		name = "Jump to line", flags = OPFLAGS_NONE, cat = "control",
		dest = "Jumps to another line in this skill's code."
	},
	OPCODE_IF_CHANCE: {
		name = "IF_CHANCE", flags = OPFLAGS_NONE, cat = "control",
		dest = "Chance% to execute next line. Otherwise next line is skipped."
	},
	OPCODE_IF_STATUS: {
		name = "IF_STATUS", flags = OPFLAGS_NONE, cat = "control",
		dest = "Execute next line if target has any status affliction. Otherwise next line is skipped."
	},
	OPCODE_IF_ACT: {
		name = "IF_ACT", flags = OPFLAGS_NONE, cat = "control",
		dest = "Execute next line if target has acted this turn. Otherwise next line is skipped."
	},
	OPCODE_IF_DAMAGED: {
		name = "IF_ACT", flags = OPFLAGS_TARGET_SELF, cat = "control",
		dest = "Execute next line if target has received damage this turn. Otherwise next line is skipped."
	},
	OPCODE_IF_HITCHECK: {
		name = "IF_HITCHECK", flags = OPFLAGS_TARGET_SELF, cat = "control",
		dest = "Execute next line if a standard hit check passes. Otherwise next line is skipped."
	},
	OPCODE_IF_CONNECT: {
		name = "IF_CONNECT", flags = OPFLAGS_NONE, cat = "control",
		dest = "Execute next line if last attack function in this skill succeeded. Otherwise next line is skipped."
	},
}

enum { TARGET_GROUP_ALLY, TARGET_GROUP_ENEMY, TARGET_GROUP_BOTH }

const statusInfo = {
	STATUS_NONE : 	{ name = "OK", desc = "restored", color = "00FF88", short = "" },
	STATUS_DOWN : 	{ name = "Incapacitated", desc = "incapacitated", color = "FF0000", short = "DWN" },
	STATUS_STASIS : { name = "Stasis", desc = "put in stasis", color = "440088", short = "STA" },
	STATUS_PARA :		{ name = "Paralysis", desc = "paralized", color = "FFFF00", short = "PAR" },
	STATUS_BLIND:		{ name = "Blind", desc = "blinded", color = "333333", short = "BLI" },
	STATUS_CURSE: 	{ name = "Curse", desc = "cursed", color = "FF00FF", short = "CUR" },
	STATUS_SLEEP: 	{ name = "Sleep", desc = "put to sleep", color = "0000FF", short = "SLP" },
}


class SkillState:
	# Core attack stats #########################
	var hits : Array =            [1, 1]   #Number of hits (min, max)
	var dmgBonus : int =          0        #Damage bonus. Added to attack power.
	var dmgAddRaw : int =         0        #Raw damage to add to attacks.
	var healPow : int =           0        #Healing power
	var healBonus : int =         0        #Healing bonus. Added to healing power.
	var healAddRaw : int =        0        #Raw healing to add to heals.
	var drainLife : int =         0        #Drain life. Percentage.
	var accMod : int =            0        #Accuracy modifier.
	var critMod : int =           0        #Critical modifier.
	var element : int =           0        #Element to use.
	var fieldEffectMult : float = 0.0      #Field effect multiplier.
	var dmgStat : int =           0        #Damage stat.
	var nomiss : bool =           false    #If true, the attack always hits.
	var nocap : bool =            false    #If true, the attack ignores damage cap (32000).
	var energyDMG : bool =        false    #If true, use energy resistance stats on target.
	var ranged : bool =           false    #If true, ignore range penalties and targetting restrictions.
	var ignoreDefs : bool =       false    #If true, ignore special defenses (guard, barrier).
	# Infliction stats ##########################
	var inflictPow : int =        0
	var inflictBonus : int =      0
	# Effect ####################################
	var setEffect : bool =        false    #If true, try to set an effect.
	# Hit record ################################
	var lastHit : bool =          false    #If true, the last attack connected.
	var hitRecord : Array =       []       #Record of last succeeding hits.
	var anyHit : bool =           false    #If true, any of the attacks has connected.
	# Onhit effects #############################
	var combo : Array                      #Data for combo setup.
	var follow : Array                     #Data for followup setup.
	var counter : Array                    #Data for counter setup.
	# Target override ###########################
	var originalTarget =          null     #Keep track of original target.
	# Statistics and output #####################
	var totalHeal : int =         0        #Total amount of healing done this turn.
	var totalAfflictions : int =  0        #Total amount of afflictions caused this turn.
	var finalHeal : int =         0        #Final amount of healing.
	var finalDMG : int =          0        #Final amount of damage.
	# SVAL stack
	var value : int =             0        #Internal data stack.

	func _init(S : Dictionary, level : int, user, target):
		#Initialize values from skill definition
		element = S.element[level]
		fieldEffectMult = S.fieldEffectMult[level]
		dmgStat = S.damageStat
		accMod = S.accMod[level]
		critMod = S.critMod[level]
		energyDMG = S.energyDMG
		ranged = S.ranged[level]
		inflictPow = S.inflictPow[level]
		setEffect = true if (S.category == CAT_SUPPORT and S.effect != EFFECT_NONE) else false
		anyHit = true if S.category == CAT_SUPPORT else false
		combo =   [user, 100, 33, S, level, false, core.stats.ELEMENTS.DMG_UNTYPED]
		follow  = [user, 100, 33, S, level, false, core.stats.ELEMENTS.DMG_UNTYPED]
		counter = [100, 0, S, level, core.stats.ELEMENTS.DMG_UNTYPED, 1, PARRY_ALL]
		originalTarget = target


func translateOpCode(o : String) -> int:
	return opCode[o] if o in opCode else OPCODE_NULL

func hasCodePR(S):
	return true if S.codePR != null else false

func calculateHeal(a, power):
	power = float(power)
	var WIS = float(a.WIS)
	return int( ( (((power * WIS * 2) * 0.0021786) + (power * 0.16667)) ) + ( ((WIS * 2 * 0.010599) * sqrt(power)) * 0.1 ) )

func calculateDamage(a, b, args): #TODO:Fix damage stat
	var ATK : float = float(a.INT if args.energyDMG else a.STR)
	var DEF : float = float(b.WIS if args.energyDMG else b.END)
	var mult : float = 1.0
	var comp : float = DEF / ATK
	var baseDMG : float = 0.0
	var finalDMG : float = 0.0
	if comp > 1.0:
		baseDMG = ((( 1.0 - ((sqrt(sqrt(comp))) * .7)) * (ATK * 3)) - (DEF * .2) * .717 )
	else:
		baseDMG = ((( .3 + (pow((1.0 - comp), 3.0) * 1.7)) * (ATK * 3)) - (DEF * .2) * .717 )
	finalDMG = baseDMG * args.power
	return finalDMG

func checkInflict(a, b, args):
	#TODO:Move to new system. Use X resist attempts with bonus to critical inflict based on luck checks.
	#TODO: This might work better in the char class.
	var effStat = 0
	match args.effStat:
		MODSTAT_INT: effStat = a.INT
		MODSTAT_WIS: effStat = a.WIS
		_:           effStat = a.LUC

	effStat = float(effStat + (a.LUC * 2))
	var comp = ((effStat + 76.5) / ((float(b.LUC) * 3) + 76.5)) * 10
	var rate = 0
	if int(comp) <= 2:           rate = args.power
	elif comp > 2 and comp < 50: rate = args.power * comp
	else:                        rate = args.power * 50
	var finalrate = clamp(rate * 100 * args.mods, 0, 1500) as int
	var rand = randi() % 1000
	if rand <= finalrate: return true
	else: return false

func tryInflict(S, state, value, user, target):
	var a = user.battle.stat
	var b = target.battle.stat
	var args = {
		power = (float(value) * .01) + (float(state.inflictBonus) * .01),
		effStat = S.modStat,
		mods = 1,
	}
	var result = checkInflict(a, b, args)
	if result:
		target.inflict(S.inflict)
		state.totalAfflictions += 1
		return true
	else:
		return false

func calculateCrit(aLUC, bLUC, mods) -> bool:
	var val = (((float(aLUC) + 25) * 100) / (float(bLUC) + 25))
	val = int(clamp(val, 30, 300)) + mods
	var rand = randi() % 1000
	if rand < val: return true
	else: return false

func checkDrawRate(user, target, S):
	if S.category != CAT_ATTACK:
		return target
	var group = target.group
	var finalTarget = target
	for i in group.activeMembers():
		if i.battle.decoy > 0:
			if core.chance(i.battle.decoy) and i.battle.decoy >= finalTarget.battle.decoy and i.filter(S.filter):
				finalTarget = i
	if target != finalTarget:
		print("[SKILL][CHECKDRAWRATE] Attack drawn by %s!" % finalTarget.name)
		msg("But %s attracted the attack!" % finalTarget.name)
	return finalTarget

func checkDrawRateRow(user, targets, S):
	if S.category != CAT_ATTACK:
		return targets
	var group = targets[0].group
	var finalTarget = targets[0]
	for i in group.activeMembers():
		if i.battle.decoy > 0:
			if core.chance(i.battle.decoy / (1 if i.row == targets[0].row else 5)) and i.battle.decoy >= finalTarget.battle.decoy and i.filter(S.filter):
				finalTarget = i
	if finalTarget.row == targets[0].row:
		return targets
	else:
		print("[SKILL][CHECKDRAWRATEROW] Row-wide attack drawn by %s!" % finalTarget.name)
		msg("But %s attracted the attack!" % finalTarget.name)
		return group.getRowTargets(finalTarget.row, S.filter)

func checkHit(a, b, mod):
	var comp = float(((float(a.AGI) * 2.0) + float(a.LUC)) * 10.0) / ((float(b.AGI) * 2) + float(b.LUC))
	var val = 0.0
	var rand = randi() % 1000
	if comp < 10:
		val = (95 + mod * 10) * (1.0 - pow(1.0 - ((sqrt(comp * .1) * 10) * .1), 2))
	else:
		val = (87.5 + (((comp / 20.0) * 50.0) * (comp * 2.5)) * (95 + mod)) * .1
	val += 0 #buff/debuff modifiers
	#print("debug: accuracy check val %s (a.AGI: %s a.LUC: %s b.AGI: %s b.LUC: %s) TS:%s base acc: 95 skill acc: %s random number: %s" % [val, a.AGI, a.LUC, b.AGI, b.LUC, comp, mod, rand])
	val = int(clamp(val, 0, 1500))
	if rand <= val: return true
	else: return false

func calculateHitNumber(hits):
	var val = 0
	if hits[0] != hits[1]: val = hits[0] + randi() % (hits[1] - hits[0])
	else:	val = hits[1]
	return val

func calculateRangedDamage(S, level, user, target) -> float:
	if S.ranged[level]:
		print("Ranged attack, skipping range checks.")
		return 1.0
	else:
		if user.row != 0 or target.row != 0:
			print("Range check: Far, halving damage!")
			return 0.5
		else:
			print("Range check: Melee, normal damage!")
			return 1.0

func calculateFieldMod(elem:int, mult:int) -> float:
	return 1.0 + (core.battle.control.state.field.getBonus(elem) * float(mult))


func checkHitConditions(S, level, user, target, state) -> bool:
	if target.filter(S.filter):
		if state.nomiss: return true
		else: return checkHit(user.battle.stat, target.battle.stat, state.accMod)
	return false


func processAttack(S, level, user, target, state, value, flags):
	#TODO: Prevent extra hits on a downed enemy
	var hitnum : int = calculateHitNumber(state.hits)
	var totalHits : int = 0
	var totalDmg = 0
	var a = user.battle.stat
	var b = target.battle.stat
	var dmg : float = 0.0
	var dmgPercent : float = 0.0
	var dmgPercentTotal : float = 0.0
	var args = null
	var temp = null
	var crit = false
	var field = core.battle.control.state.field.bonus
	var fieldBonus : float = 0.0
	var hitInfo : Array = state.hitRecord
	var inflictInfo : String = ""
	var output : String = ""
	var silent : bool = bool(flags & OPFLAGS_SILENT_ATTACK)
	print("Attack: %05d + %05d = %05d power + %05d raw damage > silent: %s, hit record: %s" % [value, state.dmgBonus, state.dmgBonus + value, state.dmgAddRaw, silent, hitInfo])
	state.lastHit = false

	for i in range(hitnum): #For each attack, check hits individually.
		#if (checkHit(a, b, state.accMod[level]) or state.nomiss == true) and target.status != STATUS_DOWN:
		if checkHitConditions(S, level, user, target, state):
			state.lastHit = true                                                  #It connected. Start processing it.
			dmg = state.dmgBonus + value
			crit = calculateCrit(a.LUC, b.LUC, state.critMod)                         #Check if this individual attack crits.
			args = {
				element = state.element,
				dmgStat = state.dmgStat,                                                #and main damage stat
				power = dmg * .01,                                                      #then apply skill power
				energyDMG = state.energyDMG,                                            #and finish setting kinetic/energy.
			}
			dmg = calculateDamage(a, b, args)                                         #Calculate base damage.
			temp = target.damageResistModifier(dmg, state.element, state.energyDMG)
			dmg = temp[0]
			match temp[1]:                                                            #Check for weakness/resist, 0 if neutral hit.
				1: user.battle.weaknessHits += 1
				2: user.battle.resistedHits += 1
			dmg *= calculateRangedDamage(S, level, user, target)
			if field[args.element] > 0:
				fieldBonus = calculateFieldMod(args.element, state.fieldEffectMult)
				print("Field effect elemental bonus: %s mult: (%s x %s) (%s x %s = %s)" % [field[state.element], core.battle.control.state.field.getBonus(state.element), state.fieldEffectMult, dmg, fieldBonus, fieldBonus*dmg])
				dmg *= fieldBonus
			if crit:                                                                  #Critical hit, x1.5 damage.
				print("Critical hit! (%s x 1.5 = %s)" % [dmg, dmg * 1.5])
				dmg *= 1.5
			totalHits += 1

			dmg = round(dmg)                                                          #Final damage
			dmg = target.finalizeDamage(dmg)
			var overkill = (target.HP - dmg < -(target.maxHealth()/10))

			totalDmg += dmg                                                           #Add to action total
			dmgPercent = (dmg / float(target.maxHealth())) * 100
			dmgPercentTotal += dmgPercent
			state.lastHit = true
			state.anyHit = true
			state.setEffect = true if S.effect != EFFECT_NONE else false
			user.battle.turnDealtDMG += dmg as int
			user.battle.accumulatedDealtDMG += dmg as int

			target.damage(dmg, [crit, overkill, temp[1]], true)                                #Deal the final amount here
			hitInfo.push_back([dmg, crit, overkill, temp[1]])
			if not target.filter(S.filter): #Abort loop if target doesn't fit filter criteria (like being defeated)
				break

			if state.inflictPow > 0 and not silent:
				if tryInflict(S, state, value, user, target):
					inflictInfo = str("[color=#%s]%s[/color] was %s!" % [
						core.battle.control.state.colorName(target), target.name,
						statusInfo[S.inflict].desc
					])
		else:
			target.dodgeAttack(user)
			state.lastHit = false

	if not silent:
		if hitInfo.size() > 1:
			output = str("Hit [color=#%s]%s[/color] %s times for %.2f%% (" % [
				core.battle.control.state.colorName(target), target.name, hitInfo.size(), dmgPercentTotal,
			])
			for i in range(hitInfo.size()):
				output += str("[color=#%s]%s%s[/color]" % [
					core.battle.control.state.msgColors.damage[hitInfo[i][3]], int(hitInfo[i][0]),
					"!" if hitInfo[i][1] else "",
				])
				if i < hitInfo.size() - 1:
					output += " "
			output += str(") damage!")
		elif hitInfo.size() == 1:
			output = str("Hit [color=#%s]%s[/color] for %.2f%%([color=#%s]%s[/color]) damage! %s") % [
				core.battle.control.state.colorName(target), target.name,
				dmgPercentTotal,
				core.battle.control.state.msgColors.damage[hitInfo[0][3]], int(totalDmg),
				"Critical hit!" if crit else "",
			]
		else:
			output = str("Missed [color=#%s]%s[/color]!") % [
				core.battle.control.state.colorName(target), target.name,
			]
		target.display.damage(hitInfo)
		hitInfo = [] #Clear accumulated attack info.

	user.battle.turnHits += totalHits
	state.finalDMG += totalDmg as int

	if state.drainLife > 0:                                                       #Drain life effects
		print("Life drain (%s)" % state.drainLife)
		user.heal(int(float(totalDmg)* (float(state.drainLife) * 0.01)))
		#output += (str(" Drained %s health!" % [int(float(totalDmg)* (float(state.drainLife) * 0.01))]))
	if not silent:
		msg(str(output, " ", inflictInfo))

func processDamageRaw(S, user, target, value, percent) -> int:                 #Cause raw damage to target.
	var dmg := int(0)
	if percent:
		dmg = int(float(target.maxHealth()) * (float(value) * 0.01))
	else:
		dmg = value
	if dmg > 0:                                                                   #TODO: Add damage messages, add a flag to bypass resistances.
		target.damage(dmg, [false, false, MAX_DMG])
	return dmg


func processHeal(S, state, user, target, value:float) -> float:
	var field = core.battle.control.state.field.bonus
	var fieldBonus : float = 0.0
	if state.element > 0:
		fieldBonus = calculateFieldMod(state.element, state.fieldEffectMult)
		print("Field effect elemental bonus : %s (%s x %s = %s)" % [field[state.element], value, fieldBonus, fieldBonus*value])
		value *= fieldBonus
		state.anyHit = true
	return value

func printSkillMsg(S, user, target, value):
	if value == 0:
		return
	else:
		value = value - 1
	if S.messages != null:
		if value <= S.messages.size():
			var m = S.messages[value]
			var args = []
			if m[1] & MSG_USER:
				args.push_back(str("[color=#%s]%s[/color]" % [core.battle.control.state.colorName(user), user.name]))
			if m[1] & MSG_TARGET:
				args.push_back(str("[color=#%s]%s[/color]" % [core.battle.control.state.colorName(target), target.name]))
			if m[1] & MSG_SKILL:
				args.push_back(S.name)
			msg(str(m[0] % args))

func msg(text):
	core.battle.skillControl.echo(text)

func process(S, level, user, _targets, WP = null, IT = null):
	print("[SKILL][PROCESS] %s's action: %s" % [user.name, S.name])
	msg(str("[color=#%s]%s[/color] used %s!" % [core.battle.control.state.colorName(user), user.name, S.name]))
	if _targets.size() == 0: return
	var targets = calculateTarget(S, level, user, _targets)
	if targets != null and targets.size() == 0: return
	match S.category: #TODO:...let's leave it this way for now.
		CAT_ATTACK, CAT_SUPPORT, CAT_OVER:
			core.battle.control.state.lastElement = 0
			processCombatSkill(S, level, user, targets, WP)
	#return SKILL_FAILED

func initSkillState(S, level, user, target):
	return SkillState.new(S, level, user, target)

func processCombatSkill(S, level, user, targets, WP = null, IT = null):
	var temp = null
	var tempTarget = null
	var controlNode = core.battle.skillControl
	var control = null
	var state = null
	user.battle.AD = S.AD[level - 1] #Set active defense on execution regardless of success.
	#print("%s sets Active Defense: %s" % [user.name, user.battle.AD])
	if WP != null:
		user.setWeapon(WP)
	user.charge(false)

	if S.codeST != null: #Has a setup part. Initialize state here, copy for individual targets.
		state = initSkillState(S, level, user, targets[0])
		control = controlNode.start()
		setupSkillCode(S, level, user, targets[0], CODE_ST, control, state)
		yield(control, "skill_end")
	for j in targets: #Start a skill state for every target unless a ST state exists.
		tempTarget = j
		if tempTarget.filter(S.filter): #Target is valid.
			controlNode.startAnim(S.animations[0], tempTarget.display)
			yield(controlNode, "fx_finished") #Wait for animation to finish.
			print("Animation finished")
			control = controlNode.start()
			processSkillCode(S, level, user, tempTarget, CODE_MN, control, state)
			yield(control, "skill_end")
			yield(controlNode.wait(0.1), "timeout")                                   #Small pause for aesthetic reasons.
	if core.battle.control.state.lastElement != 0:
		print("[SKILL][processCombatSkill] Adding element %d to field x%02d" % [core.battle.control.state.lastElement, S.fieldEffectAdd[level]])
		user.group.lastElement = core.battle.control.state.lastElement
		for i in range(S.fieldEffectAdd[level]):
			core.battle.control.state.field.push(core.battle.control.state.lastElement)
	#Check chains. TODO: Get info about last action to see if it hit or not.
	print("[SKILL] Checking chains...", S.chain, " ", user.battle.chain)
	if user.battle.chain > 0:
		if S.chain in [CHAIN_STARTER_AND_FOLLOW, CHAIN_FOLLOW]:
			print("[SKILL] Chain start!")
			user.battle.chain += 1
	elif user.battle.chain == 0:
		if S.chain in [CHAIN_STARTER, CHAIN_STARTER_AND_FOLLOW]:
			print("[SKILL] Chain up!")
			user.battle.chain = 1
	if S.chain == CHAIN_FINISHER:
		print("[SKILL] Chain finished!")
		user.battle.chain = 0
	controlNode.finish()

func processSubSkill(S, level, user, target, control = core.battle.skillControl.start()):
	var controlNode = core.battle.skillControl
	if target.filter(S.filter):
		print("Starting subskill: %s" % S.name)
		controlNode.startAnim(S.animations[0], target.display)
		yield(controlNode, "fx_finished") #Wait for animation to finish.
		print("Animation finished")
		processSkillCode(S, level, user, target, CODE_MN, control)
		yield(control, "skill_end")
		print("[processSubSkill] control check")
	else:
		print("Subskill failed to filter. Little pause and back to action.")
		yield(controlNode.wait(0.5), "timeout")

func processPR(S, level, user):
	print("%s's action PR: %s" % [user.name, S.name])
	var control = core.battle.skillControl.start()
	processSkillCode(S, level, user, user, CODE_PR, control)
	yield(control, "skill_end")
	print("PR CODE FINISH")
	core.battle.skillControl.finish()

func processEF(S, level, user, target):
	print("%s's action EF: %s" % [user.name, S.name])
	var control = core.battle.skillControl.start()
	processSkillCode(S, level, user, target, CODE_EF, control)
	yield(control, "skill_end")
	print("EF CODE FINISH")
	#core.battle.skillControl.finish()


func processFL(S, level, user, target, data, type):
	print("%s's action FL on %s => %s LV%d" % [user.name, target.name, S.name, level])
	match type:
		FOLLOW_FOLLOWUP, FOLLOW_COMBO:
			msg("[color=#%s]%s[/color] followed with %s!%s" % [
				core.battle.control.state.colorName(user),
				user.name, S.name,
				(" [color=#888888](next %03d%%)[/color]" % data[0]) if data[0] > 0 else ""
				])
		FOLLOW_COUNTER:
			msg("[color=#%s]%s[/color] countered with %s!%s" % [
				core.battle.control.state.colorName(user),
				user.name, S.name,
				(" [color=#888888](next %03d%%)[/color]" % data[0]) if data[1] > 0 else ""
				])
	yield(core.battle.skillControl.wait(0.1), "timeout")
	var control = core.battle.skillControl.start()
	core.battle.skillControl.startAnim(S.animations[0], target.display)
	yield(core.battle.skillControl, "fx_finished")
	print("FL ANIMATION FINISHED")
	processSkillCode(S, level, user, target, CODE_FL, control)
	yield(control, "skill_end")
	print("FL CODE FINISH")
	core.battle.skillControl.finish()

func processED(S, level, user, target):
	print("%s's action ED: %s" % [user.name, S.name])
	var control = core.battle.skillControl.start()
	processSkillCode(S, level, user, target, CODE_ED, control)
	yield(control, "skill_end")
	print("ED CODE FINISH")
	core.battle.skillControl.finish()

func selectTargetAuto(S, level, user, state):
	var side = 0 if S.targetGroup == TARGET_GROUP_ALLY else 1
	var temp = null
	match S.target[level]:
		TARGET_SELF:
			return [ user ]
		TARGET_ALL_NOT_SELF,TARGET_ALL:
			return state.formations[side].getAllTargets(S.filter)
		TARGET_SELF_ROW_NOT_SELF,TARGET_SELF_ROW:
			return state.formations[side].getRowTargets(user.row, S.filter)
		TARGET_SINGLE, TARGET_SPREAD:
			temp = state.formations[side].getAllTargets(S.filter)
			if temp.size() == 1:
				return temp
			else:
				return null
		_:
			return null

func calculateTarget(S, level, user, _targets):
	var targets = []
	var finalTargets = []
	var temp = null
	match S.target[level]:
		TARGET_SELF: #Target is user. Nothing special needed.
			targets.push_front(user)
		TARGET_SINGLE, TARGET_SINGLE_NOT_SELF, TARGET_SPREAD:
			if _targets[0].filter(S.filter):
				temp = checkDrawRate(user, _targets[0], S)
				targets.push_front(temp)
			else: #Target didn't pass filter criteria, meaning it's changed since selection.
				if S.category == CAT_ATTACK: #In the case of attacks, pick another target.
					print("Target didn't match filter, picking another target...")
					var newtarget = _targets[0].group.getRandomTarget(S.filter)
					if newtarget != null and newtarget[0] != null:
						targets.push_front(newtarget[0])
						print("New target is %s" % newtarget[0].name)
					else:
						print("No suitable targets for %s found, skill fails." % S.name)
		TARGET_ROW:
			temp = checkDrawRateRow(user, _targets, S)
			for i in temp:
				if i.filter(S.filter):
					targets.push_front(i)
		TARGET_SELF_ROW, TARGET_SELF_ROW_NOT_SELF:
			targets = user.group.getRowTargets(user.row, S.filter)
		TARGET_ALL, TARGET_ALL_NOT_SELF, TARGET_RANDOM1, TARGET_RANDOM2:
			for i in range(_targets.size()):
				if _targets[i].filter(S.filter):
					targets.push_front(_targets[i])
	match S.target: #Second pass to remove user from certain targettings.
		TARGET_ALL_NOT_SELF,TARGET_SELF_ROW_NOT_SELF:
			targets.erase(user)

	for i in targets:
		var T = i.checkProtect(S)
		if T[0]:
			msg("But [color=#%s]%s[/color] protected %s!" % [core.battle.control.state.colorName(T[1]), T[1].name, i.name])
			finalTargets.push_back(T[1])
		else:
			finalTargets.push_back(i)
	return finalTargets

func addEffect(S, level, user, target, state):
	target.addEffect(S, level, user)

func factoryLine(opcode, val, flags) -> Array:
	var result = core.newArray(12)
	result[0] = int(opcode)
	for i in range(1, 11):
		result[i] = int(val)
	result[11] = int(flags)
	return result

func factory(Sp, mods, level): #Sp is a pointer to skill copy
	if mods != null:
		Sp.name += "+"
		for i in mods:
			print("[SKILLFACTORY] %s on %s" % [i, Sp.name])
			match(i):
				"fieldEffectMult":
					for j in range(MAX_LEVEL):
						Sp.fieldEffectMult[j] += mods.fieldEffectMult[level]
					print("[SKILLFACTORY] Field effect multiplier increased by %s (total %s)" % [mods.fieldEffectMult[level], Sp.fieldEffectMult])
				"fieldEffectAdd":
					for j in range(MAX_LEVEL):
						Sp.fieldEffectAdd[j] += mods.fieldEffectAdd[level]
					print("[SKILLFACTORY] Field effect element charge increased by %s (total %s)" % [mods.fieldEffectAdd[level], Sp.fieldEffectAdd])
				"ranged":
					if mods.ranged[level] != 0:
						for j in range(MAX_LEVEL):
							if Sp.ranged[j] != 0:
								Sp.ranged[j] = mods.ranged[level]
					print("[SKILLFACTORY] Set range to %s" % ['ranged' if mods.ranged[level] != 0 else 'melee'])
				"accMod":
					for j in range(MAX_LEVEL):
						Sp.accMod[j] = int( float(Sp.accMod[j]) * (float(mods.accMod[level]) * .01) )
					print("[SKILLFACTORY] Accuracy modified by %s%% (total %s)" % [mods.accMod[level], Sp.accMod])
				"spdMod":
					for j in range(MAX_LEVEL):
						Sp.spdMod[j] = int( float(Sp.spdMod[j]) * (float(mods.spdMod[level]) * .01) )
					print("[SKILLFACTORY] Speed modified by %s%% (total %s)" % [mods.spdMod[level], Sp.spdMod])
				"initAD":
					for j in range(MAX_LEVEL):
						Sp.initAD[j] = int( float(Sp.initAD[j]) * (float(mods.initAD[level]) * .01) )
					print("[SKILLFACTORY] Initial Active Defense modified by %s%% (total %s)" % [mods.initAD[level], Sp.initAD])
				"AD":
					for j in range(MAX_LEVEL):
						Sp.AD[j] = int( float(Sp.AD[j]) * (float(mods.AD[level]) * .01) )
					print("[SKILLFACTORY] Active defense modified by %s%% (total %s)" % [mods.AD[level], Sp.AD])
				"power":
					print("[SKILLFACTORY] power +%s%%" % mods.power[level])
					for j in Sp.codeMN:
						if j[0] in opCodesPowerable:
							print("[SKILLFACTORY] found powerable opcode %s in MN." % [j[0]])
							for ii in range(1, 11):
								j[ii] = int(  float(j[ii]) * (float(mods.power[level]) * .01) )
							print("[SKILLFACTORY] result %s" % str(j))
				"lifeDrain":
					print("[SKILLFACTORY] lifeDrain +%s" % mods.lifeDrain[level])
					var drain = -1
					for j in range(Sp.codeMN.size()):
						if Sp.codeMN[j][0] == OPCODE_DRAINLIFE:
							drain = j
					if drain > -1: #Found an existing drainLife code, modify it
						print("[SKILLFACTORY] Skill already drains life, adding to it.")
						for ii in range(1, 11):
							Sp.codeMN[drain][ii] += mods.lifeDrain[level]
						print(Sp.codeMN)
					else:
						print("[SKILLFACTORY] Prepending drain life opcode to skill.")
						Sp.codeMN.push_front([OPCODE_DRAINLIFE, mods.lifeDrain[level],mods.lifeDrain[level], mods.lifeDrain[level], mods.lifeDrain[level], mods.lifeDrain[level], mods.lifeDrain[level], mods.lifeDrain[level], mods.lifeDrain[level], mods.lifeDrain[level], mods.lifeDrain[level], 0])
						print(Sp.codeMN)
				"merciless":
					print("[SKILLFACTORY] Damage increased if enemy is afflicted +%s" % mods.merciless[level])
					var line = -1
					var OK = false
					for j in range(Sp.codeMN.size()):
						if Sp.codeMN[j][0] == OPCODE_IF_STATUS:
							line = j
						if line > -1 and Sp.codeMN[j][0] == OPCODE_DAMAGEBONUS:
							line = j
							OK = true
					if OK: #Damage bonus if afflicted exists. Increase damage bonus.
						print("[SKILLFACTORY] Skill already has a damagebonus on inflict conditional. Modifying it.")
						for ii in range(1, 11):
							Sp.codeMN[line][ii] += mods.merciless[level]
						print(Sp.codeMN)
					else:
						print("[SKILLFACTORY] Prepending conditional code to increase damagebonus on inflict.")
						Sp.codeMN.push_front(factoryLine(OPCODE_DAMAGEBONUS, mods.merciless[level], 0))
						Sp.codeMN.push_front(factoryLine(OPCODE_IF_STATUS, 0, 0))
						print(Sp.codeMN)
				"target":
					print("[SKILLFACTORY] spread %s" % mods.target[level])
					for j in range(MAX_LEVEL):
						match(mods.target[level]):
							#TODO: This works under the assumption that all dgems are single target.
							'spread':
								for ii in range(10):
									if Sp.target[ii] == TARGET_SINGLE: Sp.target[ii] = TARGET_SPREAD
							'row':
								for ii in range(10):
									if Sp.target[ii] == TARGET_SINGLE: Sp.target[ii] = TARGET_ROW
							'all':
								for ii in range(10):
									if Sp.target[ii] == TARGET_SINGLE: Sp.target[ii] = TARGET_ALL
				"numhits":
					print("[SKILLFACTORY] Number of hits +%s" % mods.numhits[level])
					var line = -1
					for j in range(Sp.codeMN.size()):
						if Sp.codeMN[j][0] == OPCODE_NUMHITS:
							line = j
					if line > -1: #Found an existing OPCODE_NUMHITS, modify it.
						print("[SKILLFACTORY] Skill already has an OPCODE_NUMHITS")
						for ii in range(1, 11):
							Sp.codeMN[line][ii] += mods.numhits[level]
					else:
						print("[SKILLFACTORY] Prepending OPCODE_NUMHITS opcode to skill.")
						Sp.codeMN.push_front(factoryLine(OPCODE_NUMHITS, mods.numhits[level], 0))
						print(Sp.codeMN)
				"ignoreDefs":
					print("[SKILLFACTORY] Ignore defenses %s" % mods.ignoreDefs[level])
					var line = -1
					for j in range(Sp.codeMN.size()):
						if Sp.codeMN[j][0] == OPCODE_IGNORE_DEFS:
							line = j
					if line > -1: #Found an existing OPCODE_IGNORE_DEFS, modify it.
						print("[SKILLFACTORY] Skill already has an OPCODE_IGNORE_DEFS")
						for ii in range(1, 11):
							Sp.codeMN[line][ii] += mods.ignoreDefs[level]
					else:
						print("[SKILLFACTORY] Prepending OPCODE_IGNORE_DEFS opcode to skill.")
						Sp.codeMN.push_front(factoryLine(OPCODE_IGNORE_DEFS, mods.ignoreDefs[level], 0))
						print(Sp.codeMN)
				"exp_bonus":
					print("[SKILLFACTORY] EXP bonus +%s%%" % mods.exp_bonus[level])
					var line = -1
					for j in range(Sp.codeMN.size()):
						if Sp.codeMN[j][0] == OPCODE_EXP_BONUS:
							line = j
					if line > -1: #Found an existing EXP bonus code, modify it.
						print("[SKILLFACTORY] Skill already has an EXP bonus, adding to it.")
						for ii in range(1, 11):
							Sp.codeMN[line][ii] += mods.exp_bonus[level]
					else:
						print("[SKILLFACTORY] Prepending EXP bonus opcode to skill.")
						Sp.codeMN.push_front(factoryLine(OPCODE_EXP_BONUS, mods.exp_bonus[level], 0))
						print(Sp.codeMN)
				"chargeAnim":
					for j in range(MAX_LEVEL):
						Sp.chargeAnim[j] = int( mods.chargeAnim[level] )
					print("[SKILLFACTORY] Charge animation changed to %d" % [mods.chargeAnim[level]])
				"combo":
					print("[SKILLFACTORY] [!TODO!] Prepending OPCODE_COMBO stuff to %d" % [mods.combo[level]])
				"element":
					for j in range(MAX_LEVEL):
						Sp.element[j] = int( mods.element[level] )
					print("[SKILLFACTORY] Element changed to %s" % [mods.element[level]])

func getSpeedMod(tid):
	#TODO: Shouldn't this take just a skill pointer instead?
	var S = core.lib.skill.getIndex(tid)
	return S.spd

func setupSkillCode(S, level, user, target, _code, control, state):#TODO: unify all these functions.
	processSkillCode2(S, level, user, target, _code, state, control)
	yield(control, "skill_continue")
	print("*skill_continue received for %s, checking effects*" % S.name)
	if state.setEffect and _code == CODE_MN:
		print("Effect from %s " % [S.name])
		addEffect(S, level, user, target, state)
		state.anyHit = true
	print("[%s] Setup finished" % S.name)
	control.stop()
	print("[%s] Setup stopped" % S.name)

func processSkillCode(S, level, user, target, _code, control = core.battle.skillControl.start(), setState = null):
	var state = initSkillState(S, level, user, target) if setState == null else setState.duplicate()
	processSkillCode2(S, level, user, target, _code, state, control)
	yield(control, "skill_continue")
	print("[SKILL][PROCESSSKILLCODE] skill_continue received for %s, checking effects" % S.name)
	if state.setEffect and _code == CODE_MN:
		print("Effect from %s " % [S.name])
		addEffect(S, level, user, target, state)
		msg("%s was affected!" % [target.name])
		state.anyHit = true

	print("[SKILL][processSkillCode] Hit record:\n", state.hitRecord)

# Post skill actions ##################################################################################
# TODO: Post skill actions should be renamed.
# Combo should be chain, follow should be combo, and chain should be follow.
# For consistency.
	if state.anyHit and _code in [CODE_MN, CODE_FL]: #Proc on hit actions.
		core.battle.control.state.lastElement = state.element                 #Store last element for later
		if S.target[level] == TARGET_SPREAD:	#Spread damage
			if state.finalDMG > 0: #TODO: Do this with healing too!
				var spread = target.group.getSpreadTargets(target.row, S.filter, target.slot)
				if spread.size() > 0:
					msg("Spreaded %d damage!" % [state.finalDMG / 2])
					for i in spread:
						print("[SKILL][PROCESSSKILLCODE] Spreading %d damage to %s" % [state.finalDMG / 2, i.name])
						i.damage(state.finalDMG / 2, [false, false, 0])
		target.updateFollows() #Update target's followup actions, purge excess ones etc.
		if user.battle.follow.size() > 0 and S.category == CAT_ATTACK: #User following with another skill.
			for i in user.battle.follow:
				if i[5] == 0 or (i[5] == state.element):
					if user.canFollow(i[3], i[4], target) and user != target and core.chance(i[1]):
						i[1] -= i[2]
						core.battle.control.state.follows.push_back([target, i, FOLLOW_FOLLOWUP])
		if target.battle.combo.size() > 0 and S.category == CAT_ATTACK: #Target has a combo set.
			for i in target.battle.combo:
				if i[5] == 0 or (i[5] == state.element):
					if i[0].canFollow(i[3], i[4], target) and user != i[0] and core.chance(i[1]):
						i[1] -= i[2]
						core.battle.control.state.follows.push_back([target, i, FOLLOW_COMBO])
		#Check for counters.
		var C = target.canCounter(user, state.element, state.counter)
		if C[0] and S.category == CAT_ATTACK:
			core.battle.control.state.follows.push_back([user, C[1], FOLLOW_COUNTER])


	if state.follow[5]: #Set follow parameters. User will add one skill (CODE_FL) after their next action.
		print("[SKILL][PROCESSSKILLCODE] %s set to follow with params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [target.name, state.follow[0].name, state.follow[1], state.follow[2], str(state.follow[3].name), state.follow[4], state.follow[6]])
		target.battle.follow.push_front([target, state.follow[1], state.follow[2], state.follow[3], state.follow[4], state.follow[6]])

	if state.anyHit: #Set combo parameters. When target is hit, make the one who set the follow add one skill (CODE_FL) after this action.
		if state.combo[5]:
			print("[SKILL][PROCESSSKILLCODE] %s set to combo with params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [target.name, state.combo[0].name, state.combo[1], state.combo[2], str(state.combo[3].name), state.combo[4], state.combo[6]])
			target.battle.combo.push_front([state.combo[0], state.combo[1], state.combo[2], state.combo[3], state.combo[4], state.combo[6]])

	print("[SKILL][PROCESSSKILLCODE] %s finished" % S.name)
	control.stop()
	print("[SKILL][PROCESSSKILLCODE] %s control stopped" % S.name)

func processSkillCode2(S, level, user, target, _code, state, control):
	level = 1                                                                     #TODO: Remember this is here...
	var a = user.battle.stat
	var b = target.battle.stat
	var code = null
	var controlNode = core.battle.skillControl

	yield(controlNode.wait(0.0001), "timeout") #Wait a little bit so the yield in processSkillCode() can wait.

	match _code:
		CODE_MN: code = S.codeMN
		CODE_PR: code = S.codePR
		CODE_EF: code = S.codeEF
		CODE_ED: code = S.codeED
		CODE_ST: code = S.codeST
		CODE_FL: code = S.codeFL

	if code == null:
		print("[%s] No skill code %02d found. Taking no action." % [S.name, _code])
		if S.effect != EFFECT_NONE:
			print("[%s] Provides an effect. Performing accuracy check." % S.name)
			if state.nomiss or checkHit(a, b, state.accMod):
				state.setEffect = true
				print(" Accuracy check passed.")
			else:
				state.setEffect = false
				print(" Accuracy check failed.")
		print("[%s] Code processing finished. Emitting skill_continue signal" % S.name)
		control.continueSkill()
	else:

		var line = null
		var skipLine = false
		var cond_block = false
		var dmg = 0
		var args = null
		var flags = null

		var variableTarget = target
		var b2 = b

		var value = 0

		var scriptSize = code.size()
		for j in range(scriptSize):
			line = code[j]
			value = line[level]
			flags = line[11]
			print("[%s]%02d>OPCODE:%03d VALUE:%03d(LV%02d) FLAGS:%03d [SVAL:%d]" % [S.name, j, line[0], value, level, flags, state.value])

			#Check if current line overrides target to self for compatible funcs.
			if flags & OPFLAGS_TARGET_SELF:
				variableTarget = user
				b2 = a
			else:
				variableTarget = target
				b2 = b
			#Check if current line overrides value.
			if flags & OPFLAGS_USE_SVAL:
				print("%02d> USING STORED VALUE [sval = %s]) INSTEAD OF PROVIDED VALUE (%s) ##" % [j, state.value, value])
				value = state.value

			if not skipLine:
				match line[0]:

# Standard combat functions ####################################################
					OPCODE_ATTACK:
						print(">ATTACK(%s)" % value)
						processAttack(S, level, user, target, state, value, flags)
					OPCODE_FORCE_INFLICT:
						print(">INFLICT(%s)" % value)
						args = {
							power = (float(value) * .01) + state.inflictBonus,
							effStat = S.modStat,
							mods = 1,
						}
						dmg = checkInflict(a, b, args)
						if dmg:
							dmg = target.inflict(S.inflict)
							msg(str("%s %s %s!" % [user.name, statusInfo[S.inflict].desc, target.name]))
							state.totalAfflictions += 1
					OPCODE_DAMAGERAW:
						print(">RAW DAMAGE: %s" % value)
						state.finalDMG += processDamageRaw(S, user, variableTarget, value, true if flags & OPFLAGS_VALUE_PERCENT else false)
# Chains and follows ###########################################################
					OPCODE_FOLLOW:
						print(">FOLLOW SET: %s" % value)
						state.follow[5] = true
						print("Follow params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [state.follow[0].name, state.follow[1], state.follow[2], str(state.follow[3].name), state.follow[4], state.follow[6]])
					OPCODE_FOLLOW_DECREMENT:
						print(">FOLLOW DECREMENT: %s" % value)
						state.follow[2] = int(value)
						print("Follow params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [state.follow[0].name, state.follow[1], state.follow[2], str(state.follow[3].name), state.follow[4], state.follow[6]])
					OPCODE_FOLLOW_ELEMENT:
						print(">FOLLOW ELEMENT: %s" % value)
						state.follow[6] = int(value) if value > 0 else state.element
						print("Follow params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [state.follow[0].name, state.follow[1], state.follow[2], str(state.follow[3].name), state.follow[4], state.follow[6]])
					OPCODE_COMBO:
						print(">COMBO SET: %s" % value)
						state.combo[5] = true
						print("Combo params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [state.combo[0].name, state.combo[1], state.combo[2], str(state.combo[3].name), state.combo[4], state.combo[6]])
					OPCODE_COMBO_DECREMENT:
						print(">COMBO DECREMENT: %s" % value)
						state.combo[2] = int(value)
						print("Combo params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [state.combo[0].name, state.combo[1], state.combo[2], str(state.combo[3].name), state.combo[4], state.combo[6]])
					OPCODE_COMBO_ELEMENT:
						print(">COMBO ELEMENT: %s" % value)
						state.combo[6] = int(value) if value > 0 else state.element
						print("Combo params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [state.combo[0].name, state.combo[1], state.combo[2], str(state.combo[3].name), state.combo[4], state.combo[6]])
# Counters #####################################################################
					OPCODE_COUNTER_DECREMENT:
						print(">COUNTER DECREMENT: %s" % value)
						state.counter[1] = int(value)
					OPCODE_COUNTER_MAX:
						print(">COUNTER MAX AMOUNT: %s" % value)
						state.counter[5] = int(value)
					OPCODE_COUNTER_ELEMENT:
						print(">COUNTER ELEMENT: %s" % value)
						state.counter[4] = int(value)
					OPCODE_COUNTER_FILTER:
						print(">COUNTER FILTER: %s" % value)
						state.counter[6] = int(value)
					OPCODE_COUNTER:
						print(">COUNTER SET: %s" % value)
						state.counter[0] = int(value)
						for i in range(7):
							variableTarget.battle.counter[i] = state.counter[i]
# Chains #######################################################################
					OPCODE_CHAIN_START:
						print(">CHAIN START: %s" % value)
						if variableTarget.battle.chain == 0:
							print("Starting chain!")
							variableTarget.battle.chain = 1
						else:
							print("Chain already started! No action taken.")
					OPCODE_CHAIN_FOLLOW:
						print(">CHAIN FOLLOW: %s" % value)
						if variableTarget.battle.chain > 0:
							print("Following chain! Adding %d" % [value])
							variableTarget.battle.chain += value
						else:
							print("Chain not started! No action taken.")
					OPCODE_CHAIN_FINISH:
						print(">CHAIN FINISH: %s" % value)
						if variableTarget.battle.chain > 0:
							print("Finishing chain!")
							variableTarget.battle.chain = 0
						else:
							print("Chain not started! No action taken.")
# Healing functions ############################################################
					OPCODE_HEAL:
						print(">HEAL(%s)" % value)
						dmg = 0
						if flags & OPFLAGS_HEAL_BONUS:
							dmg = calculateHeal(a, state.healBonus)
							print("Bonus healing: %s" % [dmg])
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							dmg += value
						elif flags & OPFLAGS_VALUE_PERCENT:
							dmg += 999 #TODO: Heal X%
						else:
							dmg += calculateHeal(a, value)
						dmg = processHeal(S, state, user, target, dmg)
						dmg = round(dmg)
						variableTarget.heal(dmg)
						state.totalHeal += dmg
						if variableTarget == user:
							msg(str("%s restored %s!" % [user.name, dmg]))
						else:
							msg(str("%s restored %s to %s!" % [user.name, dmg, target.name]))
					OPCODE_HEALROW:
						print(">HEALROW(%s)" % value)
						dmg = 0
						if flags & OPFLAGS_HEAL_BONUS:
							dmg = calculateHeal(a, state.healBonus)
							print("Bonus healing: %s" % [dmg])
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							dmg += value
						elif flags & OPFLAGS_VALUE_PERCENT:
							dmg += 999 #TODO: Heal X%
						else:
							dmg += calculateHeal(a, value)
						var temptargets = user.group.getRow(user.row, user.group.ROW_SIZE)
						for i in temptargets:
							dmg = processHeal(S, state, user, i, dmg)
							i.heal(dmg)
							state.totalHeal += dmg
					OPCODE_HEALALL:
						print(">HEALALL(%s)" % value)
						dmg = 0
						if flags & OPFLAGS_HEAL_BONUS:
							dmg = calculateHeal(a, state.healBonus)
							print("Bonus healing: %s" % [dmg])
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							dmg += value
						elif flags & OPFLAGS_VALUE_PERCENT:
							dmg += 999 #TODO: Heal X%
						else:
							dmg += calculateHeal(a, value)
						var temptargets = user.group.activeMembers()
						for i in temptargets:
							dmg = processHeal(S, state, user, i, dmg)
							i.heal(dmg)
							state.totalHeal += dmg
					OPCODE_CURE:
						print(">CURE(%s)" % value)
					OPCODE_RESTOREPART:
						print(">RESTORE PART: %s" % value)
					OPCODE_REVIVE:
						print(">REVIVE: %s" % value)
					OPCODE_OVERHEAL:
						print(">OVERHEAL: %s" % value)
# Standard effect functions ####################################################
					OPCODE_AD:
						print(">ACTIVE DEFENSE(%s)" % value)
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							variableTarget.battle.AD = value
						else:
							variableTarget.battle.AD += value
						print("Total: %s" % variableTarget.battle.AD)
					OPCODE_DECOY:
						print(">DECOY(%s)" % value)
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							variableTarget.battle.decoy = value
						else:
							variableTarget.battle.decoy += value
						print("Total: %s" % variableTarget.battle.decoy)
					OPCODE_BARRIER:
						print(">BARRIER(%s)" % value)
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							variableTarget.battle.barrier = value
						else:
							variableTarget.battle.barrier += value
						print("Total: %s" % variableTarget.barrier)
					OPCODE_GUARD:
						print(">GUARD(%s)" % value)
						if flags & OPFLAGS_VALUE_PERCENT: dmg = int(float(variableTarget.maxHealth()) * (float(value) * 0.01))
						else: dmg = value
						if flags & OPFLAGS_VALUE_ABSOLUTE: variableTarget.battle.guard = dmg
						else: variableTarget.battle.guard += dmg
						print("Total: %s" % variableTarget.battle.guard)
					OPCODE_PROTECT:
						print(">PROTECT(%s)" % value)
						if flags & OPFLAGS_TARGET_SELF:
							user.battle.protectedBy.push_back([target, value])
							print("%s protects %s (%s%%)" % [target.name, user.name, value])
						else:
							target.battle.protectedBy.push_back([user, value])
							print("%s protects %s (%s%%)" % [user.name, target.name, value])
					OPCODE_RAISE_OVER:
						print(">RAISE OVER: %s" % value)
						if "over" in variableTarget:
							variableTarget.over += value
						print("Total: %s" % variableTarget.over)
# State modifiers ##############################################################
					OPCODE_DAMAGEBONUS:
						print(">DAMAGE BONUS: %s" % value)
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							state.dmgBonus = value
						else:
							state.dmgBonus += value
						print("Total: %s" % state.dmgBonus)
					OPCODE_HEALBONUS:
						print(">HEAL BONUS: %s" % value)
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							state.healBonus = value
						else:
							state.healBonus += value
						print("Total: %s" % state.healBonus)
					OPCODE_INFLICT:
						print(">INFLICT: %s" % value)
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							state.inflictPow = value
						else:
							state.inflictPow += value
						print("Total: %s" % state.inflictPow)
					OPCODE_INFLICT_B:
						print(">INFLICT BONUS: %s" % value)
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							state.inflictBonus = value
						else:
							state.inflictBonus += value
						print("Total: %s" % state.inflictBonus)
					OPCODE_CRITMOD:
						print(">CRITMOD: %s" % value)
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							state.critMod = value
						else:
							state.critMod += value
					OPCODE_ELEMENT:
						print(">ELEMENT: %s" % value)
						state.element = value
						print("Element set to %s" % core.stats.ELEMENT_CONV[state.element])
					OPCODE_ELEMENT_WEAK:
						print(">[INDEV]ELEMENT TO TARGET WEAKNESS[!]")
					OPCODE_ELEMENT_RESIST:
						print(">[INDEV]ELEMENT TO TARGET RESIST[!]")
					OPCODE_MINHITS:
						print(">MINHITS: %s" % value)
						state.hits[0] = value
						if state.hits[0] > state.hits[1]:
							state.hits[0] = state.hits[1]
						print("HITS: %s-%s" % [state.hits[0], state.hits[1]])
					OPCODE_MAXHITS:
						print(">MAXHITS: %s" % value)
						state.hits[1] = value
						if state.hits[1] < state.hits[0]:
							state.hits[1] = state.hits[0]
						print("HITS: %s-%s" % [state.hits[0], state.hits[1]])
					OPCODE_NUMHITS:
						print(">NUMHITS: %s" % value)
						state.hits[0] = value
						state.hits[1] = value
						print("HITS: %s-%s" % [state.hits[0], state.hits[1]])
					OPCODE_NOMISS:
						print(">NOMISS: %s" % value)
						state.nomiss = true if value != 0 else false
					OPCODE_NOCAP:
						print(">NO DAMAGE CAP: %s" % value)
						state.nocap = true if value != 0 else false
					OPCODE_IGNORE_DEFS:
						print(">IGNORE DEFS: %s" % value)
						state.ignoreDefs = bool(value)
					OPCODE_RANGE:
						print(">RANGE: %s" % value)
						state.ranged = bool(value)
					OPCODE_ENERGY:
						print(">ENERGY DMG: %s" % value)
						state.energyDMG = bool(value)
					OPCODE_DRAINLIFE:
						print(">DRAIN LIFE: %s" % value)
						if flags & OPFLAGS_VALUE_ABSOLUTE:
							state.drainLife = value
						else:
							state.drainLife += value
						print("TOTAL DRAIN: %s" % state.drainLife)
# Field control ################################################################
					OPCODE_FIELD_PUSH:
						print(">ELEMENTFIELD PUSH: %s" % value)
						core.battle.control.state.field.push(state.element if value == 0 else value)
					OPCODE_FIELD_FILL:
						print(">ELEMENTFIELD FILL: %s" % value)
						core.battle.control.state.field.fill(value)
					OPCODE_FIELD_REPLACE:
						print(">ELEMENTFIELD REPLACE: %s" % value)
						core.battle.control.state.field.replace(value, state.element)
					OPCODE_FIELD_REPLACE2:
						print(">ELEMENTFIELD REPLACE2: %s" % value)
						core.battle.control.state.field.replaceChance2(state.element, value)
					OPCODE_FIELD_RANDOMIZE:
						print(">ELEMENTFIELD RANDOMIZE: %s" % value)
						core.battle.control.state.field.randomize(value)
					OPCODE_FIELD_OPTIMIZE:
						print(">ELEMENTFIELD OPTIMIZE: %s" % value)
						core.battle.control.state.field.optimize()
					OPCODE_FIELD_CONSUME:
						print(">ELEMENTFIELD CONSUME")
						core.battle.control.state.field.consume(state.element if value == 0 else value)
					OPCODE_FIELD_LOCK:
						print(">ELEMENTFIELD LOCK FOR: %s" % value)
						core.battle.control.state.field.lock(value)
					OPCODE_FIELD_UNLOCK:
						print(">ELEMENTFIELD UNLOCK")
						core.battle.control.state.field.unlock()
					OPCODE_FIELD_GDOMINION:
						print(">ELEMENTFIELD G-DOMINION[!]")
						core.battle.control.state.field.setHyper(1)
					OPCODE_FIELD_SETLASTELEM:
						print(">ELEMENTFIELD SET ELEMENT TO LAST")
						state.element = core.battle.control.state.field.data[core.battle.control.state.field.FIELD_EFFECT_SIZE]
						print("CURRENT ELEMENT: %s" % state.element)
					OPCODE_FIELD_SETDOMIELEM:
						print(">ELEMENTFIELD SET ELEMENT TO DOMINANT")
						state.element = core.battle.control.state.field.dominant
						print("CURRENT ELEMENT: %s" % state.element)
					OPCODE_FIELD_ELEMBLAST:
						print(">[INDEV]ELEMENTFIELD ELEMBLAST[!]")
					OPCODE_FIELD_MULT:
						print(">ELEMENTFIELD SET DAMAGE MULTIPLIER: %s" % value)
						state.fieldEffectMult = value
						print("Current multiplier = %s" % state.fieldEffectMult)
# Actions ######################################################################
					OPCODE_PRINTMSG:
						print(">PRINT MESSAGE: %s" % value)
						printSkillMsg(S, user, target, value)
						yield(controlNode.wait(0.1), "timeout")
					OPCODE_LINKSKILL:
						print(">LINK TO SKILL: %s" % value)
						if value > 0:
							var S2 = core.getSkillPtr(S.linkSkill[value - 1])
							var control2 = controlNode.start()
							print("Linking to %s" % S2.name)
							processSubSkill(S2, level, user, target, control2)
							yield(control2, "skill_end")
							print("Subskill yielded")
							yield(controlNode.wait(0.01), "timeout")
					OPCODE_PLAYANIM:
						print(">PLAY ANIMATION: %s" % value)
						controlNode.startAnim(S.animations[0], target.display)
						yield(controlNode, "fx_finished")
					OPCODE_WAIT:
						print(">WAIT: %s" % value)
						yield(controlNode.wait(float(value) * 0.01), "timeout")
# Player only specials #########################################################
					OPCODE_EXP_BONUS:
						print(">EXP_BONUS: %s" % value)
						if target is core.Enemy:
							target.XPMultiplier += (float(value) * 0.01)
						else:
							print("EXP_BONUS not applied, target is not an enemy.")
# Flow control #################################################################
					OPCODE_STOP:
						print(">STOP")
						control.continueSkill()
						return
					OPCODE_JUMP:
						print(">[INDEV]JUMP TO LINE: %s" % value)
# Gets #########################################################################
					OPCODE_GET_FIELD_BONUS:
						print(">GET ELEMENTFIELD BONUS")
						state.value = int(core.battle.control.state.field.getBonus(state.element if value == 0 else value) * 100)
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_FIELD_CHAINS:
						print(">GET ELEMENTFIELD ELEMENT CHAINS")
						state.value = core.battle.control.state.field.chains
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_FIELD_UNIQUE:
						print(">GET ELEMENTFIELD ELEMENT CHAINS")
						state.value = core.battle.control.state.field.unique
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_SYNERGY_PARTY:
						print(">GET SYNERGY WITH SKILL %02d IN PARTY" % [(value - 1)])
						value = int(value - 1)
						var synResult = 0
						if value >= 0 and value < S.synergy.size():
							var synS = core.lib.skill.getIndex(S.synergy[value])
							synResult = variableTarget.group.countEffects(synS)
						state.value = synResult
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_TURN:
						print(">GET CURRENT TURN")
						state.value = core.battle.control.state.turn
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_CHAIN:
						print(">GET CURRENT CHAIN")
						state.value = variableTarget.battle.chain
						print(">>>>>SVAL = %s" % state.value)
# Math #########################################################################
					OPCODE_MATH_ADD:
						print(">MATH_ADD: %s + %s = %s" % [state.value, value, state.value + value])
						state.value += value
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_SUB:
						print(">MATH_SUB: %s - %s = %s" % [state.value, value, state.value - value])
						state.value -= value
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_MUL:
						print(">MATH_MUL: %s * %s = %s" % [state.value, value, state.value * value])
						state.value *= value
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_DIV:
						print(">MATH_DIV: %s / %s = %s" % [state.value, value, state.value / value])
						state.value /= value
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_MULF:
						print(">MATH_MULF: %s / %s(%s) = %s" % [state.value, value, float(value) * 0.001, state.value * (float(value) * 0.001)])
						state.value = float(state.value) * float(value * 0.001)
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_DIVF:
						print(">MATH_DIVF: %s / %s(%s) = %s" % [state.value, value, float(value) * 0.001, state.value / (float(value) * 0.001)])
						state.value = float(state.value) / float(value * 0.001)
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_CAP:
						print(">MATH_CAP: %s up to %s" % [state.value, value])
						if state.value > value:
							state.value = int(value)
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_MOD:
						print(">MATH_MODULO: %s %% %s = %s" % [state.value, value, state.value % int(value)])
						state.value = state.value % int(value)
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_PERCENT:
						print(">MATH_PERCENT: %s%% of %s = %s" % [value, state.value, int(float(state.value) * float(value * 0.01))])
						state.value = int(float(state.value) * float(value * 0.01))
						print(">>>>>SVAL = %s" % state.value)
# Conditionals #################################################################
					OPCODE_IF_TRUE:
						print(">IF TRUE %s" % value)
						if value != 0:
							print("%s is not zero" % [int(value)])
						else:
							if flags & OPFLAGS_QUIT_ON_FALSE:
								print("%s is zero. Aborting execution." % [int(value)])
								control.continueSkill()
								return
							else:
								cond_block = (flags & OPFLAGS_BLOCK_START)
								print("%s is zero. Skipping next line." % [int(value)])
								skipLine = true
					OPCODE_IF_CHANCE:
						print(">IF_CHANCE: %s" % value)
						if core.chance(value):
							print("Chance check passed, executing next line.")
						else:
							if flags & OPFLAGS_QUIT_ON_FALSE:
								print("Chance check failed. Aborting execution.")
								control.continueSkill()
								return
							else:
								cond_block = (flags & OPFLAGS_BLOCK_START)
								print("Chance check failed. Skipping next %s." % ('block' if cond_block else 'line'))
								skipLine = true
					OPCODE_IF_STATUS:
						print(">IF_STATUS: %s" % value)
						if variableTarget.status != STATUS_NONE:
							print("Target is afflicted, executing next line.")
						else:
							if flags & OPFLAGS_QUIT_ON_FALSE:
								print("Target is not afflicted. Aborting execution.")
								control.continueSkill()
								return
							else:
								cond_block = (flags & OPFLAGS_BLOCK_START)
								print("Target is not afflicted. Skipping next %s." % ('block' if cond_block else 'line'))
								skipLine = true
					OPCODE_IF_SVAL_EQUAL:
						print(">IF SVAL EQUALS %s" % value)
						if int(state.value) == int(value):
							print("%s == %s, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAGS_QUIT_ON_FALSE:
								print("%s != %s. Aborting execution." % [int(state.value),int(value)])
								control.continueSkill()
								return
							else:
								cond_block = (flags & OPFLAGS_BLOCK_START)
								print("%s != %s. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_SVAL_LESSTHAN:
						print(">IF SVAL IS LESS THAN %s" % value)
						if int(state.value) < int(value):
							print("%s < %s, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAGS_QUIT_ON_FALSE:
								print("%s >= %s. Aborting execution." % [int(state.value),int(value)])
								control.continueSkill()
								return
							else:
								cond_block = (flags & OPFLAGS_BLOCK_START)
								print("%s >= %s. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_SVAL_LESS_EQUAL_THAN:
						print(">IF SVAL IS LESS OR EQUAL THAN %s" % value)
						if int(state.value) <= int(value):
							print("%s <= %s, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAGS_QUIT_ON_FALSE:
								print("%s > %s. Aborting execution." % [int(state.value),int(value)])
								control.continueSkill()
								return
							else:
								cond_block = (flags & OPFLAGS_BLOCK_START)
								print("%s > %s. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_SVAL_MORETHAN:
						print(">IF SVAL IS MORE THAN %s" % value)
						if int(state.value) > int(value):
							print("%s > %s, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAGS_QUIT_ON_FALSE:
								print("%s <= %s. Aborting execution." % [int(state.value),int(value)])
								control.continueSkill()
								return
							else:
								cond_block = (flags & OPFLAGS_BLOCK_START)
								print("%s <= %s. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_SVAL_MORE_EQUAL_THAN:
						print(">IF SVAL IS MORE OR EQUAL THAN %s" % value)
						if int(state.value) >= int(value):
							print("%s >= %s, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAGS_QUIT_ON_FALSE:
								print("%s < %s. Aborting execution." % [int(state.value),int(value)])
								control.continueSkill()
								return
							else:
								cond_block = (flags & OPFLAGS_BLOCK_START)
								print("%s < %s. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_EF_BONUS_LESS_EQUAL_THAN:
						print(">IF ELEMENT FIELD MORE OR EQUAL THAN %s" % value)
						if core.battle.control.state.field.bonus[state.element] <= value:
							print("Element bonus for %s: %s <= %s, executing next line" % [state.element, core.battle.control.state.field.bonus[state.element], value])
						else:
							if flags & OPFLAGS_QUIT_ON_FALSE:
								print("Element bonus for %s: %s > %s. Aborting execution." % [state.element, core.battle.control.state.field.bonus[state.element], value])
								control.continueSkill()
								return
							else:
								cond_block = (flags & OPFLAGS_BLOCK_START)
								print("Element bonus for %s: %s > %s. Skipping next line." % [state.element, core.battle.control.state.field.bonus[state.element], value])
								skipLine = true
					OPCODE_IF_EF_BONUS_MORE_EQUAL_THAN:
						print(">IF ELEMENT FIELD MORE OR EQUAL THAN %s" % value)
						if core.battle.control.state.field.bonus[state.element] >= value:
							print("Element bonus for %s: %s >= %s, executing next line" % [state.element, core.battle.control.state.field.bonus[state.element], value])
						else:
							if flags & OPFLAGS_QUIT_ON_FALSE:
								print("Element bonus for %s: %s < %s. Aborting execution." % [state.element, core.battle.control.state.field.bonus[state.element], value])
								control.continueSkill()
								return
							else:
								cond_block = (flags & OPFLAGS_BLOCK_START)
								print("Element bonus for %s: %s < %s. Skipping next line." % [state.element, core.battle.control.state.field.bonus[state.element], value])
								skipLine = true
					OPCODE_IF_SYNERGY_PARTY:
						print(">[INDEV]IF SYNERGY IN PARTY %02d (using %02d)" % [value, value - 1])
						value = int(value - 1)
						if value >= 0 and value < S.synergy.size():
							var synS = core.lib.skill.getIndex(S.synergy[value])
							var synResult = variableTarget.group.findEffects(synS)
							if synResult:
								print("Skill %s found in party. Executing next line." % [synS.name])
							else:
								if flags & OPFLAGS_QUIT_ON_FALSE:
									print("Skill %s not found in party. Aborting execution." % [synS.name])
									control.continueSkill()
									return
								else:
									cond_block = (flags & OPFLAGS_BLOCK_START)
									print("Skill %s not found in party. Skipping next %s" % [synS.name, 'block' if cond_block else 'line'])
									skipLine = true
						else:
							print("%d not found" % value)
					OPCODE_IF_SYNERGY_TARGET:
						print(">[INDEV]IF SYNERGY IN TARGET %s" % value)
						value = int(value - 1)
						if value >= 0 and value < S.synergy.size():
							var synS = core.lib.skill.getIndex(S.synergy[value])
							var synResult = variableTarget.findEffects(synS)
							if synResult:
								print("Skill %s found on %s. Executing next line." % [synS.name, variableTarget.name])
							else:
								if flags & OPFLAGS_QUIT_ON_FALSE:
									print("Skill %s not found on %s. Aborting execution." % [synS.name, variableTarget.name])
									control.continueSkill()
									return
								else:
									cond_block = (flags & OPFLAGS_BLOCK_START)
									print("Skill %s not found in %s. Skipping next %s" % [synS.name, variableTarget.name, 'block' if cond_block else 'line'])
									skipLine = true

			else:
				print("[%s]%02d>SKIP %s" % [S.name, j, 'LINE' if not cond_block else 'BLOCK'])
				if cond_block:
					#We are inside a code block.
					if flags & OPFLAGS_BLOCK_END:
						#This line ends the block.
						cond_block = false
						skipLine = false
						print("%02d>END BLOCK" % j)
					else:
						skipLine = true
				else:
					skipLine = false

	control.continueSkill()
