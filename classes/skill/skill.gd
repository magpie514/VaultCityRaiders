var stats = core.stats
var MAX_DMG = stats.MAX_DMG


enum { #Category
#General category of the attacks. Determines its general context
	CAT_ATTACK = 0,		#Combat actions that target enemies (attacks, debuffs, etc)
	CAT_SUPPORT,			#Combat actions that target allies (heals, buffs, etc) (no acc check)
	CAT_OVER,				#Skill is an Over skill and only available in battle, similar to CAT_ATTACK
	CAT_STATUP,				#Skill has no combat or passive effects, only raises stats/resists
	CAT_PASSIVE,			#Skill that have passive effects
	CAT_FIELD,				#Skill that can be used for events
}

# Regular constants
const SKILL_MISSED = -1  #TODO: Review these.
const SKILL_FAILED = -2
const MAX_LEVEL    = 10  #Max amount of levels for skills.

#Skill code line template
#                   0              1 2 3 4 5   6 7 8 9 10  11            12            13           14
#                   <SKILL OPCODE> <VALUE PER LEVEL>       <FLAGS>       <DATA ARRAY>  <DGEM TAG>   <TAG>
var LINE_TEMPLATE = [OPCODE_NULL,  0,0,0,0,0,  0,0,0,0,0,  OPFLAG_NONE, null,         '',          '']


enum { #Filter
#Whenever any skill activates (for every number of activations), the skill will test based on filter
#If failed, the attack fails (as opposed to missing).
#In menus, only targets that match can be selected.
	FILTER_ALIVE = 0,				#Target must be alive (attacks, heals, pretty much anything)
	FILTER_DOWN,					#Target must be incapacitated (revives)
	FILTER_STATUS,					#Target must be alive and have a status effect (status recovery, ailment combos)
}

enum { MODSTAT_NONE, MODSTAT_ATK, MODSTAT_DEF, MODSTAT_ETK, MODSTAT_EDF, MODSTAT_AGI, MODSTAT_LUC }

enum { #Over skill costs.
	OVER_COST_1 = 033, #Tier 1 Over skill cost.
	OVER_COST_2 = 050, #Tier 2 Over skill cost.
	OVER_COST_3 = 100, #Tier 3 Over skill cost.
}

enum { USE_ANYWHERE, USE_COMBAT, USE_FIELD } #Defines where the skill can be used.
enum { EFFTYPE_BUFF, EFFTYPE_DEBUFF, EFFTYPE_SPECIAL } #If it's a buff, debuff or general passive effect.


# Skill Effects ###############################################################
enum { #Skill effects
	EFFECT_NONE    = 0b00000, #No effect
	EFFECT_STATS   = 0b00001, #Alters combat stats
	EFFECT_ATTACK  = 0b00010, #Runs effect code EA on a successful hit
	EFFECT_ONHIT   = 0b00100, #Runs effect code EH when receiving a hit
	EFFECT_ONEND   = 0b01000, #Runs effect code EE when the effect ends
	EFFECT_SPECIAL = 0b10000, #Runs effect code ES at the start of a turn
}

enum { #What to do in case of effect collision (same effect active on target)
	EFFCOLL_REFRESH,	#Default, reset effect to maximum duration.
	EFFCOLL_ADD,		#Add maximum duration to current duration.
	EFFCOLL_FAIL,		#Effect fails
	EFFCOLL_NULLIFY,	#Cancels or toggles the effect
}

# Conditions:
# Machines are inherently immune to Narcosis. Dragons cannot be sealed.
enum {
	# Primaries: Only one can be active at once. Last overrides current.
	CONDITION_GREEN     = 0,  #All good.
	CONDITION_DOWN      = 5,  #Target is incapacitated, but not dead, can still be brought back to action. Resistance to this status is used for insta-kills.
	CONDITION_PARALYSIS = 1,  #Target is paralyzed and has a 50% chance of being unable to execute normal actions. Over actions ignore this.
	CONDITION_NARCOSIS  = 2,  #Target is in an artifical stupor and won't be able to execute normal or Over actions, but receiving hits will randomly cancel it.
	CONDITION_CRYO      = 3,  #Target is frozen and unable to execute normal or Over actions, and weaker to kinetic damage. Fire does extra damage but unfreezes early.
	CONDITION_SEAL      = 4,  #Target is sealed in an energy field and unable to execute normal or Over actions, and weaker to energy damage, but more resistant of kinetic damage.
}

enum {
	# Secondaries: Any can be active at any time.
	CONDITION2_BLIND     = 0b00001,  #Target skill accuracy is halved.
	CONDITION2_STUN      = 0b00010,  #Target is unable to act for this turn.
	CONDITION2_CURSE     = 0b00100,  #Target is damaged by a factor when it damages other targets.
	CONDITION2_PANIC     = 0b01000,  #Target is unable to execute Over actions, and has a 30% chance of being unable to act.
	CONDITION2_ARMS      = 0b10000,  #Target is put in stasis and removed from normal combat until expiring. Skills can specifically aim for targets in stasis.
}

enum { TARGET_GROUP_ALLY, TARGET_GROUP_ENEMY, TARGET_GROUP_BOTH }


var messageColors = {   #Colors for various message types.
	buff     = "62EAFF", #Buffs
	debuff   = "FFA9B0", #Debuffs
	effect   = "777777", #General effects
	statup   = "FFDAE0", #Stat ups
	statdown = "E3E2FF", #Stat downs
	chain    = "FBFFA5", #Chain chances
	protect  = "BEFFCE", #Protect
	followup = "DEF0FC", #Followup actions
}

enum { #Animation flags.
	ANIMFLAGS_NONE               = 0b0000,
	ANIMFLAGS_LONG               = 0b0001, #Animation is long. Long animations are to be stored and skipped when seen once.
	ANIMFLAGS_COLOR_FROM_ELEMENT = 0b0010, #Inherits effect color from element.
}

enum { #Animation types.
	ANIM_ONHIT   = 0,
	ANIM_STARTUP = 1,
	ANIM_FINISH  = 2,
}

enum { #Chains. Starters init a sequence, follows increase it, and finishers use the chain value as modifier.
	CHAIN_NONE = 0,
	CHAIN_STARTER,
	CHAIN_FOLLOW,
	CHAIN_STARTER_AND_FOLLOW,
	CHAIN_FINISHER,
}

const CHAIN_INIT = [ CHAIN_STARTER_AND_FOLLOW, CHAIN_STARTER ]
const CHAIN_CONT = [ CHAIN_STARTER_AND_FOLLOW, CHAIN_FOLLOW  ]

enum { #Parry. Reduces the damage of an attack with a given chance.
	PARRY_NONE = 0,
	PARRY_KINETIC,
	PARRY_ENERGY,
	PARRY_ALL,
}

enum { #On-hit effects.
	ONHIT_FOLLOWUP,
	ONHIT_CHASE,
	ONHIT_COUNTER,
}

enum { #Targeting.
#To expedite combat, some skills don't show a target prompt.
#Skills only allow targets within range. If only one target is in range, it'll be chosen automatically.
	#No prompt
	TARGET_SELF             , #Targets only self.																		prompt: no
	TARGET_SELF_ROW         , #Pics any valid targets on self's row.								prompt: no
	TARGET_SELF_ROW_NOT_SELF, #Picks any valid targets on self's row but user.			prompt: no
	TARGET_NOT_SELF_ROW     , #Picks any valid targets on the other row.						prompt: no
	TARGET_ALL              , #Targets everyone.																		prompt: no
	TARGET_ALL_NOT_SELF     , #Targets everyone but user.														prompt: no
	#TODO: Do something about these, implement proper logic.
	TARGET_RANDOM1          , #Picks any valid targets, can repeat.									prompt: no
	TARGET_RANDOM2          , #Picks any valid targets, but can't repeat.						prompt: no

	#Pick single target
	TARGET_SINGLE           , #Targets any member.																	prompt: yes
	TARGET_SINGLE_NOT_SELF  , #Targets any member, except self.											prompt: yes
	TARGET_LINE             , #Targets one member and whatever is in front or behind it.
	TARGET_WIDE             , #Targets one member and nearby members, full effect.  prompt: yes

	#Pick row of targets
	TARGET_ROW              , #Targets a full row.																	prompt: yes
	TARGET_ROW_RANDOM       , #Picks any valid targets on selected row.							prompt: yes
	TARGET_ROW_FRONT        , #Explicitly picks the front row.
	TARGET_ROW_BACK         , #Explicitly picks the back row.
}

enum { #Code blocks
	#Priority actions (Effects at the start of the turn, before Over actions)
	CODE_PR,	#[*] Priority code: targets self, used to set things up at the start of the turn.
	CODE_PP,	#[ ] Priority post code: if present, run this code on self or defined targetPost targets of the same group as the user.

	#Main skill body (Effects for Over and normal turn actions)
	CODE_ST, #[*] Setup code: Targets self. If the skill has multiple targets, run this code to do stuff that should only happen once, not once per target.
	CODE_MN,	#[*] Main code: the main body of the skill.
	CODE_PO,	#[*] Post action code. It's used on self or defined targetPost targets of the same group after the end of a code MN.

	#Extra attacks
	CODE_FL,	#[*] Follow code: For actions that cause an extra attack to come out. Keep it simple!

	#Defeat actions
	CODE_DN,  #[ ] Down code: run this if the skill defeats a target, for every target.
	CODE_GD,  #[ ] Global down code: Run this if anyone is defeated in the field with that anyone as a target.

	#Effect logic and actions
	CODE_EF,	#[*] Effect code: if the skill provides a buff/debuff with special effect, use this code.
	CODE_EP,	#[ ] Effect post code. If included, run this on targetPost defined targets of the user's group.
	CODE_EE,	#[*] Effect end code: if the skill provides a buff/debuff, use this code when it ends.
	CODE_EA, #[ ] Effect hitting code: while the skill provides a buff/debuff, use this code when successfuly hitting a target.
	CODE_EH, #[ ] Effect hit code: while the skill provides a buff/debuff, use this code when getting successfully hit by an attacker.
	CODE_ED, #[ ] Effect down code: while the skill provides a buff/debuff, use this code when defeating a target.
}

enum { #Skill function flags. Value between [] is used in the function codes where applicable.
	OPFLAG_NONE           = 0b000000000,  #Default settings.
	OPFLAG_TARGET_SELF    = 0b000000001,  #[@] This opcode will affect the user if applicable.
	OPFLAG_VALUE_ABSOLUTE = 0b000000010,  #[=] This opcode will set a value as absolute, if applicable.
	OPFLAG_VALUE_PERCENT  = 0b000000100,  #[%] This opcode will set a value as a percentage, if applicable.
	OPFLAG_HEAL_BONUS     = 0b000001000,  #[+] Heal only. Uses bonus healing value.
	OPFLAG_USE_SVAL       = 0b000010000,  #Use state stored value instead of passed value.
	OPFLAG_QUIT_ON_FALSE  = 0b000100000,  #[X] In a conditional, directly quit instead of skipping next line.
	OPFLAG_BLOCK_START    = 0b001000000,  #In a conditional, start a block. Skips everything until a OPFLAG_BLOCK_END is found.
	OPFLAG_BLOCK_END      = 0b010000000,  #Determines end of a code block.
	OPFLAG_LOGIC_NOT      = 0b100000000,  #[!] In a conditional, reverse the outcome.
}

enum { #Skill function codes.
	#Null
	OPCODE_NULL                       , #No effect

	# Standard combat functions ##################################################
	OPCODE_ATTACK                     , #Standard attack function with power%.
	OPCODE_ATTACK_COMBO               , #Same as OPCODE_ATTACK but only triggers if the previous hit connected.
	# Complex attack #############################################################
	# Data is provided via a hexadecimal value with format 0xAAAABCDE
	OPCODE_ATTACK_EX                  , #Use attack data.
	OPCODE_DEFEND                     , #Standard defense function. TODO: Define defense role's further.
	# Condition infliction #####################################################
	# Data is provided via a hexadecimal value with format 0xABC
	# A: 0-C: Condition to inflict
	# 	0: Do nothing  5: Blindness
	#	1: Paralysis   6: Stun
	#	2: Cryostasis  7: Curse
	#	3: Seal        8: Panic
	#  4: Defeat      9: Disable Arms
	# B: 0-F: Infliction power
	# C: 0-1: Only try to apply if last attack connected.
	OPCODE_INFLICT_EX                 , #Use inflict data.
	OPCODE_FORCE_INFLICT              , #[@]Attempt to inflict an ailment independent from attack.
	OPCODE_DAMAGERAW                  , #[@%]Reduce target's HP by given value (no accuracy check)
	OPCODE_SELF_DAMAGE                , #[%]Shortcut for delivering recoil/self damage to the user.
	OPCODE_DEFEAT                     , #[@]Instantly defeats target with a given chance. This bypasses regular instant death protection and is mostly used for self-destructs with potential chances of survival.
	OPCODE_TRYRUN                     , #[@]Tries to run from battle with a X% chance check.
	OPCODE_RUN                        , #[@]If not zero, runs from battle bypassing checks. Will still fail on battles where running is disabled.

	# Movement functions #########################################################
	# For FRONT and BACK, the value of X determines:
	# 0 = No effect
	# 1 = Only carry on if the target position is empty.
	# 2 = If the position is not empty, force a switch unless either character is inmovable.
	# 3 = No ifs or buts just switch the position.
	# TODO: Inmovable character property?
	OPCODE_MOVE_FRONT , #[@] Position target in the front row, same line.
	OPCODE_MOVE_BACK  , #[@] Position target in the back row, same line.
	OPCODE_MOVE_SWITCH, #[@]

	# Follow and chase functions #################################################
	# Data is provided via a hexadecimal value with format 0x1AABBC (Example: 0x16421F)
	# The 1 is to pad the size, it's mandatory or things will misbehave.
	# AA: 00-64: Counter chance%
	# BB: 00-64: Chance decrement per use.
	# C : 0-F  : Element to trigger. 0 for current skill element, F for any element.
	OPCODE_CHASE                      , #Sets up a chase on target. When target is hit by the given element, the skill will trigger.
	OPCODE_FOLLOW                     , #Sets up a followup on target. When the user attacks with the given element, the skill will trigger.

	# Counter functions ##########################################################
	# Data is provided via a hexadecimal value with format 0x1AABBCDE (Example: 0x16400200)
	# The 1 is to pad the size, it's mandatory or things will misbehave.
	# AA: 00-64: Counter chance%
	# BB: 00-64: Chance decrement per use.
	# C : 0-F  : Max counter amount.
	# D : 0-A  : Element to counter (see element table).
	# E : 0-3  : Counter 0:None 1:Energy 2:Kinetic 3:All attack skills.
	OPCODE_COUNTER                    , #Sets counter with provided data.

	# Healing functions ##########################################################
	OPCODE_HEAL                       , #[@=%+]Standard healing.
	OPCODE_HEAL_MOD                   , #[@] Healing effectiveness modifier.
	OPCODE_HEALROW                    , #[=+]Heal user's row with power X.
	OPCODE_HEALALL                    , #[=+]Heal user's party with power X.
	OPCODE_RESTOREPART                , #[@]Restores up to X disabled body parts. 3+ restores them all.
	OPCODE_REVIVE                     , #[+]Target is revived with X health. TODO: Modify to [@] so it can be used to prevent a death as well?
	OPCODE_OVERHEAL                   , #[@]Sets amount of healing allowed to go past maximum health for this turn.
	# Condition healing ########################################################
	# Data is provided via a hexadecimal value with format 0xABC
	# A: 0-C: Condition to remove
	# 	0: Do nothing  5: Blindness
	#	1: Paralysis   6: Stun
	#	2: Cryostasis  7: Curse
	#	3: Seal        8: Panic
	#  4: Defeat      9: Disable Arms
	# B: 0-F: Add this much to defense
	# C: 0-1: 0: Cap at maximum. 1: Allow going beyond maximum.
	OPCODE_REINFORCE_EX               , #[@]Cure afflictions with given data.
	OPCODE_REINFORCE                  , #[@]Restore condition defense to max for condition x.
	OPCODE_REINFORCE_ALL              , #[@]Restore condition defense to max for all conditions.
	OPCODE_CURE                       , #[@]Cure condition X if active.
	OPCODE_CURE_ALL                   , #[@]Cure all conditions.
	OPCODE_CURE_TYPE                  , #[@]Cure: [1] Primary conditions. [2] Secondary conditions. [3] Damage over time. [4] Disables.

	# Standard effect functions ##################################################
	# TODO                            : Move a few of these to stat mods.
	OPCODE_AD                         , #[@=]Set target's active defense% for the rest of the turn.
	OPCODE_DECOY                      , #[@=]Set target's decoy% for the rest of the turn.
	OPCODE_BLOCK                      , #[@=]Set target's block (all incoming damage is reduced by X) for the rest of the turn.
	OPCODE_BARRIER                    , #[@=%]Set target's barrier (a total of X damage is negated) for the rest of the turn.
	OPCODE_BARRIER_RAW                , #[@=%]Set target's barrier for the rest of the turn. Not modified by elemental bonuses.
	OPCODE_BARRIER_HOLD               , #[@%]Keep X% barrier at the end of a turn.
	OPCODE_DODGE                      , #[@=]Set target's dodge rate for the rest of the turn.
	OPCODE_FORCE_DODGE                , #[@=]Set target's forced dodges for the rest of the turn. Automatically dodges without checks.
	OPCODE_PROTECT                    , #[@]User protects target with an X% chance until the end of the turn.
	OPCODE_RAISE_OVER                 , #[@]Increases Over gauge by X.
	OPCODE_DAMAGE_GUARD               , #[@]Damages barrier, using the standard damage formula.
	OPCODE_BREAK_GUARD                , #[@]Removes barriers.
	#TODO:
	#[ ] Add a healing received% modifier.
	OPCODE_FE_GUARD                   , #[@=]Set a chance%, for the target's GROUP, to prevent the opposing group from adding elements to the field.
	OPCODE_SETVITAL                   , #[@=]Set target's HP to given value.

	# Standard support functions #################################################
	OPCODE_SCAN                       , #Scans target with 1 or 2 power. Anything beyond 2 is reduced to 2, has no effect if 0.
	OPCODE_TRANSFORM                  , #[@]Causes target to transform, if possible, if not 0, cancel transformation if 0.

	#Attack modifiers ############################################################
	#These are reset per target and if used in PR code they don't carry over.
	OPCODE_DAMAGEBONUS                , #Bonus% to base power (additive).
	OPCODE_DAMAGEBONUS_ON_COND        , #Same as OPCODE_DAMAGEBONUS but only activates if target is afflicted.
	OPCODE_DAMAGEBONUS_ON_RANGE       , #Damage bonus on proximity: Hex value with format 0xAABBCCDD
		# AA: 00-FF: Damage on range 0 (both front). Must be above 0.
		# BB: 00-FF: Damage on range 1 (front to back or back to front).
		# CC: 00-FF: Damage on range 2 (back to back).
	OPCODE_DAMAGE_RAW_BONUS           , #Raw damage addition to next attack.
	OPCODE_HEALBONUS                  , #Bonus% to heal power (additive).
	OPCODE_HEAL_RAW_BONUS             , #Raw healing addtion to next heal.
	OPCODE_DAMAGE_EFFECT              , #Damage over time values: Hex value with format 0x1AAAABC. 1 is mandatory to pad size.
		# AAAA: 0000-FFFF: Damage per turn
		# B:    0-F      : Duration
		# C:    0-A      : Element modifier
		# D:    0-F      : Inflict power
	OPCODE_CRITMOD                    , #Critical hit mod.
	OPCODE_ELEMENT                    , #Element change:
		# 0: No effect  3: Strike  6: Electric
		# 1: Cut        4: Fire    7: Unknown
		# 2: Pierce     5: Cold    8: Ultimate
		# 9: Untyped
		# 10: Set to most effective
		# 11: Set to least effective
		# 12: [TODO] Set element to last element used by a party member.
		# 13: Reset to element defined in skill lib.

	OPCODE_NOMISS                     , #If 1, following combat effects won't miss.
	OPCODE_NOCAP                      , #If 1, damage can go over cap (32000). #TODO: Make it an event flag.
	OPCODE_IGNORE_ARMOR               , #Ignore a given percentage of target's armor provided defense.
	OPCODE_IGNORE_BARRIERS            , #Attack ignores target's barrier, block, and defender.
	OPCODE_RANGE                      , #Switch ranged property to true (not 0) or false (0).
	OPCODE_ENERGY                     , #Switch energy property to true (not 0) or false (0).
	OPCODE_DRAINLIFE                  , #User is healed for given % of total damage dealt for each hit.
	OPCODE_NONLETHAL                  , #Marks the skill as nonlethal. It cannot decrease target's Vital below 1.

	OPCODE_CHAIN_START                , #If a chain is not started (chain is 0), make it 1.
	OPCODE_CHAIN_FOLLOW               , #Modify current chain value (more than 1 only) by X.
	OPCODE_CHAIN_FINISH               , #If chain is not 0, make it 0.

	# Elemental Field ############################################################
	OPCODE_FIELD_PUSH                 , #Add specified element to the element field. 0 to use current element.
	OPCODE_FIELD_FILL                 , #Fill the element field with the specified element.
	OPCODE_FIELD_REPLACE              , #Replace all elements of the specified type from the field to current element.
	OPCODE_FIELD_REPLACE2             , #With a chance of X, try to replace all elements for current one.
	OPCODE_FIELD_RANDOMIZE            , #Randomize all elements in the field with X changing the randomization strategy.
	OPCODE_FIELD_CONSUME              , #Remove all instances of current element from the field to empty spaces, push the rest to the right.
	OPCODE_FIELD_TAKE                 , #Take X of current element from the field, starting from the left.
	OPCODE_FIELD_CLEAR                , #Empty the entire field.
	OPCODE_FIELD_OPTIMIZE             , #Sort elements so they form chains if more than one exists.
	OPCODE_FIELD_LOCK                 , #Lock the element field for X turns. If the wait is already not 0, add X-1 instead.
	OPCODE_FIELD_UNLOCK               , #Unlock the element field now.
	OPCODE_FIELD_GDOMINION            , #Set G-Dominion's "hyper field" property for user's group. All bonuses become x1.5 base.
	OPCODE_FIELD_SETLASTELEM          , #Set current element to the last (rightmost) element on the field.
	OPCODE_FIELD_SETDOMIELEM          , #Set current element to the dominant element on the field.
	OPCODE_FIELD_ELEMBLAST            , #For every chain on the field, add its element to queue.
	OPCODE_FIELD_SHIFT                , #Shift all elements to the right X times.
	OPCODE_FIELD_MULT                 , #[@]Set current field effect damage multiplier.

	# Stat mods ##################################################################
	OPCODE_ATK_MOD                    , #Modify target's ATK for the current turn.
	OPCODE_DEF_MOD                    , #Modify target's DEF for the current turn
	OPCODE_ETK_MOD                    , #Modify target's ETK for the current turn
	OPCODE_EDF_MOD                    , #Modify target's EDF for the current turn
	OPCODE_AGI_MOD                    , #Modify target's AGI for the current turn
	OPCODE_LUC_MOD                    , #Modify target's LUC for the current turn
	OPCODE_FE_BONUS_MOD               , #Field Element add bonus. Adds +X elements for the current turn.

	# General specials ###########################################################
	OPCODE_PRINTMSG                   , #Print message X of the defined skill messages. Use 0 to print nothing.
	OPCODE_LINKSKILL                  , #Uses a provided skill TID with the same level as cast.
	OPCODE_PLAYANIM                   , #Plays a given animation. Use 0 to play no animation, 1 to play default animation.
	OPCODE_FX_EFFECTOR_ADD            , #If X > 0, adds an effector (an object that attaches to the character sprite) defined in the "fx" array.
	OPCODE_WAIT                       , #Wait for X/100 miliseconds.
	OPCODE_POST                       , #Run post code for PR, MN or EF. x = 0 disables it. x = 1 targets the user's group. x = 2 targets the opposing group.
	OPCODE_SYNERGY_REMOVE             , #Removes a synergy if x > 0.
	# Effect controls ############################################################
	OPCODE_EFFECT_AUTOSET             , #X>0 is a linkSkill property index. If user has the specified effect skill, use it at current level at no cost.
	OPCODE_EFFECT_FINISH              , #If X > 0, remove this skill from active effects.
	OPCODE_EFFECT_REMOVE              , #X>0 is a linkSkill property index. Remove target effect.
	OPCODE_EFFECT_ADD                 , #X>0 is a linkSkill property index. Add target effect.
	# Event control ##############################################################
	#TODO: Remove. Event flags should be set in a combat script.
	OPCODE_EVENT_FLAG_SET             , #Set global event flag X.
	OPCODE_EVENT_FLAG_UNSET           , #Unset global event flag X.
	OPCODE_QUEST_FLAG_SET             , #Set quest event flag X.
	OPCODE_QUEST_FLAG_UNSET           , #Unset quest event flag X.
	OPCODE_START_EVENT                , #Start event X.
	# Player only specials #######################################################
	OPCODE_EXP_BONUS                  , #Increases EXP given by enemy at the end of battle.
	OPCODE_FORCE_CONDITIONAL_DROP     , #Forces conditional drop by enemy at the end of battle.
	OPCODE_REPAIR_PARTIAL             , #Repairs currently equipped weapon by X%.
	OPCODE_REPAIR_FULL                , #Repairs currently equipped weapon completely if not 0.
	OPCODE_REPAIR_PARTIAL_ALL         , #Repairs all equipped weapons by X%.
	OPCODE_REPAIR_FULL_ALL            , #Repairs all equipped weapons completely if not 0.
	OPCODE_ITEM_RECHARGE              , #Gives items charge equivalent to X hours.
	OPCODE_ITEM_REFILL                , #Fully refills chargeable items.

	# Enemy only specials ########################################################
	OPCODE_ENEMY_REVIVE               , #[+]Revives a fallen enemy.
	OPCODE_ENEMY_SUMMON               , #Summons with index X. If battle formation has a summons set, those take priority, otherwise monster-specific ones are used, if neither exist or the index is out of range, summon the same type as the user.
	OPCODE_ENEMY_ARMED                , #Sets enemy as armed or not. 0 makes no change. 1 makes it armed, 2 makes it disarmed.

	# Control flow ###############################################################
	OPCODE_STOP                       , #Stop execution.
	OPCODE_JUMP                       , #Jump (Continue execution from given line).

	# Gets #######################################################################
	OPCODE_GET_FIELD_BONUS            , #Get field bonus for specified element. Current element if 0.
	OPCODE_GET_FIELD_CHAINS           , #Get amount of element chains.
	OPCODE_GET_FIELD_UNIQUE           , #Get amount of unique elements.
	OPCODE_GET_SYNERGY_PARTY          , #Get amount of synergies found in the party.
	OPCODE_GET_TURN                   , #Get current turn.
	OPCODE_GET_TIME                   , #Get current day time (0-3600).
	OPCODE_GET_CHAIN                  , #Get current chain value.
	OPCODE_GET_LAST_ELEMENT           , #Get last element used by a party member.
	OPCODE_GET_HEALTH_PERCENT         , #Get health percentage from target.
	OPCODE_GET_MAX_HEALTH             , #Get target's max health.
	OPCODE_GET_HEALTH                 , #Get target's health.
	OPCODE_GET_LEVEL                  , #Get target's level.
	OPCODE_GET_ATK                    , #Get target's ATK.
	OPCODE_GET_DEF                    , #Get target's DEF.
	OPCODE_GET_ETK                    , #Get target's ETK.
	OPCODE_GET_EDF                    , #Get target's EDF.
	OPCODE_GET_AGI                    , #Get target's AGI.
	OPCODE_GET_LUC                    , #Get target's LUC.
	OPCODE_GET_LAST_HURT              , #Get amount of health lost from last skill.
	OPCODE_GET_DODGES                 , #Get amount of dodges for this turn.
	OPCODE_GET_DEFEATED               , #Get amount of defeated in the target team.
	OPCODE_GET_RANGE                  , #Get distance to target. Can be used in functions that target self, precalculated on skill state init.
	OPCODE_GET_OVER                   , #Get Over of target as a 0-100 value.
	OPCODE_GET_WEAPON_DUR             , #Get weapon durability. In enemies this is always 100 if armed, 0 if not. In players it's current remaining weapon DUR.
	OPCODE_GET_WORLD_TIME             , #Get current world time for the current day.
	OPCODE_GET_WORLD_DATE             , #Get current world date (current day).

	# Math #######################################################################
	OPCODE_MATH_ADD                   , #Add X to stored value. (SVAL + X)
	OPCODE_MATH_SUB                   , #Substract X from stored value. (SVAL - X)
	OPCODE_MATH_SUBI                  , #Substract stored value from X. (X - SVAL)
	OPCODE_MATH_MUL                   , #Multiply stored value by X. (SVAL * X)
	OPCODE_MATH_DIV                   , #Divide stored value by X. (SVAL / X)
	OPCODE_MATH_DIVI                  , #Divide X by stored value. (X / SVAL)
	OPCODE_MATH_MULF                  , #Multiply stored value by float(X/1000)
	OPCODE_MATH_DIVF                  , #Divide stored value by float(X/1000) (SVAL / (X/1000))
	OPCODE_MATH_CAP                   , #Cap value to the given value.
	OPCODE_MATH_MOD                   , #Modulo operation on stored value. sval%X.
	OPCODE_MATH_PERCENT               , #Set stored value to X% of its current value.

	# Conditionals ###############################################################
	OPCODE_IF_TRUE                    , #[!]Execute next line if X is not zero.
	OPCODE_IF_OVER                    , #[!]Execute next line if target's Over is >= X.
	OPCODE_IF_CHANCE                  , #[!]Chance% to execute next line.
	OPCODE_IF_CONDITION               , #[!]Execute next line if afflicted.
	OPCODE_IF_SVAL_EQUAL              , #[!]Execute next line if sval == X.
	OPCODE_IF_SVAL_LESSTHAN           , #[!]Execute next line if sval < X.
	OPCODE_IF_SVAL_LESS_EQUAL_THAN    , #[!]Execute next line if sval <= X.
	OPCODE_IF_SVAL_MORETHAN           , #[!]Execute next line if sval > X.
	OPCODE_IF_SVAL_MORE_EQUAL_THAN    , #[!]Execute next line if sval >= X.
	OPCODE_IF_EF_BONUS_LESS_EQUAL_THAN, #[!]Execute next line if bonus for current element <= X.
	OPCODE_IF_EF_BONUS_MORE_EQUAL_THAN, #[!]Execute next line if bonus for current element >= X.
	OPCODE_IF_ACT                     , #[!]Execute next line if target has already acted.
	OPCODE_IF_GUARDING                , #[!]Execute next line if target is defending.
#TODO                              : Think of a better mechanism to specify TIDs or lists of TIDs for these.
	OPCODE_IF_BUFF                    , #[!]Execute next line if target has active buff with given TID. -1 for any.
	OPCODE_IF_DEBUFF                  , #[!]Execute next line if target has active debuff with given TID. -1 for any.
	OPCODE_IF_TARGET_TID              , #[!]Execute next line if target matches given TID.
###/###
	OPCODE_IF_FULL_HEALTH             , #[!]Execute next line if target is at full health.
	OPCODE_IF_DAMAGED                 , #[!]Execute next line if target was damaged this turn.
	OPCODE_IF_SELF_DAMAGED            , #[!]Execute next line if user received damage this turn.
	OPCODE_IF_CHAIN                   , #[!]Execute next line if user's chain value is equal or over X.
	OPCODE_IF_HITCHECK                , #[!]Execute next line if a standard hit check succeeds.
	OPCODE_IF_CONNECT                 , #[!]Execute next line if last attack command hit.
	OPCODE_IF_SYNERGY_PARTY           , #[!]Execute next line if target's party has a given skill active, usually buffs, debuffs or passives.
	OPCODE_IF_SYNERGY_TARGET          , #[!]Execute next line if target has a given skill active.
	OPCODE_IF_RACE_ASPECT             , #[!]Execute next line if target has the given race aspects (BIO/MEC/SPI).
	OPCODE_IF_RACE_TYPE               , #[!]Execute next line if target has the given race type amount its list.
	OPCODE_IF_DAY                     , #[!]Execute next line if current time is day.
	OPCODE_IF_NIGHT                   , #[!]Execute next line if current time is night. Convenient shortcut for "not if_day"

}


#Functions that can be modified by dgems.
const opCodesPowerable = [
	OPCODE_ATTACK, OPCODE_ATTACK_COMBO,
	OPCODE_DAMAGERAW, OPCODE_DAMAGE_RAW_BONUS,                             #Damaging functions
	OPCODE_HEAL, OPCODE_HEALROW, OPCODE_HEALALL, OPCODE_HEALBONUS, OPCODE_HEAL_RAW_BONUS, #Healing functions
	OPCODE_BLOCK,                                                                       #Miscelaneous defensive functions
	OPCODE_BARRIER, OPCODE_BARRIER_RAW,                                                   #Guard functions.
]

#Translation from strings to function codes.
const opCode = {
	"null" : OPCODE_NULL,

	"attack"       : OPCODE_ATTACK,
	"attack.ex"    : OPCODE_ATTACK_EX,
	"attack.combo" : OPCODE_ATTACK_COMBO,
	"defend"       : OPCODE_DEFEND,
	"inflict"      : OPCODE_INFLICT_EX,
	"dmgraw"       : OPCODE_DAMAGERAW,
	"defeat"       : OPCODE_DEFEAT,
	"tryrun"       : OPCODE_TRYRUN,
	"run"          : OPCODE_RUN,

	"follow"  : OPCODE_FOLLOW,
	"chase"   : OPCODE_CHASE,
	"counter" : OPCODE_COUNTER,

	"chain_start" : OPCODE_CHAIN_START,
	"chain_follow": OPCODE_CHAIN_FOLLOW,
	"chain_finish": OPCODE_CHAIN_FINISH,

	"heal"         : OPCODE_HEAL,
	"heal.mod"     : OPCODE_HEAL_MOD,
	"heal_row"     : OPCODE_HEALROW,
	"heal_all"     : OPCODE_HEALALL,
	"healpart"     : OPCODE_RESTOREPART,
	"revive"       : OPCODE_REVIVE,
	"overheal"     : OPCODE_OVERHEAL,
	"reinforce"    : OPCODE_REINFORCE,
	"reinforce_all": OPCODE_REINFORCE_ALL,
	"reinforce_ex" : OPCODE_REINFORCE_EX,
	"cure"         : OPCODE_CURE,
	"cure_all"     : OPCODE_CURE_ALL,
	"cure_type"    : OPCODE_CURE_TYPE,

	"ad"          : OPCODE_AD,
	"decoy"       : OPCODE_DECOY,
	"barrier"     : OPCODE_BARRIER,
	"barrier.raw" : OPCODE_BARRIER_RAW,
	"dodge"       : OPCODE_DODGE,
	"force_dodge" : OPCODE_FORCE_DODGE,
	"block"       : OPCODE_BLOCK,
	"protect"     : OPCODE_PROTECT,
	"over"        : OPCODE_RAISE_OVER,
	"guarddamage" : OPCODE_DAMAGE_GUARD,
	"guardbreak"  : OPCODE_BREAK_GUARD,
	"fe.guard"    : OPCODE_FE_GUARD,
	"vital.set"   : OPCODE_SETVITAL,

	"scan"     : OPCODE_SCAN,
	"transform": OPCODE_TRANSFORM,

	"dmgbonus"      : OPCODE_DAMAGEBONUS,
	"dmgbonus.if_afflicted" : OPCODE_DAMAGEBONUS_ON_COND,
	"dmgbonus.on_range"     : OPCODE_DAMAGEBONUS_ON_RANGE,
	"dmg_raw_bonus" : OPCODE_DAMAGE_RAW_BONUS,
	"healbonus"     : OPCODE_HEALBONUS,
	"heal_raw_bonus": OPCODE_HEAL_RAW_BONUS,
	"dmg_over_time" : OPCODE_DAMAGE_EFFECT,
	"dot"           : OPCODE_DAMAGE_EFFECT, #Alias

	"critmod"       : OPCODE_CRITMOD,
	"element"       : OPCODE_ELEMENT,

	"nomiss"         : OPCODE_NOMISS,
	"nocap"          : OPCODE_NOCAP,
	"ignore_armor"   : OPCODE_IGNORE_ARMOR,
	"ignore_barriers": OPCODE_IGNORE_BARRIERS,
	"energy_dmg"     : OPCODE_ENERGY,
	"drainlife"      : OPCODE_DRAINLIFE,
	"nonlethal"      : OPCODE_NONLETHAL,

	"fe.push"      : OPCODE_FIELD_PUSH,
	"fe.fill"      : OPCODE_FIELD_FILL,
	"fe.replace"   : OPCODE_FIELD_REPLACE,
	"fe.replace2"  : OPCODE_FIELD_REPLACE2,
	"fe.rando"     : OPCODE_FIELD_RANDOMIZE,
	"fe.consume"   : OPCODE_FIELD_CONSUME,
	"fe.take"      : OPCODE_FIELD_TAKE,
	"fe.optimize"  : OPCODE_FIELD_OPTIMIZE,
	"fe.lock"      : OPCODE_FIELD_LOCK,
	"fe.unlock"    : OPCODE_FIELD_UNLOCK,
	"fe.hyper"     : OPCODE_FIELD_GDOMINION,
	"fe.el_setdomi": OPCODE_FIELD_SETDOMIELEM,
	"fe.el_setlast": OPCODE_FIELD_SETLASTELEM,
	"fe.elemblast" : OPCODE_FIELD_ELEMBLAST,
	"fe.mult"      : OPCODE_FIELD_MULT,
	"fe.shift"     : OPCODE_FIELD_SHIFT,
	"fe.clear"     : OPCODE_FIELD_CLEAR,

	# Stat mods
	"atk_mod" : OPCODE_ATK_MOD,
	"def_mod" : OPCODE_DEF_MOD,
	"etk_mod" : OPCODE_ETK_MOD,
	"edf_mod" : OPCODE_EDF_MOD,
	"agi_mod" : OPCODE_AGI_MOD,
	"luc_mod" : OPCODE_LUC_MOD,

	# Effect control
	"skill.auto"    : OPCODE_EFFECT_AUTOSET,
	"effect.end"    : OPCODE_EFFECT_FINISH,
	"effect.remove" : OPCODE_EFFECT_REMOVE,
	"effect.add"    : OPCODE_EFFECT_ADD,

	# Player specials
	"exp_bonus"     : OPCODE_EXP_BONUS,
	"repair"        : OPCODE_REPAIR_PARTIAL,
	"fullrepair"    : OPCODE_REPAIR_FULL,
	"repair_all"    : OPCODE_REPAIR_PARTIAL_ALL,
	"fullrepair_all": OPCODE_REPAIR_FULL_ALL,
	"item.recharge" : OPCODE_ITEM_RECHARGE,
	"item.refill"   : OPCODE_ITEM_REFILL,

	#Enemy specials
	"enemy.revive" : OPCODE_ENEMY_REVIVE,
	"enemy.summon" : OPCODE_ENEMY_SUMMON,

	"printmsg" : OPCODE_PRINTMSG,
	"linkskill": OPCODE_LINKSKILL,
	"anim.play": OPCODE_PLAYANIM,
	"fx.add"   : OPCODE_FX_EFFECTOR_ADD,
	"wait"     : OPCODE_WAIT,
	"post"     : OPCODE_POST,

	"stop" : OPCODE_STOP,
	"jump" : OPCODE_JUMP,

	"get_fe_bonus"    : OPCODE_GET_FIELD_BONUS,
	"get_fe_chains"   : OPCODE_GET_FIELD_CHAINS,
	"get_fe_unique"   : OPCODE_GET_FIELD_UNIQUE,
	"get_synergies"   : OPCODE_GET_SYNERGY_PARTY,
	"get_turn"        : OPCODE_GET_TURN,
	"get_chain"       : OPCODE_GET_CHAIN,
	"get_last_element": OPCODE_GET_LAST_ELEMENT,
	"get_health%"     : OPCODE_GET_HEALTH_PERCENT,
	"get_max_health"  : OPCODE_GET_MAX_HEALTH,
	"get_health"      : OPCODE_GET_HEALTH,
	"get_level"       : OPCODE_GET_LEVEL,
	"get_atk"         : OPCODE_GET_ATK,
	"get_def"         : OPCODE_GET_DEF,
	"get_etk"         : OPCODE_GET_ETK,
	"get_edf"         : OPCODE_GET_EDF,
	"get_agi"         : OPCODE_GET_AGI,
	"get_luc"         : OPCODE_GET_LUC,
	"get_dodges"      : OPCODE_GET_DODGES,
	"get_defeated"    : OPCODE_GET_DEFEATED,
	"get_range"       : OPCODE_GET_RANGE,
	"get_over"        : OPCODE_GET_OVER,
	"get_weapon_dur"  : OPCODE_GET_WEAPON_DUR,
	"get_world_time"  : OPCODE_GET_WORLD_TIME,
	"get_world_date"  : OPCODE_GET_WORLD_DATE,

	"add"  : OPCODE_MATH_ADD,
	"sub"  : OPCODE_MATH_SUB,
	"subi" : OPCODE_MATH_SUBI,
	"mul"  : OPCODE_MATH_MUL,
	"div"  : OPCODE_MATH_DIV,
	"divi" : OPCODE_MATH_DIVI,
	"mulf" : OPCODE_MATH_MULF,
	"divf" : OPCODE_MATH_DIVF,
	"cap"  : OPCODE_MATH_CAP,
	"mod"  : OPCODE_MATH_MOD,

	"if_true"          : OPCODE_IF_TRUE,
	"if_chance"        : OPCODE_IF_CHANCE,
	"if_condition"     : OPCODE_IF_CONDITION,
	"if_sval=="        : OPCODE_IF_SVAL_EQUAL,
	"if_sval<"         : OPCODE_IF_SVAL_LESSTHAN,
	"if_sval<="        : OPCODE_IF_SVAL_LESS_EQUAL_THAN,
	"if_sval>"         : OPCODE_IF_SVAL_MORETHAN,
	"if_sval>="        : OPCODE_IF_SVAL_MORE_EQUAL_THAN,
	"if_ef_bonus<="    : OPCODE_IF_EF_BONUS_LESS_EQUAL_THAN,
	"if_ef_bonus>="    : OPCODE_IF_EF_BONUS_MORE_EQUAL_THAN,
	"if_act"           : OPCODE_IF_ACT,
	"if_full_health"   : OPCODE_IF_FULL_HEALTH,
	"if_damaged"       : OPCODE_IF_DAMAGED,
	"if_self_damaged"  : OPCODE_IF_SELF_DAMAGED,
	"if_chain>"        : OPCODE_IF_CHAIN,
	"if_hitcheck"      : OPCODE_IF_HITCHECK,
	"if_connect"       : OPCODE_IF_CONNECT,
	"if_synergy_party" : OPCODE_IF_SYNERGY_PARTY,
	"if_synergy"       : OPCODE_IF_SYNERGY_TARGET,
	"if_race_aspect"   : OPCODE_IF_RACE_ASPECT,
	"if_race_type"     : OPCODE_IF_RACE_TYPE,
}

var opcodeInfo = {
	OPCODE_NULL: {
		name = "NULL", flags = OPFLAG_NONE, cat = "null",
		desc = "Does nothing.",
		expl = "ERROR",
	},
	OPCODE_ATTACK: {
		name = "Attack", flags = OPFLAG_NONE, cat = "combat",
		desc = "Standard attack function, tries to inflict for each hit, if capable.",
		expl = "hits for %s damage"
	},
	OPCODE_ATTACK_COMBO: {
		name = "Combo Attack", flags = OPFLAG_NONE, cat = "combat",
		desc = "Standard attack function, only activates if the previous hit connected.",
		expl = "hits for %s damage"
	},
	OPCODE_FORCE_INFLICT: {
		name = "Force inflict", flags = OPFLAG_TARGET_SELF, cat = "combat",
		desc = "Attempt to inflict an ailment, independent from attack.",
		expl = "may inflict %s"
	},
	OPCODE_DAMAGERAW: {
		name = "Raw damage", flags = OPFLAG_TARGET_SELF|OPFLAG_VALUE_PERCENT, cat = "combat",
		desc = "Causes X damage.\nIf VALUE_PERCENT is set, does a percentage of target's max health.",
		expl = "deals %s %s direct damage"
	},
	OPCODE_HEAL: {
		name = "Heal", flags = OPFLAG_TARGET_SELF|OPFLAG_VALUE_ABSOLUTE|OPFLAG_VALUE_PERCENT, cat = "healing",
		desc = "Heals a target.\nIf VALUE_ABSOLUTE is set, it heals a fixed amount.\n If VALUE_PERCENT is set, heals X% of target's max health.\nVALUE_ABSOLUTE takes precedence.",
		expl = "heals %s for %s"
	},
	OPCODE_CURE: {
		name = "Cure", flags = OPFLAG_TARGET_SELF, cat = "healing",
		dest = "Restores target's status to normal, no questions asked.",
		expl = "restores %s status"
	},
	OPCODE_RESTOREPART: {
		name = "Restore part", flags = OPFLAG_TARGET_SELF, cat = "healing",
		dest = "Restores up to X disabled body parts for the target. 3+ restores all parts.",
		expl = "restores body parts (%s)"
	},
	OPCODE_REVIVE: {
		name = "Revive", flags = OPFLAG_VALUE_PERCENT, cat = "healing",
		dest = "Removes a target's DOWN status and sets health to X. If VALUE_PERCENT is set, sets it to X% of target's max health.",
		expl = "revives the target at %s health"
	},
	OPCODE_OVERHEAL: {
		name = "Overheal", flags = OPFLAG_VALUE_ABSOLUTE, cat = "healing",
		dest = "Allows healing over max health for the rest of the turn up to MHP+X, additive. If VALUE_ABSOLUTE is set, set it exactly to X. If VALUE_PERCENT is set, set it to X% of max health. If both are present, set it to X% of max health.",
		expl = "allows %s to heal past maximum health (+%s)"
	},
	OPCODE_AD: {
		name = "Set AD", flags = OPFLAG_TARGET_SELF|OPFLAG_VALUE_ABSOLUTE, cat = "stats",
		desc = "Raises target's Active Defense by X.\nIf VALUE_ABSOLUTE is set, it sets it to X.",
		expl = "%s AD to %s"
	},
	OPCODE_DECOY: {
		name = "Decoy", flags = OPFLAG_TARGET_SELF|OPFLAG_VALUE_ABSOLUTE, cat = "stats",
		dest = "Raises target's decoy by X.\nIf VALUE_ABSOLUTE is set, it sets it to X.",
		expl = "%s draw attack rate by %s"
	},
	OPCODE_BARRIER: {
		name = "Guard", flags = OPFLAG_TARGET_SELF|OPFLAG_VALUE_ABSOLUTE|OPFLAG_VALUE_PERCENT, cat = "stats",
		dest = "Raises target's barrier by X.\nIf VALUE_ABSOLUTE is set, it sets it to X.\nIf VALUE_PERCENT is set, sets it to X% of target's max health.\nVALUE_ABSOLUTE takes precedence."
	},
	OPCODE_PROTECT: {
		name = "Protect target", flags = OPFLAG_TARGET_SELF, cat = "stats",
		dest = "User protects target with a X% chance of taking damage for the target.\nIf TARGET_SELF is set, this makes the target protect the user.",
		expl = "%s protects %s (%s%% chance)"
	},
	OPCODE_RAISE_OVER: {
		name = "Raise Over", flags = OPFLAG_TARGET_SELF, cat = "stats",
		dest = "Adds X to target's Over gauge. Does nothing on enemies.",
		expl = "raises %s Over by %s"
	},
	OPCODE_SCAN: {
		name = "Scan", flags = OPFLAG_NONE, cat = "misc",
		dest = "Scans target with power 1 or 2. Does nothing if zero.",
		expl = "%s draw attack rate by %s"
	},
	OPCODE_TRANSFORM: {
		name = "Transform", flags = OPFLAG_TARGET_SELF, cat = "misc",
		dest = "If not 0, transforms target if possible. If 0, cancel transformation.",
		expl = "transform"
	},
	OPCODE_DAMAGEBONUS: {
		name = "Damage bonus", flags = OPFLAG_VALUE_ABSOLUTE, cat = "modifiers",
		dest = "Increases damage bonus for next attack. If VALUE_ABSOLUTE is set, set it to X."
	},
	OPCODE_HEALBONUS: {
		name = "Healing bonus", flags = OPFLAG_VALUE_ABSOLUTE, cat = "modifiers",
		dest = "Increases healing bonus for following heals. If VALUE_ABSOLUTE is set, set it to X."
	},
	OPCODE_CRITMOD: {
		name = "Critical modifier", flags = OPFLAG_VALUE_ABSOLUTE, cat = "modifiers",
		dest = "Increases critical hit bonus for next attack. If VALUE_ABSOLUTE is set, set it to X."
	},
	OPCODE_ELEMENT: {
		name = "Set element", flags = OPFLAG_NONE, cat = "modifiers",
		dest = "Sets element of following attacks."
	},
	OPCODE_NOMISS: {
		name = "No miss", flags = OPFLAG_NONE, cat = "modifiers",
		dest = "Next attack will never miss."
	},
	OPCODE_IGNORE_ARMOR: {
		name = "Ignore armor", flags = OPFLAG_NONE, cat = "modifiers",
		dest = "Ignores a percentage of defenses provided by armor.",
		expl = "ignore armor"
	},
	OPCODE_IGNORE_BARRIERS: {
		name = "Ignore barriers", flags = OPFLAG_NONE, cat = "modifiers",
		dest = "If not 0, sets current attack to ignore guard, barrier or protect.",
		expl = "ignore barriers"
	},
	OPCODE_RANGE: {
		name = "Attack range", flags = OPFLAG_NONE, cat = "modifiers",
		dest = "Changes attack to ranged if not 0, if 0 remove range property.",
		expl = "%s draw attack rate by %s"
	},
	OPCODE_ENERGY: {
		name = "Energy damage", flags = OPFLAG_NONE, cat = "modifiers",
		dest = "Changes attack to energy damage if not 0, to kinetic damage if 0.",
		expl = "%s draw attack rate by %s"
	},
	OPCODE_DRAINLIFE: {
		name = "Drain life", flags = OPFLAG_TARGET_SELF, cat = "modifiers",
		dest = "Sets both minimum and maximum amount of hits for the attack, effectively hitting X times."
	},
	OPCODE_NONLETHAL: {
		name = "Non-lethal", flags = OPFLAG_NONE, cat = "modifiers",
		dest = "Marks the skill as nonlethal. It cannot decrease target's Vital below 1."
	},
	OPCODE_PRINTMSG: {
		name = "Print message", flags = OPFLAG_NONE, cat = "action",
		dest = "Prints a message, defined in the messages section."
	},
	OPCODE_LINKSKILL: {
		name = "Link skill", flags = OPFLAG_NONE, cat = "action",
		dest = "Discards current state and runs a new skill. It must be defined in the TID section"
	},
	OPCODE_PLAYANIM: {
		name = "Play animation", flags = OPFLAG_NONE, cat = "action",
		dest = "Plays animation X. It must be defined in the animations section."
	},
	OPCODE_STOP: {
		name = "Stop", flags = OPFLAG_NONE, cat = "control",
		dest = "Aborts execution."
	},
	OPCODE_JUMP: {
		name = "Jump to line", flags = OPFLAG_NONE, cat = "control",
		dest = "Jumps to another line in this skill's code."
	},
	OPCODE_IF_CHANCE: {
		name = "IF_CHANCE", flags = OPFLAG_NONE, cat = "control",
		dest = "Chance% to execute next line. Otherwise next line is skipped."
	},
	OPCODE_IF_CONDITION: {
		name = "IF_CONDITION", flags = OPFLAG_NONE, cat = "control",
		dest = "Execute next line if target has any status affliction. Otherwise next line is skipped."
	},
	OPCODE_IF_ACT: {
		name = "IF_ACT", flags = OPFLAG_NONE, cat = "control",
		dest = "Execute next line if target has acted this turn. Otherwise next line is skipped."
	},
	OPCODE_IF_DAMAGED: {
		name = "IF_ACT", flags = OPFLAG_TARGET_SELF, cat = "control",
		dest = "Execute next line if target has received damage this turn. Otherwise next line is skipped."
	},
	OPCODE_IF_HITCHECK: {
		name = "IF_HITCHECK", flags = OPFLAG_TARGET_SELF, cat = "control",
		dest = "Execute next line if a standard hit check passes. Otherwise next line is skipped."
	},
	OPCODE_IF_CONNECT: {
		name = "IF_CONNECT", flags = OPFLAG_NONE, cat = "control",
		dest = "Execute next line if last attack function in this skill succeeded. Otherwise next line is skipped."
	},
}

enum { #DGem skill mod codes
	DGEM_NONE = 0, #No mod
	DGEM_EF_MUL       , #EF Multiplier bonus
	DGEM_EF_ADD       , #EF Add bonus
	DGEM_RANGE        , #Range bonus
	DGEM_ACC          , #Accuracy bonus
	DGEM_SPD          , #Speed bonus
	DGEM_INITAD       , #Initial AD bonus
	DGEM_AD           , #Action AD bonus
	DGEM_COND_BONUS   , #Condition bonus
	DGEM_CHAINMOD     , #Chain mod
	DGEM_NONLETHAL    , #Nonlethal flag
	DGEM_EX_HIT       , #Extra hit
	DGEM_TARGET       , #Targetting mod
	DGEM_IGNOREARMOR  , #Ignore armor mod
	DGEM_IGNOREBARRIER, #Ignore barriers
	DGEM_DAMAGEBARRIER, #Damage barriers
	DGEM_CHARGE_FX    , #Enable charge effect until action
	DGEM_CHASE        , #Activate chase attack
	DGEM_ELEMENT      , #Rebind element
	DGEM_POWER        , #Power mod
	DGEM_LIFEDRAIN    , #Life drain flag
	DGEM_EXP_BONUS    , #EXP bonus on target
}

class SkillState:
	# Core attack stats #########################
	var skill:Dictionary                 #Current skill library data
	var level:int             = 0        #Current skill level
	var dmgBonus:int          = 0        #Damage bonus. Added to attack power.
	var dmgAddRaw:int         = 0        #Raw damage to add to attacks.
	var healPow:int           = 0        #Healing power
	var healBonus:int         = 0        #Healing bonus. Added to healing power.
	var healAddRaw:int        = 0        #Raw healing to add to heals.
	var drainLife:int         = 0        #Drain life. Percentage.
	var nonlethal:bool        = false    #Non-lethal. Cannot drop HP below 1.
	var accMod:int            = 0        #Accuracy modifier.
	var critMod:int           = 0        #Critical modifier.
	var element:int           = 0        #Element to use (read: current element)
	var fieldEffectMult:float = 1.0      #Field effect multiplier.
	var dmgStat: int          = 0        #Damage stat.
	var nomiss:bool           = false    #If true, the attack always hits.
	var nocap:bool            = false    #If true, the attack ignores damage cap (32000).
	var energy:bool           = false    #If true, use energy resistance stats on target.
	var ranged:bool           = false    #If true, ignore range penalties and targetting restrictions.
	var ignoreDefs:bool       = false    #If true, ignore special defenses (barrier, block).
	var ignoreArmor:int       = 0        #Ignore a percentage of armor defense.
	# Effect ####################################
	var setEffect:bool        = false    #If true, try to set an effect.
	# Hit record ################################
	var lastHit:bool          = false    #If true, the last attack connected.
	var hitRecord:Array       = []       #Record of last succeeding hits.
	var anyHit:bool           = false    #If true, any of the attacks has connected.
	# Onhit effects #############################
	var chase:Array                      #Data for chase setup    [User pointer, activation chance%, chance decrement per use, skill pointer, level, active, element to chase]
	var follow:Array                     #Data for followup setup [User pointer, activation chance%, chance decrement per use, skill pointer, level, active, element to follow]
	var counter:Array                    #Data for counter setup  [Activation chance%, chance decrement per use, skill pointer, level, element to counter, max counter amount, counter none/physical/energy/all]
	# Target override ###########################
	var originalTarget        = null     #Keep track of original target.
	# Statistics and output #####################
	# TODO: Remove, add directly to battle statistics for the user/target.
	var totalHeal:int         = 0        #Total amount of healing done this turn.
	var totalAfflictions:int  = 0        #Total amount of afflictions caused this turn.
	var finalHeal:int         = 0        #Final amount of healing.
	var finalDMG:int          = 0        #Final amount of damage.
	var criticals:int         = 0
	var revives:int           = 0
	# Switches ##################################
	var post:int              = 0       #If available, try to run post action codes. 0 = cancel running code, 1 = run it on user's group, 2 = run it on enemy's group.
	# SVAL stack #TODO: Make it a stack.
	var value:int             = 0       #Internal data stack.
	# Copy of init values
	var initVals:Array

	func _init(S:Dictionary, lv:int, user, target) -> void:
		initVals = [S, level, user, target]
		skill           = S
		level           = lv
		#Initialize values from skill definition
		element         = S.element[level]
		fieldEffectMult = float(S.fieldEffectMult[level])
		dmgStat         = S.damageStat
		accMod          = S.accMod[level]
		critMod         = S.critMod[level]
		energy          = S.energy
		ranged          = S.ranged[level]
		setEffect       = true if (S.category == CAT_SUPPORT and S.effect != core.skill.EFFECT_NONE) else false
		anyHit          = true if  S.category == CAT_SUPPORT else false
		follow          = [user, 100, 33, S, level, false, core.stats.ELEMENTS.DMG_UNTYPED]
		chase           = [user, 100, 33, S, level, false, core.stats.ELEMENTS.DMG_UNTYPED]
		counter         = [100, 0, S, level, core.stats.ELEMENTS.DMG_UNTYPED, 1, core.skill.PARRY_ALL]
		originalTarget  = target

	func duplicate() -> SkillState:
		print("[SKILL_STATE] Duplicating state...")
		var copy = SkillState.new(initVals[0], initVals[1], initVals[2], initVals[3])
		copy.skill            = skill
		copy.level            = level
		copy.dmgBonus         = dmgBonus
		copy.dmgAddRaw        = dmgAddRaw
		copy.healPow          = healPow
		copy.healBonus        = healBonus
		copy.healAddRaw       = healAddRaw
		copy.drainLife        = drainLife
		copy.nonlethal        = nonlethal
		copy.accMod           = accMod
		copy.critMod          = critMod
		copy.element          = element
		copy.fieldEffectMult  = fieldEffectMult
		copy.dmgStat          = dmgStat
		copy.nomiss           = nomiss
		copy.nocap            = nocap
		copy.energy           = energy
		copy.ranged           = ranged
		copy.ignoreDefs       = ignoreDefs
		copy.setEffect        = setEffect
		copy.lastHit          = lastHit
		copy.hitRecord        = hitRecord.duplicate()
		copy.anyHit           = anyHit
		copy.chase            = chase.duplicate()
		copy.follow           = follow.duplicate()
		copy.counter          = counter.duplicate()
		copy.originalTarget   = originalTarget
		copy.totalHeal        = totalHeal
		copy.totalAfflictions = totalAfflictions
		copy.finalHeal        = finalHeal
		copy.finalDMG         = finalDMG
		copy.value            = value
		return copy

	func element_set(val:int, target = null) -> void:
		match val:
			1,2,3,4,5,6,7,8:
				element = val
				print("Element set to %s." % core.stats.ELEMENT_CONV[element])
			15:
				element = skill.element
				print("Element set to %s (original)." % core.stats.ELEMENT_CONV[element])
			9:
				element = core.stats.ELEMENTS.DMG_UNTYPED
				print("Element set to untyped.")
			10:
				if target != null:
					element = target.getWeakestElementalResist()
					print("Element set to %s (best)." % core.stats.ELEMENT_CONV[element])
			11:
				if target != null:
					element = target.getStrongestElementalResist()
					print("Element set to %s (worst)." % core.stats.ELEMENT_CONV[element])
			_: print("No change")

func translateOpCode(o:String) -> int:
	o = o.to_lower() #Ensure string is lower case.
	return opCode[o] if o in opCode else OPCODE_NULL

func hasCodePR(S) -> bool:
	return true if S.codePR != null else false

func flaggedSet(sourceValue:int, value:int, flags:int) -> int:
	if  flags & OPFLAG_VALUE_ABSOLUTE: return value
	elif flags & OPFLAG_VALUE_PERCENT: return ( sourceValue as float * core.percent(value)) as int
	else                             : return sourceValue + value

func calculateHeal(a, power) -> int:
	power = float(power)
	var EDF = float(a.EDF)
	return int( ( (((power * EDF * 2) * 0.0021786) + (power * 0.16667)) ) + ( ((EDF * 2 * 0.010599) * sqrt(power)) * 0.1 ) )

static func getRange(user, target) -> int:
	var result:int = 0
	if user.row == 0:
		if target.row == 0: result = 0
		else:               result = 1
	else:
		if target.row == 0: result = 1
		else:               result = 2
	return result

func calculateDamage(a, b, args) -> float:
	var field     = core.battle.control.state.field.bonus #Current EF bonuses.
	var ATK:float = float(a[core.stats.STATS[args.dmgStat]])
	var DEF:float
	if args.energy: DEF = b.EDF + core.percentMod(args.armorDefs[1], args.armorValue)
	else          : DEF = b.DEF + core.percentMod(args.armorDefs[0], args.armorValue)
	print("[SKILL][calculateDamage] Adding +%02d to damage stat from field bonus" % field[args.element])
	ATK += field[args.element] #Boost base damage by element field bonus as raw damage.
	var comp:float     = DEF / ATK
	var baseDMG:float  = 0.0
	var finalDMG:float = 0.0
	if comp > 1.0:
		baseDMG = ((( 1.0 - ((sqrt(sqrt(comp))) * .7)) * (ATK * 3)) - (DEF * .2) * .717 )
	else:
		baseDMG = ((( .3 + (pow((1.0 - comp), 3.0) * 1.7)) * (ATK * 3)) - (DEF * .2) * .717 )
	finalDMG = baseDMG * args.power
	return finalDMG

func calculateCrit(aLUC, bLUC, mods:int, bonus:int = 0) -> bool:
	var val:int = ( ((aLUC + 25) * 100) as float / (bLUC + 25) as float ) as int
	val = int(clamp(val, 30, 300)) + mods + bonus
	var rand:int = randi() % 1000
	if rand < val: return true
	else:          return false

func checkDrawRate(user, target, S):
	if S.category != CAT_ATTACK: return target
	var group = target.group
	var finalTarget = target
	for i in group.activeMembers():
		if i.battle.decoy > 0:
			if core.chance(i.battle.decoy) and i.battle.decoy >= finalTarget.battle.decoy and i.filter(S):
				finalTarget = i
	if target != finalTarget:
		print("[SKILL][CHECKDRAWRATE] Attack drawn by %s!" % finalTarget.name)
		msg("But %s attracted the attack!" % finalTarget.name)
	return finalTarget

func checkDrawRateRow(user, targets, S):
	if S.category != CAT_ATTACK: return targets
	var group = targets[0].group
	var finalTarget = targets[0]
	for i in group.activeMembers():
		if i.battle.decoy > 0:
			if core.chance(i.battle.decoy / (1 if i.row == targets[0].row else 5)) and i.battle.decoy >= finalTarget.battle.decoy and i.filter(S):
				finalTarget = i
	if finalTarget.row == targets[0].row:
		return targets
	else:
		print("[SKILL][CHECKDRAWRATEROW] Row-wide attack drawn by %s!" % finalTarget.name)
		msg("But %s attracted the attack!" % finalTarget.name)
		return group.getRowTargets(finalTarget.row, S)

func checkHit(a, b, sACC:int = 95, dodge:int = 0, blind:bool = false) -> bool:
	var comp:float = float(((float(a.AGI) * 2.0) + float(a.LUC)) * 10.0) / ((float(b.AGI) * 2) + float(b.LUC) + 0.00001)
	var val:float  = 0.0
	var rand:int   = randi() % 100
#	var ACC:float  = clamp(sACC as float - dodge as float, 0, 200)
#	if comp < 10: val = (ACC * 10) * (1.0 - pow(1.0 - ((sqrt(comp * .1) * 10) * .1), 2))
#	else:         val = (87.5 + (((comp / 20.0) * 50.0) * (comp * 2.5)) * (ACC * .01)) * .1
#
	val = comp + (95 * ((sACC - dodge) * 0.01))
	val = ceil(clamp(val, 0, 200))
	if blind: val *= .5
	print("\t[checkHit] Val:%s (A:AGI:%s LUC:%s|B:AGI:%s LUC:%s)|COMP:%s|ACC:%s|Dodge:%s|RNG:%s"
	 % [val, a.AGI, a.LUC, b.AGI, b.LUC, comp, sACC, dodge, rand])
	if rand <= val: return true
	else: return false

func calculateRangedDamage(ranged:bool, user, target) -> float:
	if ranged:
		print("Ranged attack, skipping range checks.")
		return 1.0
	else:
		if user.row != 0 or target.row != 0:
			print("Range check: Far, halving damage!")
			return 0.5
		else:
			print("Range check: Melee, normal damage!")
			return 1.0

func canHit(S, level:int, user, target, state, crit = false) -> bool:
	if target.filter(S):
		if state.nomiss: return true #Ignores everything, always hits. TODO: Make event flags that bypass this?
		if not target.damagePreventionPass(S, user, state.element, crit): return false #Check if hit can be fully prevented.
		return checkHit(user.battle.stat, target.battle.stat, state.accMod, target.battle.dodge, bool(user.condition2 & CONDITION2_BLIND))
	return false

func barrierDamage(S, user, target, state, value:int, flags:int) -> void:
	var field:Array          = core.battle.control.state.field.bonus
	var dmg:float            = 0.0
	var crit:bool            = false
	var specials:Dictionary  = { guardBreak = false, barrierFullBlock = false }
	if target.filter(S):
		if target.barrier <= 0:
			print("[SKILL][barrierDamage] No barrier to damage, exiting.")
			return
		dmg  = state.dmgBonus + value
		crit = calculateCrit(user.battle.stat.LUC, target.battle.stat.LUC, state.critMod, 0)
		if crit: print("[SKILL][barrierDamage] Critical hit.")
		var args = {
			element     = state.element,
			dmgStat     = state.dmgStat,
			power       = dmg * .01,
			energy      = state.energy,
			armorValue  = 0,
			armorDefs   = [0,0]
		}
		dmg  = calculateDamage(user.battle.stat, target.battle.stat, args)
		dmg *= calculateRangedDamage(state.ranged, user, target)
		if field[args.element] > 0: dmg = core.battle.control.state.field.calculate(dmg, args.element, state.fieldEffectMult)
		if crit                   : dmg *= 1.5
		dmg = round(dmg)
		var finalDmg:int = int(dmg)
		print("[SKILL][barrierDamage] Total barrier damage: %s" % finalDmg)
		var temp:int = target.damageBarriers(finalDmg, specials)

func magicNumberDecode(code:int, value:int) -> Dictionary:
	match code:
		OPCODE_ATTACK_EX:
			return {
				power   = core.clampi((value & 0xFFFF000) >> 12, 0, 0xFFFF),
				element = core.clampi((value & 0x0000F00) >> 8 , 0, 0xF),
				energy  = core.clampi((value & 0x00000F0) >> 4 , 0, 1),
				combo   = core.clampi((value & 0x000000F)      , 0, 1),
			}
		OPCODE_FOLLOW, OPCODE_CHASE:
			return {
				rate      = core.clampi((value & 0x0FF000) >> 12, 0, 100),
				decrement = core.clampi((value & 0x000FF0) >> 04, 0, 100),
				element   = core.clampi((value & 0x00000F)      , 0, 0xF)
			}
		OPCODE_DAMAGEBONUS_ON_RANGE:
			return {
				dmg0 = core.clampi((value & 0xFF0000) >> 16, 0, 255),
				dmg1 = core.clampi((value & 0x00FF00) >> 08, 0, 255),
				dmg2 = core.clampi((value & 0x0000FF)      , 0, 255),
			}
		OPCODE_COUNTER:
			return {}
		_:
			return {}

func magicNumberEncode(code:int, values:Array) -> int:
	match code:
		OPCODE_ATTACK_EX: return (values[0] << 12 | values[1] << 8 | values[2] << 4 || values[3])
		_: return 0

func magicNumberEncodeDict(code:int, X:Dictionary) -> int:
	match code:
		OPCODE_ATTACK_EX:
			X.power   = 0 if not 'power'   in X else core.clampi(X.power  , 0, 0xFFFF)
			X.element = 0 if not 'element' in X else core.clampi(X.element, 0, 0xF   )
			X.energy  = 0 if not 'energy'  in X else core.clampi(X.energy , 0, 0x1   )
			X.combo   = 0 if not 'combo'   in X else core.clampi(X.combo  , 0, 0x1   )
			return magicNumberEncode(code, [X.power, X.element, X.energy, X.combo])
		_: return 0

func processDamageEX(S:Dictionary, level:int, user, target, state:SkillState, value:int, flags:int) -> void:
	var state_temp:Dictionary = { element = state.element, energy = state.energy }
	var data:Dictionary       = magicNumberDecode(OPCODE_ATTACK_EX, value)
	if not data: return
	if data.combo and not state.lastHit:
		print("[processDamageEX] Combo defined, but last hit didn't connect, exiting.")
		return
	#Temporarily overwrite state properties.
	state.element_set(data.element, target)
	state.energy = data.energy
	processDamage(S, level, user, target, state, data.power, flags)
	#Restore state back.
	state.element = state_temp.element
	state.energy  = state_temp.energy

func damageBonusOnRange(user, target, value:int) -> int:
	var data:Dictionary = magicNumberDecode(OPCODE_DAMAGEBONUS_ON_RANGE, value)
	var rang:int = getRange(user, target)
	match rang:
		0: return data.dmg0
		1: return data.dmg1
		2: return data.dmg2
		_: return 0


func processDamage(S, level:int, user, target, state, value:int, flags:int) -> void:
	var field:Array          = core.battle.control.state.field.bonus
	var dmg:float            = 0.0
	var a                    = user.battle.stat
	var b                    = target.battle.stat
	var dmgPercent:float     = 0.0
	var crit:bool            = false
	var specials:Dictionary  = { guardBreak = false, barrierFullBlock = false }
	var hitInfo:Array        = state.hitRecord
	var args:Dictionary
	var temp:Array
	state.lastHit = false
	print("\tDAMAGE: <%s> %05d + %05d = %05d power + %05d raw damage" % ["NRG" if state.energy else "KIN", value, state.dmgBonus, state.dmgBonus + value, state.dmgAddRaw])
	crit = calculateCrit(a.LUC, b.LUC, state.critMod, user.battle.critBonus) #Check if this individual attack crits beforehand.
	if crit:
		print("\tCritical hit check passed.")
	if canHit(S, level, user, target, state, crit):
		state.lastHit = true                #It connected. Start processing it.
		dmg = state.dmgBonus + value
		args = {
			element     = state.element,           #Current element.
			dmgStat     = state.dmgStat,           #Main damage stat.
			power       = dmg * .01,               #Skill power multiplier.
			energy      = state.energy,            #Energy/Kinetic damage.
			armorValue  = 100 - state.ignoreArmor, #Ignore armor value.
			armorDefs   = target.armorDefs ,       #Armor values to add
		}
		dmg = calculateDamage(a, b, args)   #Calculate base damage.
		temp = target.damageResistModifier(dmg, state.element, state.energy)
		dmg = temp[0]                       #Damage modified by elemental resistances.
		dmg *= calculateRangedDamage(state.ranged, user, target) #Apply range multiplier.
		print("\tDamage so far: %05d, adding raw +%05d (=%05d)" % [dmg, state.dmgAddRaw, dmg+state.dmgAddRaw])
		dmg += state.dmgAddRaw              #Add raw damage bonus this late so it's actually raw, but enhanced by crit.
		if field[args.element] > 0:         #Check for field effect bonuses.
			dmg = core.battle.control.state.field.calculate(dmg, args.element, state.fieldEffectMult)
		if crit:                            #Critical hit, x1.5 damage.
			print("\tCritical hit! (%s x 1.5 = %s)" % [dmg, dmg * 1.5])
			dmg *= 1.5
		user.battle.turnHits += 1           #Raise statistics.
		match temp[1]:                      #Check for weakness/resist, 0 if neutral hit.
			1: user.battle.weaknessHits += 1 #1 if target is vulnerable.
			2: user.battle.resistedHits += 1 #2 if target resists.
		#-- Final damage --------------------------------------------------------
		dmg = target.finalizeDamage(round(dmg), specials, state.ignoreDefs, state.nocap)
		print("\tFinal damage: %05d" % dmg)
		var info:Array = target.damage(dmg, crit, temp[1], state.nonlethal) #Deal the final amount here
		dmgPercent = (dmg / float(target.maxHealth())) * 100 #Get damage%.
		state.lastHit   = true  #Last hit connected, so register it so skills can check for "if_connect"
		state.anyHit    = true  #Any hit in the state connected, so always set it here.
		state.setEffect = true if S.effect != EFFECT_NONE else false
		if state.drainLife > 0: #Drain life effects
			print("\tLife drain: %s%%" % state.drainLife)
			user.heal( int(dmg * core.percent(state.drainLife)) )

		#Set hit information with the following parameters:
		#[0]: Final damage [1]: Critical [2]: Overkill [3]: Weak/Strong [4]: Specials [5]: Damage% [6]: Defeat
		hitInfo.push_back([dmg, crit, info[0], temp[1], specials, dmgPercent, info[1]])
		# Set statistics.
		user.battle.turnDealtDMG        += dmg
		user.battle.accumulatedDealtDMG += dmg
		state.finalDMG += dmg as int #Raise total damage for this state.
	else: #Attack missed.
		target.dodgeAttack(user)
		state.lastHit = false #Last hit didn't connect, so ensure if_connect fails after this.

func processDamageRaw(S, user, target, value, percent) -> int:                 #Cause raw damage to target.
	var dmg:int = 0
	if percent:
		dmg = int(float(target.maxHealth()) * (float(value) * 0.01))
	else:
		dmg = value
	if dmg > 0:                                                                   #TODO: Add damage messages, add a flag to bypass resistances.
		target.damage(dmg)
	return dmg

func damageRaw(S, level, user, target, state, value:int, flags:int = 0, bonus:bool = false) -> void:
	var defeats:bool = false
	var temp:float = ( float(target.maxHealth()) * core.percent(value) ) if flags & OPFLAG_VALUE_PERCENT else value as float
	if bonus: #Add elemental bonuses.
		temp = core.battle.control.state.field.calculate(temp, state.element, state.fieldEffectMult)
	if temp > 0:
		var info = target.damage(temp)
		if info[1]:
			defeats = true

func processHeal(S, state, user, target, value:float) -> float:
	var field = core.battle.control.state.field.bonus
	var fieldBonus:float  = 0.0
	var elementKey:String = ""
	if state.element > 0:
		print("Heal so far: %05d, adding raw +%05d (=%05d)" % [value, state.healAddRaw, value+state.healAddRaw])
		value += state.healAddRaw
		elementKey = core.stats.getElementKey(state.element)
		print("User elemental modifier: %d %d%% = %d + %d raw" % [state.element, user.battle.stat.OFF[elementKey], value * core.percent(user.battle.stat.OFF[elementKey]), field[state.element]])
		value += field[state.element]
		value *= core.percent(user.battle.stat.OFF[elementKey])
		value = core.battle.control.state.field.calculate(value, state.element, state.fieldEffectMult)
		state.anyHit = true
	return value

func printSkillMsg(S, user, target, value) -> bool:
	if value == 0:
		print("\t[SKILL][printSkillMsg] Value is zero, stopping.")
		return false
	if S.messages != null:
		var colorize = funcref(core.battle.control.state, "colorName") #For convenience.
		value -= 1 # Reduce value by one to adapt it to zero-indexed arrays.
		if value <= S.messages.size(): #Value is valid, output message and request delay.
			#Form the dictionary with the formatting values.
			var dict = {
				'USER'  : "[color=#%s]%s[/color]" % [colorize.call_func(user), user.name],
				'TARGET': "[color=#%s]%s[/color]" % [colorize.call_func(target), target.name],
				'SKILL' : "[color=#%s]%s[/color]" % [S.name, 'ABABAB'],
			}
			msg(str(S.messages[value]).format(dict)) #Use godot's builtin format(). {SUBSTITUTIONS} must be allcaps!
			return true
		else: # Value out of range, do not print anything, do not force delay.
			print("\t[SKILL][printSkillMsg] Value out of range, stopping.")
			return false
	return false

func msg(text) -> void:
	core.battle.skillControl.echo(text)

func selectTargetAuto(S, level:int, user, state):
	var side:int = 0 if S.targetGroup == TARGET_GROUP_ALLY else 1
	match S.target[level]:
		TARGET_SELF             : return [ user ]
		TARGET_ALL              : return state.formations[side].getAllTargets(S)
		TARGET_ALL_NOT_SELF     : return state.formations[side].getAllTargetsNotSelf(S, user)
		TARGET_SELF_ROW         : return user.group.getRowTargets(user.row, S)
		TARGET_SELF_ROW_NOT_SELF: return user.group.getRowTargetsNotSelf(user.row, S, user)
		TARGET_NOT_SELF_ROW     : return user.group.getOtherRowTargets(user.row, S, user)
		TARGET_ROW_BACK         : return state.formations[side].getRowTargets(1, S)
		TARGET_ROW_FRONT        : return state.formations[side].getRowTargets(0, S)
		TARGET_SINGLE:
			var temp = state.formations[side].getAllTargets(S)
			if temp.size() == 1:
				return temp
			else:
				return null
		_: return null

func selectPostTargets(S, level:int, user, group):
	match S.targetPost[level]:
		TARGET_ALL              : return group.getAllTargets(S)
		TARGET_ALL_NOT_SELF     : return group.getAllTargetsNotSelf(S, user)
		TARGET_SELF_ROW         : return user.group.getRowTargets(user.row, S)
		TARGET_SELF_ROW_NOT_SELF: return user.group.getRowTargetsNotSelf(user.row, S, user)
		TARGET_NOT_SELF_ROW     : return user.group.getOtherRowTargets(user.row, S, user)
		TARGET_ROW_BACK         : return group.getRowTargets(1, S)
		TARGET_ROW_FRONT        : return group.getRowTargets(0, S)
		_: return [ user ]

func calculateTarget(S, level:int, user, _targets) -> Array:
	var targets:Array      = []
	var finalTargets:Array = []
	var temp               = null
	match S.target[level]:
		TARGET_SELF:  targets.push_front(user) #Target is user. Nothing special needed.
		TARGET_SINGLE, TARGET_SINGLE_NOT_SELF: #Single target, check if the original target is gone.
			if _targets and _targets[0].filter(S):
				temp = checkDrawRate(user, _targets[0], S)
				targets.push_front(temp)
			else: #Target didn't pass filter criteria, meaning it's changed since selection.
				if S.category == CAT_ATTACK: #In the case of attacks, pick another target.
					#TODO: See if something can be done in the case of repeating last actions, so if there aren't optimal targets or results are ambiguous, it brings up the target selection again.
					print("[SKILL][calculateTarget] Target didn't match filter, picking another target...")
					var newtarget = user.group.getRandomTarget(S) if S.targetGroup == TARGET_GROUP_ALLY else user.group.versus.getRandomTarget(S)
					if newtarget != null and newtarget[0] != null:
						targets.push_front(newtarget[0])
						print("[SKILL][calculateTarget] New target is %s" % newtarget[0].name)
					else:
						print("[SKILL][calculateTarget] No suitable targets for %s found, skill fails." % S.name)
		TARGET_ROW: #Row target, update with current row.
			temp = checkDrawRateRow(user, _targets, S)
			for i in temp:
				if i.filter(S):
					targets.push_front(i)
		TARGET_ROW_BACK:
			targets = user.group.getRowTargets(1, S) if S.targetGroup == TARGET_GROUP_ALLY else user.group.versus.getRowTargets(1, S)
		TARGET_ROW_FRONT:
			targets = user.group.getRowTargets(0, S) if S.targetGroup == TARGET_GROUP_ALLY else user.group.versus.getRowTargets(0, S)
		TARGET_SELF_ROW:          targets = user.group.getRowTargets(user.row, S) #User's row.
		TARGET_SELF_ROW_NOT_SELF: targets = user.group.getRowTargetsNotSelf(user.row, S, user) #User's row, but not self.
		TARGET_NOT_SELF_ROW:      targets = user.group.getOtherRowTargets(user.row, S, user) #The other row from the user's group.

		TARGET_ALL, TARGET_RANDOM1, TARGET_RANDOM2: #All targets. Update with whatever is active now.
			targets = user.group.getAllTargets(S) if S.targetGroup == TARGET_GROUP_ALLY else user.group.versus.getAllTargets(S)
		TARGET_ALL_NOT_SELF: #Same, but if somehow targeting the other team, don't bother looking for self.
			targets = user.group.getAllTargetsNotSelf(S, user) if S.targetGroup == TARGET_GROUP_ALLY else user.group.versus.getAllTargets(S)

	for i in targets:
		var T = i.checkProtect(S)
		if T[0]:
			msg("But [color=#%s]%s[/color] protected %s!" % [core.battle.control.state.colorName(T[1]), T[1].name, i.name])
			finalTargets.push_back(T[1])
		else:
			finalTargets.push_back(i)
	return finalTargets

func addEffect(S, level:int, user, target, state):
	if target is core.Player:
		var what:int = 0
		match S.effectType:
			EFFTYPE_BUFF:    what = core.lib.item.COUNTER_BUFF
			EFFTYPE_DEBUFF:  what = core.lib.item.COUNTER_DEBUFF
		if what != 0:
			var IT:Array = target.group.inventory.canCounterEvent(what)
			if not IT.empty():
				target.group.inventory.takeConsumable(IT[0])
				print("\t[SKILL][addEffect] %s was protected by %s!" % [target.name, IT[0].data.lib.name])
				msg("%s was protected by %s!" % [core.battle.control.state.color_name(target), IT[0].data.lib.name])
				target.display.message(str(">EFFECT BLOCKED BY %s" % IT[0].data.lib.name), "00FFFF")
			else:
				target.addEffect(S, level, user)
	else:
		target.addEffect(S, level, user)


# SKILL PROCESSING ################################################################################

func process(S, level:int, user, targets, WP = null, IT = null, skipAnim:bool = false):
	print("\n[SKILL][PROCESS] ### %s's action: %s ############################################\n" % [user.name, S.name])
	if IT != null:    msg(str("[color=#%s]%s[/color] used [color=#80E36E]%s[/color]!" % [core.battle.control.state.colorName(user), user.name, IT.data.lib.name]))
	else:             msg(str("[color=#%s]%s[/color] used [color=#EEFF80]%s[/color]!" % [core.battle.control.state.colorName(user), user.name, S.name]))
	match S.category: #TODO:...let's leave it this way for now.
		CAT_ATTACK, CAT_SUPPORT, CAT_OVER:
			core.battle.control.state.lastElement = 0
			processCombatSkill(S, level, user, targets, WP)
	#return SKILL_FAILED

func initSkillState(S, level:int, user, target) -> SkillState:
	return SkillState.new(S, level, user, target)

func initSkillInfo() -> Dictionary:
	return { anyHit = false, postTargetGroup = 0 }

func processCombatSkill(S, level:int, user, targets, WP = null, IT = null, skipAnim:bool = false):
	var controlNode = core.battle.skillControl
	var temp        = null
	var tempTarget  = null
	var control     = null
	var state:SkillState
	user.charge(false) #Stop charging FX now.
	if IT != null: #Using an item, override some things.
		#TODO: Put item bonuses somewhere here.
		user.setAD(user.battle.itemAD, true)
	else:	user.setAD(S.AD[level], true) #Set active defense on execution regardless of success.
	#print("%s sets Active Defense: %s" % [user.name, user.battle.AD])
	if WP != null: #Using a weapon
		user.setWeapon(WP)
		print("[SKILL][processCombatSkill] Switching weapon: %s (L:%s)" % [WP.lib.name, WP.level])
	var info = initSkillInfo()

	# Skill pre-main setup #####################################################
	info.postTargetGroup = 1 if S.codePO != null else 0 #Assume a post-main code is wanted if it's defined. Allow to cancel with codes.
	if S.codeST != null: #Has a setup part. Initialize state here, copy for individual targets.
		state = initSkillState(S, level, user, user)
		control = controlNode.start()
		setupSkillCode(S, level, user, user, CODE_ST, control, state)
	# Main skill body ##########################################################
	for j in targets: #Start a skill state for every target unless a ST state exists.
		tempTarget = j
		if tempTarget.filter(S): #Target is valid.
			if not skipAnim:
				core.battle.displayManager.addHitSpark(S, level, tempTarget.sprite.effectHook)
			control = controlNode.start()
			processSkillCode(S, level, user, tempTarget, CODE_MN, control, state, info, WP)
	# Post-main setup ##########################################################
	if S.codePO != null and info.postTargetGroup > 0: #Has a post-main part. Use a fresh state but set some variables.
		#postTargetGroup is enabled by default but a skill can stop it from triggering if postTargetGroup is set to -1
		print("[SKILL][processCombatSkill] Post skill code starting.")
		var po_targets = selectPostTargets(S, level, user, user.group.versus if info.postTargetGroup == 2 else user.group)
		if po_targets != null:
			for j in po_targets:
				var po_state = initSkillState(S, level, user, j)
				po_state.anyHit = info.anyHit
				control = controlNode.start()
				processSkillCode(S, level, user, j, CODE_PO, control, po_state)
				print("[SKILL][processCombatSkill] Post skill code finished.")
	# Elemental Field updating #################################################
	if core.battle.control.state.lastElement != 0:
		print("[SKILL][processCombatSkill] Adding element %d to field x%02d" % [core.battle.control.state.lastElement, S.fieldEffectAdd[level]])
		user.group.lastElement = core.battle.control.state.lastElement
		for i in range(S.fieldEffectAdd[level]):
			#TODO: Add FE Guard effects here and in the standard functions.
			#Add effect as a percentage for each group.
			core.battle.control.state.field.push(core.battle.control.state.lastElement)
	user.updateChain(S.chain) 	#TODO: Get info about last action to see if it hit or not
	controlNode.finish()

func runExtraCode(S, level:int, user, code_key, target = null):
	var code = null; var codeName = ''; var codePost = null
	match code_key:
		CODE_PR:
			code = S.codePR; codeName = "PR"; codePost = CODE_PP
		CODE_EF:
			code = S.codeEF; codeName = "EF"; codePost = CODE_EP
		CODE_GD:
			code = S.codeGD; codeName = "GD"; codePost = null
	print("[SKILL][runExtraCode] %s's action code%s: %s" % [user.name, codeName, S.name])
	var control = core.battle.skillControl.start()
	var info = initSkillInfo()
	processSkillCode(S, level, user, target if target != null else user, code_key, control, null, info)
	print("[SKILL] %s CODE FINISH" % codeName)

	if codePost != null and info.postTargetGroup > 0: #Has a post-main part. Use a fresh state but set some variables.
		#postTargetGroup is enabled by default but a skill can stop it from triggering if postTargetGroup is set to -1
		print("[SKILL][runExtraCode] Post skill code starting.")
		var po_targets = selectPostTargets(S, level, user, user.group.versus if info.postTargetGroup == 2 else user.group)
		if po_targets != null:
			for j in po_targets:
				var po_state = initSkillState(S, level, user, j)
				po_state.anyHit = info.anyHit
				control = core.battle.skillControl.start()
				processSkillCode(S, level, user, user, codePost, control, po_state)
				print("[SKILL][runExtraCode] Post skill code finished.")
	core.battle.skillControl.finish()


func processFL(S, level:int, user, target, data, type) -> void:
	print("%s's action FL on %s => %s LV%d" % [user.name, target.name, S.name, level])
	match type:
		ONHIT_FOLLOWUP, ONHIT_CHASE:
			msg("[color=#%s]%s[/color] followed with %s!%s" % [
				core.battle.control.state.colorName(user),
				user.name, S.name,
				(" [color=#888888](next %03d%%)[/color]" % data[0]) if data[0] > 0 else ""
				])
		ONHIT_COUNTER:
			msg("[color=#%s]%s[/color] countered with %s!%s" % [
				core.battle.control.state.colorName(user),
				user.name, S.name,
				(" [color=#888888](next %03d%%)[/color]" % data[0]) if data[1] > 0 else ""
				])
	core.battle.skillControl.startAnim(S, level, 'onfollow', target.sprite.effectHook)
	processSkillCode(S, level, user, target, CODE_FL)
	print("[%s] CodeFL finished" % S.name)

func processED(S, level:int, user, target) -> void:
	print("[SKILL][ProcessED]%s's ED action: %s" % [user.name, S.name])
	var control = core.battle.skillControl.start()
	processSkillCode(S, level, user, target, CODE_ED, control)
	print("[%s] CodeED finished" % S.name)

func setupSkillCode(S, level:int, user, target, _code, control, state):#TODO: unify all these functions.
	processSkillCode2(S, level, user, target, _code, state, control)
	if state.setEffect and _code == CODE_MN:
		print("Effect from %s " % [S.name])
		addEffect(S, level, user, target, state)
		state.anyHit = true
		control.stop()
	print("[%s] Setup finished" % S.name)


const CODEBLOCKS_ONHIT = [CODE_MN, CODE_FL]
func processSkillCode(S, level:int, user, target, codeblock:int, control = core.battle.skillControl.start(), _state = null, info = null, WP = null):
	var state:SkillState = initSkillState(S, level, user, target) if _state == null else _state.duplicate()
	if WP != null:
		match S.category:
			CAT_ATTACK:
				if WP.lib.codeWPA0 != null:
					print("[SKILL][processSkillCode][%s] has WPA0 code block. Running." % WP.lib.name)
					runSkillCode(S, level, state, WP.lib.codeWPA0, user, target)
			CAT_SUPPORT:
				if WP.lib.codeWPS0 != null:
					print("[SKILL][processSkillCode][%s] has WPS0 code block. Running." % WP.lib.name)
					runSkillCode(S, level, state, WP.lib.codeWPS0, user, target)

	processSkillCode2(S, level, user, target, codeblock, state, control)
	print("[SKILL][PROCESSSKILLCODE] Skill %s code block:%s complete, checking effects" % [S.name, codeblock])
	if state.setEffect and codeblock == CODE_MN:
		print("\t[SKILL][processSkillCode] Effect from %s " % [S.name])
		addEffect(S, level, user, target, state)
		#msg("%s was affected!" % [target.name])
		state.anyHit = true
	if state.hitRecord:
		core.battle.control.state.logHitRecord(user, target, state)
		state.hitRecord.clear()

# Post skill actions ##################################################################################
# TODO: Post skill actions should be renamed.
	if state.anyHit and codeblock in CODEBLOCKS_ONHIT:         #Proc on hit actions.
		core.battle.control.state.lastElement = state.element #Store last element for later
		target.updateFollows() #Update target's followup actions, purge excess ones etc.
		if user.battle.follow.size() > 0 and S.category == CAT_ATTACK: #User following with another skill.
			for i in user.battle.follow:
				if i[5] == 0 or (i[5] == state.element):
					if user.canFollow(i[3], i[4], target) and user != target and core.chance(i[1]):
						i[1] -= i[2]
						core.battle.control.state.onhit.push_back([target, i, ONHIT_FOLLOWUP])
		if target.battle.chase.size() > 0 and S.category == CAT_ATTACK: #Target has a chase set.
			for i in target.battle.chase:
				if i[5] == 0 or (i[5] == state.element):
					if i[0].canFollow(i[3], i[4], target) and user != i[0] and core.chance(i[1]):
						i[1] -= i[2]
						core.battle.control.state.onhit.push_back([target, i, ONHIT_CHASE])
		#Check for counters.
		var C = target.canCounter(user, state.element, state.counter)
		if C[0] and S.category == CAT_ATTACK: #Cannot counterattack Over skills.
			core.battle.control.state.onhit.push_back([user, C[1], ONHIT_COUNTER])
	if WP != null:
		match S.category:
			CAT_ATTACK:
				if WP.lib.codeWPA1 != null:
					print("[SKILL][processSkillCode][%s] has WPA1 code block. Running." % WP.lib.name)
					runSkillCode(S, level, state, WP.lib.codeWPA1, user, target)
			CAT_SUPPORT:
				if WP.lib.codeWPS1 != null:
					print("[SKILL][processSkillCode][%s] has WPS1 code block. Running." % WP.lib.name)
					runSkillCode(S, level, state, WP.lib.codeWPS1, user, target)

	if state.follow[5]: #Set follow parameters. User will add one skill (CODE_FL) after their next action.
		print("[SKILL][PROCESSSKILLCODE] %s set to follow with params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [target.name, state.follow[0].name, state.follow[1], state.follow[2], str(state.follow[3].name), state.follow[4], state.follow[6]])
		target.battle.follow.push_front([target, state.follow[1], state.follow[2], state.follow[3], state.follow[4], state.follow[6]])

	if state.anyHit: #Set chase parameters. When target is hit, make the one who set the chase add one skill (CODE_FL) after this action.
		if state.chase[5]:
			print("[SKILL][PROCESSSKILLCODE] %s set to chase with params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [target.name, state.chase[0].name, state.chase[1], state.chase[2], str(state.chase[3].name), state.chase[4], state.chase[6]])
			target.battle.chase.push_front([state.chase[0], state.chase[1], state.chase[2], state.chase[3], state.chase[4], state.chase[6]])

	if info != null:
		print("[SKILL][PROCESSSKILLCODE] info storage found.")
		if state.anyHit  : info.anyHit = true
		if state.post > 0: info.postTargetGroup = state.post

	print("[SKILL][PROCESSSKILLCODE] %s finished" % S.name)
	control.stop()
	print("[SKILL][PROCESSSKILLCODE] %s control stopped" % S.name)


func s_if(cond:bool = false, flags:int = 0) -> bool: #Wrapper to be able to easily negate logic expressions with a logic not flag.
	if flags & OPFLAG_LOGIC_NOT: cond = not cond
	return cond

func effectCheck(S, level:int, user, target, state) -> bool:
	if S.effect != EFFECT_NONE:
		if state.nomiss or S.category == CAT_OVER or target == user:
			print("[%s] Provides an effect. Conditions make it apply." % S.name)
			return true
		else:
			print("[%s] Provides an effect. Performing accuracy check." % S.name)
			if checkHit(user.battle.stat, target.battle.stat, state.accMod, target.battle.dodge, bool(user.condition2 & CONDITION2_BLIND)):
				print("Accuracy check passed.")
				return true
			else:
				print("Accuracy check failed.")
				return false
	return false

func processSkillCode2(S, level:int, user, target, _code, state:SkillState, control):
	level = 0  #TODO: Remember this is here...
	var code        = null

	match _code:
		CODE_PR: code = S.codePR #Priority code
		CODE_PP: code = S.codePP #Post-priority code
		CODE_ST: code = S.codeST #Setup code
		CODE_MN: code = S.codeMN #Main code
		CODE_PO: code = S.codePO #Post-main code
		CODE_EF: code = S.codeEF #Effect code
		CODE_EP: code = S.codeEP #Post-effect code
		CODE_ED: code = S.codeED #Effect end code
		CODE_FL: code = S.codeFL #Follow code
		CODE_GD: code = S.codeGD #Global Down code
	if code == null:
		print("[%s] No skill code %02d found. Taking no action." % [S.name, _code])
		state.setEffect = effectCheck(S, level, user, target, state)
		print("[%s] Code processing finished. Emitting skill_continue signal" % S.name)
		return
	else:
		runSkillCode(S, level, state, code, user, target)


func runSkillCode(S, level:int, state:SkillState, code:Array, user, target) -> void:
	if code == null: return
	else:
		var line            = null
		var skipLine:bool   = false
		var cond_block:bool = false
		var dmg             = 0
		var args            = null
		var flags           = null
		var value           = 0
		var variableTarget  = target
		var a               = user.battle.stat
		var b               = variableTarget.battle.stat
		var b2              = b
		var scriptSize      = code.size()

		for j in range(scriptSize):
			line = code[j]
			value = line[level + 1]
			flags = line[11]
			print("[%s]%02d>OPCODE:%03d VALUE:%03d(LV%02d) FLAGS:%03d [SVAL:%d]" % [S.name, j, line[0], value, level, flags, state.value])

			#Check if current line overrides target to self for compatible funcs.
			if flags & OPFLAG_TARGET_SELF:
				variableTarget = user
				b2 = a
			else:
				variableTarget = target
				b2 = b
			#Check if current line overrides value.
			if flags & OPFLAG_USE_SVAL:
				print("[%s]%02d> USING STORED VALUE [sval = %s]) INSTEAD OF PROVIDED VALUE (%s) ##" % [S.name, j, state.value, value])
				value = state.value

			if not skipLine:
				match line[0]:

# Standard combat functions ####################################################
					OPCODE_ATTACK:
						print(">ATTACK: ", value)
						if value > 0:
							if variableTarget.filter(S): processDamage(S, level, user, variableTarget, state, value, flags)
							else                       : print("[!!]Target doesn't meet targetting filter anymore, skipping.")
					OPCODE_ATTACK_COMBO:
						print(">COMBO ATTACK: ", value)
						if state.lastHit and value > 0:
							if variableTarget.filter(S):
								processDamage(S, level, user, variableTarget, state, value, flags)
							else:
								print("[!!]Target doesn't meet targetting filter anymore, skipping.")
						else: print("\tLast hit didn't connect. Skipping.")
					OPCODE_ATTACK_EX:
						print(">ATTACK EX: ", value, " 0x%X" % value)
						if variableTarget.filter(S):
							processDamageEX(S, level, user, variableTarget, state, value, flags)
						else:
							print("[!!]Target doesn't meet targetting filter anymore, skipping.")
					OPCODE_DEFEND:
						print(">DEFEND(%s)" % value)
						if value > 0: variableTarget.defend()
					OPCODE_INFLICT_EX: #Inflicts conditions.
						print(">INFLICT: ", value, " 0x%X" % value)
						if value > 0x100:
							variableTarget.tryInflict(user, value, state.critMod, state.lastHit)
					OPCODE_DAMAGERAW:
						print(">RAW DAMAGE: %s" % value)
						state.finalDMG += processDamageRaw(S, user, variableTarget, value, true if flags & OPFLAG_VALUE_PERCENT else false)
					OPCODE_DEFEAT:
						print(">DEFEAT: %s" % value)
						if core.chance(value):
							print("Check passed, %s is defeated." % variableTarget.name)
							variableTarget.defeat()
							if user == variableTarget:
								print("[SKILL][DEFEAT] User is not active, aborting execution")
						else:
							print("Check failed, no effect.")
					OPCODE_TRYRUN:
						print(">[TODO] TRY TO RUN: %s" % value)
					OPCODE_RUN:
						print(">[TODO] RUN: %s" % value)
# Chains and follows and counters #############################################
					OPCODE_FOLLOW:
						print(">FOLLOW: ", value, " 0x%X" % value)
						state.follow[5] = true
						state.follow[1] = core.clampi((value & 0x0FF000) >> 12, 0, 100)
						state.follow[2] = core.clampi((value & 0x000FF0) >> 04, 0, 100)
						state.follow[6] = core.clampi((value & 0x00000F)      , 0, 015)
						if state.follow[6] == 0: state.follow[6] = state.element
						elif state.follow[6] == 15: state.follow[6] = 0
						variableTarget.display.message("FOLLOW: %s!" % S.name, messageColors.followup)
						print("Follow params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [state.chase[0].name, state.chase[1], state.chase[2], str(state.chase[3].name), state.chase[4], state.chase[6]])
					OPCODE_CHASE:
						print(">CHASE: ", value, " 0x%X" % value)
						state.chase[5] = true
						state.chase[1] = core.clampi((value & 0x0FF000) >> 12, 0, 100)
						state.chase[2] = core.clampi((value & 0x000FF0) >> 04, 0, 100)
						state.chase[6] = core.clampi((value & 0x00000F)      , 0, 015)
						if state.chase[6] == 0: state.chase[6] = state.element
						elif state.chase[6] == 15: state.chase[6] = 0
						variableTarget.display.message("CHASE: %s!" % S.name, messageColors.followup)
						print("Chase params: [Name = %s, Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock: %d]" % [state.follow[0].name, state.follow[1], state.follow[2], str(state.follow[3].name), state.follow[4], state.follow[6]])
					# Counters #####################################################################
					OPCODE_COUNTER:
						print(">COUNTER: ", value, " 0x%X" % value)
						state.counter[0] = core.clampi((value & 0x0FF00000) >> 20, 0, 100)
						state.counter[1] = core.clampi((value & 0x000FF000) >> 12, 0, 100)
						state.counter[5] = core.clampi((value & 0x00000F00) >> 08, 0, 015)
						state.counter[4] = core.clampi((value & 0x000000F0) >> 04, 0, 015)
						state.counter[6] = core.clampi((value & 0x0000000F)      , 0, 015)
						for i in range(7):
							variableTarget.battle.counter[i] = state.counter[i]
						variableTarget.display.message("COUNTER: %s!" % S.name, messageColors.followup)
						print("Counter params: [Rate = %d%%, Decrement = %d%%, Skill = %s, Level = %d, Element Lock : %d, Max =  %d]" % [variableTarget.battle.counter[0], variableTarget.battle.counter[1], variableTarget.battle.counter[2].name, variableTarget.battle.counter[3], variableTarget.battle.counter[4], variableTarget.battle.counter[5]])
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
					OPCODE_HEAL: #TODO: Healing functions might be consolidated in functions to save space?
						print(">HEAL(%s)" % value)
						dmg = 0
						if flags & OPFLAG_HEAL_BONUS:
							dmg = calculateHeal(a, state.healBonus)
							print("Bonus healing: %s" % [dmg])
						if flags & OPFLAG_VALUE_ABSOLUTE:
							dmg += value
						elif flags & OPFLAG_VALUE_PERCENT:
							dmg += float(variableTarget.maxHealth()) * core.percent(value)
						else:
							dmg += calculateHeal(a, value)
						dmg = processHeal(S, state, user, variableTarget, dmg)
						dmg = round(dmg)
						variableTarget.heal(dmg)
						state.totalHeal += int(dmg)
						if variableTarget == user:
							msg(str("%s restored %s!" % [user.name, dmg]))
						else:
							msg(str("%s restored %s to %s!" % [user.name, dmg, variableTarget.name]))
					OPCODE_HEAL_MOD:
						print(">HEAL EFFECTIVENESS MOD: ", value)
						variableTarget.battle.healMod += value
						if value > 0: variableTarget.display.message("HEAL RATE UP!", messageColors.buff)
						else:         variableTarget.display.message("HEAL RATE DOWN!", messageColors.debuff)
					OPCODE_HEALROW:
						print(">HEALROW(%s)" % value)
						dmg = 0
						if flags & OPFLAG_HEAL_BONUS:
							dmg = calculateHeal(a, state.healBonus)
							print("Bonus healing: %s" % [dmg])
						if flags & OPFLAG_VALUE_ABSOLUTE:
							dmg += value
						elif flags & OPFLAG_VALUE_PERCENT:
							dmg += float(user.maxHealth()) * core.percent(value)
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
						if flags & OPFLAG_HEAL_BONUS:
							dmg = calculateHeal(a, state.healBonus)
							print("Bonus healing: %s" % [dmg])
						if flags & OPFLAG_VALUE_ABSOLUTE:
							dmg += value
						elif flags & OPFLAG_VALUE_PERCENT:
							dmg += float(user.maxHealth()) * core.percent(value)
						else:
							dmg += calculateHeal(a, value)
						var temptargets = user.group.activeMembers()
						for i in temptargets:
							dmg = processHeal(S, state, user, i, dmg)
							i.heal(dmg)
							state.totalHeal += dmg
					OPCODE_RESTOREPART:
						print(">RESTORE PART: %s" % value)
					OPCODE_REVIVE:
						print(">REVIVE: %s" % value)
						dmg = 0
						if flags & OPFLAG_HEAL_BONUS:
							dmg = calculateHeal(a, state.healBonus)
							print("Bonus healing: %s" % [dmg])
						if flags & OPFLAG_VALUE_ABSOLUTE:
							dmg += value
						elif flags & OPFLAG_VALUE_PERCENT:
							dmg += 999 #TODO: Heal X%
						else:
							dmg += calculateHeal(a, value)
						dmg = processHeal(S, state, user, target, dmg)
						variableTarget.revive(dmg)
					OPCODE_OVERHEAL:
						print(">OVERHEAL[TODO]: %s" % value)
					OPCODE_REINFORCE_ALL:
						print(">REINFORCE ALL: ", value)
						if value > 0: variableTarget.reinforceAll()
					OPCODE_REINFORCE:
						print(">REINFORCE: ", value)
						if value != 0: variableTarget.reinforce(value)
					OPCODE_REINFORCE_EX:
						print(">REINFORCE COMPLEX: ", value, " 0x%X" % value)
						variableTarget.reinforceComplex(value)
					OPCODE_CURE:
						print(">CURE: ", value)
						if value > 0: variableTarget.cure(value)
					OPCODE_CURE_ALL:
						print(">CURE ALL: ", value)
						if value > 0: variableTarget.cureAll()
					OPCODE_CURE_TYPE:
						print(">CURE TYPE: ", value)
						if value > 0: variableTarget.cureType(value)
# Standard effect functions ####################################################
					OPCODE_AD:
						print(">ACTIVE DEFENSE: %s(%s)" % ["=" if flags & OPFLAG_VALUE_ABSOLUTE else "+", value])
						variableTarget.setAD(value, flags & OPFLAG_VALUE_ABSOLUTE)
						print("Total: %s" % variableTarget.battle.AD)
					OPCODE_DECOY:
						print(">DECOY(%s)" % value)
						var oldstat = variableTarget.battle.decoy
						variableTarget.battle.decoy = flaggedSet(variableTarget.battle.decoy, value, flags)
						if variableTarget.battle.decoy < oldstat:
							variableTarget.display.message("DECOY DOWN!", messageColors.statdown)
						else:
							variableTarget.display.message("DECOY UP!", messageColors.statup)
						print("Total: %s" % variableTarget.battle.decoy)
					OPCODE_BLOCK:
						print(">BLOCK(%s)" % value)
						if flags & OPFLAG_VALUE_ABSOLUTE: variableTarget.battle.block = value
						else                            : variableTarget.battle.block += value
						print("Total: %s" % variableTarget.block)
					OPCODE_BARRIER:
						print(">BARRIER(%s)" % value)
						variableTarget.setGuard(value, state.element, flags, state.fieldEffectMult)
						print("Total: %s" % variableTarget.battle.barrier)
					OPCODE_BARRIER_RAW:
						print(">BARRIER RAW(%s)" % value)
						variableTarget.setGuard(value, 0, flags)
						print("Total: %s" % variableTarget.battle.barrier)
					OPCODE_DODGE:
						print(">DODGE RATE: %s" % value)
						var oldstat = variableTarget.battle.dodge
						variableTarget.battle.dodge = flaggedSet(variableTarget.battle.dodge, value, flags)
						if variableTarget.battle.dodge < oldstat:
							variableTarget.display.message("DODGE DOWN!", messageColors.statdown)
						else:
							variableTarget.display.message("DODGE UP!", messageColors.statup)
						print("Total: %s" % variableTarget.battle.dodge)
					OPCODE_FORCE_DODGE:
						print(">FORCED DODGE:" % value)
						var oldstat = variableTarget.battle.forceDodge
						variableTarget.battle.forceDodge = flaggedSet(variableTarget.battle.forceDodge, value, flags)
						if variableTarget.battle.forceDodge > oldstat:
							variableTarget.display.message("PERFECT DODGE", messageColors.statup)
						print("Total: %s" % variableTarget.battle.forceDodge)
					OPCODE_PROTECT:
						print(">PROTECT(%s)" % value)
						if flags & OPFLAG_TARGET_SELF:
							user.battle.protectedBy.push_back([target, value])
							print("%s protects %s (%s%%)" % [target.name, user.name, value])
							variableTarget.display.message("%s protects %s" % [target.name, user.name], messageColors.protect)
						else:
							target.battle.protectedBy.push_back([user, value])
							print("%s protects %s (%s%%)" % [user.name, target.name, value])
							variableTarget.display.message("Protected by %s" % [user.name], messageColors.protect)
					OPCODE_RAISE_OVER:
						print(">RAISE OVER: %s" % value)
						if 'over' in variableTarget:
							variableTarget.over += value
						print("Total: %s" % variableTarget.over)
					OPCODE_DAMAGE_GUARD:
						print(">DAMAGE GUARD: %s" % value)
						if value > 0:
							barrierDamage(S, user, variableTarget, state, value, flags)
					OPCODE_BREAK_GUARD:
						print(">BREAK GUARD: %s" % value)
						if value == 1:
							variableTarget.battle.barrier = 0
							variableTarget.display.message("GUARD BREAK!", messageColors.protect)
					OPCODE_IGNORE_ARMOR:
						print(">IGNORE ARMOR: ", value)
						if value != 0:
							state.ignoreArmor = true
					OPCODE_FE_GUARD:
						print(">FIELD EFFECT GUARD: %s" % value)
					OPCODE_SETVITAL:
						print(">SET VITAL %s" % value)
						variableTarget.HP = flaggedSet(variableTarget.HP, value, flags)
					OPCODE_ENEMY_SUMMON:
						print(">ENEMY SUMMON: %s" % value)
						var sumresult: Array
						var SU = null
						if value == 0:
							print("Zero value summon, taking no action.")
						else:
							value -= 1
							if S.summons != null:
								print("Using skill summon data. val:%d" % value)
								sumresult = core.battle.enemy.trySummon(user, value, S.summons, user.level)
							else:
								print("Normal enemy summon chain val:%d" % value)
								sumresult = core.battle.enemy.trySummon(user, value)
						if sumresult[0]:
							SU = core.lib.enemy.getIndex(sumresult[1].tid)
							if sumresult[1].msg.length() > 0: msg(sumresult[1].msg.format(SU))
						else:
							if sumresult[1] != null:
								if sumresult[1].failmsg.length() > 0: msg(sumresult[1].failmsg.format(SU))
							else:
								print("Unable to summon!")
						#yield(controlNode.wait(0.1), "timeout")
						print("Done.")

# State modifiers ##############################################################
					OPCODE_DAMAGEBONUS:
						print(">DAMAGE BONUS: %s" % value)
						state.dmgBonus = flaggedSet(state.dmgBonus, value, flags)
						print("Damage Bonus - Total: %s" % state.dmgBonus)
					OPCODE_DAMAGEBONUS_ON_COND:
						print(">DAMAGE BONUS IF AFFLICTION: %s" % value)
						if variableTarget.checkInflict():
							state.dmgBonus = flaggedSet(state.dmgBonus, value, flags)
							print("Damage Bonus - Total: %s" % state.dmgBonus)
					OPCODE_DAMAGEBONUS_ON_RANGE:
						print(">DAMAGE BONUS ON RANGE: %s" % value)
						state.dmgBonus = flaggedSet(state.dmgBonus, damageBonusOnRange(user, variableTarget, value), flags)
						print("Damage Bonus - Total: %s" % state.dmgBonus)
					OPCODE_DAMAGE_RAW_BONUS:
						print(">DAMAGE RAW BONUS: %s" % value)
						state.dmgAddRaw = flaggedSet(state.dmgAddRaw, value, flags)
						print("Raw Damage Bonus - Total: %s" % state.dmgAddRaw)
					OPCODE_HEALBONUS:
						print(">HEAL BONUS: %s" % value)
						state.healBonus = flaggedSet(state.healBonus, value, flags)
						print("Healing Bonus - Total: %s" % state.healBonus)
					OPCODE_HEAL_RAW_BONUS:
						print(">HEAL RAW BONUS: %s" % value)
						state.healAddRaw = flaggedSet(state.healAddRaw, value, flags)
						print("Raw Healing Bonus - Total: %s" % state.healAddRaw)
					OPCODE_DAMAGE_EFFECT:
						print(">DAMAGE EFFECT: ", value, " 0x%X" % value)
						variableTarget.tryDamageEffect(user, S, value)
					OPCODE_CRITMOD:
						print(">CRITMOD: %s" % value)
						state.critMod = flaggedSet(state.critMod, value, flags)
						print("\tCritical hit - Total: %s" % state.healAddRaw)
					OPCODE_ELEMENT:
						print(">ELEMENT: %s" % value)
						state.element_set(value, variableTarget)
					OPCODE_NOMISS:
						print(">NOMISS: %s" % value)
						state.nomiss = true if value != 0 else false
					OPCODE_NOCAP:
						print(">NO DAMAGE CAP: %s" % value)
						state.nocap = true if value != 0 else false
					OPCODE_IGNORE_ARMOR:
						print(">IGNORE ARMOR: %s" % value)
						state.ignoreArmor = int(value)
					OPCODE_IGNORE_BARRIERS:
						print(">IGNORE BARRIERS: %s" % value)
						state.ignoreDefs = bool(value)
					OPCODE_RANGE:
						print(">RANGE: %s" % value)
						state.ranged = bool(value)
					OPCODE_ENERGY:
						print(">ENERGY DMG: %s" % value)
						state.energy = bool(value)
					OPCODE_DRAINLIFE:
						print(">DRAIN LIFE: %s" % value)
						state.drainLife = flaggedSet(state.drainLife, value, flags)
						print("Drain Life - Total: %s" % state.drainLife)
					OPCODE_NONLETHAL:
						print(">NONLETHAL: %s" % value)
						state.nonlethal = bool(value)

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
						print(">ELEMENTFIELD CONSUME: %s" % value)
						core.battle.control.state.field.consume(state.element if value == 0 else value)
					OPCODE_FIELD_TAKE:
						print(">ELEMENTFIELD TAKE: %s" % value)
						core.battle.control.state.field.take(value, state.element)
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
					OPCODE_FIELD_SHIFT:
						print(">ELEMENTFIELD SHIFT RIGHT BY: %s" % value)
						core.battle.control.state.field.shift(value)
					OPCODE_FIELD_MULT:
						print(">ELEMENTFIELD SET DAMAGE MULTIPLIER: %s" % value)
						if flags & OPFLAG_VALUE_ABSOLUTE:
							state.fieldEffectMult = core.percent(value)
						else:
							state.fieldEffectMult += core.percent(value)
						print("Current multiplier = %s" % state.fieldEffectMult)

# Stat mods ####################################################################
					OPCODE_ATK_MOD:
						print(">ATK MOD: %s" % value)
						var oldstat = variableTarget.battle.stat.ATK
						variableTarget.battle.stat.ATK = flaggedSet(variableTarget.battle.stat.ATK, value, flags)
						if variableTarget.battle.stat.ATK < oldstat: variableTarget.display.message("ATK DOWN!", messageColors.statdown)
						else                                       : variableTarget.display.message("ATK UP!", messageColors.statup)
						print("%s's current ATK:", variableTarget.battle.stat.ATK)
					OPCODE_DEF_MOD:
						print(">DEF MOD: %s" % value)
						var oldstat = variableTarget.battle.stat.DEF
						variableTarget.battle.stat.DEF = flaggedSet(variableTarget.battle.stat.DEF, value, flags)
						if variableTarget.battle.stat.DEF < oldstat: variableTarget.display.message("DEF DOWN!", messageColors.statdown)
						else                                       : variableTarget.display.message("DEF UP!", messageColors.statup)
						print("%s's current DEF:", variableTarget.battle.stat.DEF)
					OPCODE_ETK_MOD:
						var oldstat = variableTarget.battle.stat.ETK
						print(">ETK MOD: %s" % value)
						variableTarget.battle.stat.ETK = flaggedSet(variableTarget.battle.stat.ETK, value, flags)
						if variableTarget.battle.stat.ETK < oldstat: variableTarget.display.message("ETK DOWN!", messageColors.statdown)
						else                                       : variableTarget.display.message("ETK UP!", messageColors.statup)
						print("%s's current ETK:", variableTarget.battle.stat.ETK)
					OPCODE_EDF_MOD:
						print(">EDF MOD: %s" % value)
						var oldstat = variableTarget.battle.stat.EDF
						variableTarget.battle.stat.EDF = flaggedSet(variableTarget.battle.stat.EDF, value, flags)
						if variableTarget.battle.stat.EDF < oldstat: variableTarget.display.message("EDF DOWN!", messageColors.statdown)
						else                                       : variableTarget.display.message("EDF UP!", messageColors.statup)
						print("%s's current EDF:", variableTarget.battle.stat.EDF)
					OPCODE_AGI_MOD:
						print(">AGI MOD: %s" % value)
						var oldstat = variableTarget.battle.stat.AGI
						variableTarget.battle.stat.AGI = flaggedSet(variableTarget.battle.stat.AGI, value, flags)
						if variableTarget.battle.stat.AGI < oldstat: variableTarget.display.message("AGI DOWN!", messageColors.statdown)
						else                                       : variableTarget.display.message("AGI UP!", messageColors.statup)
						print("%s's current AGI:", variableTarget.battle.stat.AGI)
					OPCODE_LUC_MOD:
						print(">LUC MOD: %s" % value)
						var oldstat = variableTarget.battle.stat.LUC
						variableTarget.battle.stat.LUC = flaggedSet(variableTarget.battle.stat.LUC, value, flags)
						if variableTarget.battle.stat.LUC < oldstat: variableTarget.display.message("LUC DOWN!", messageColors.statdown)
						else                                       : variableTarget.display.message("LUC UP!", messageColors.statup)
						print("%s's current LUC:", variableTarget.battle.stat.LUC)
# Actions ######################################################################
					OPCODE_PRINTMSG:
						print(">PRINT MESSAGE: %s" % value)
						printSkillMsg(S, user, target, value)
					OPCODE_LINKSKILL:
						print(">LINK TO SKILL: %s" % value)
#						if value > 0:
#							var S2 = core.getSkillPtr(S.linkSkill[value - 1])
#							var control2 = controlNode.start()
#							print("Linking to %s" % S2.name)
#							processSubSkill(S2, level, user, target, control2)
#							yield(control2, "skill_end")
#							print("Subskill yielded")
#							yield(controlNode.wait(0.01), "timeout")
					OPCODE_PLAYANIM:
						print(">PLAY ANIMATION: %s" % value)
#						controlNode.startAnim(S, level, str(value) if value in S.animations else 'main', target.sprite.effectHook)
#						yield(controlNode, "fx_finished")
					OPCODE_FX_EFFECTOR_ADD:
						print(">ADD FX EFFECTOR: ", value)
						if value > 0 and S.fx:
							if value - 1 < S.fx.size():
								core.battle.displayManager.addEffector(variableTarget, S.fx[value-1])
					OPCODE_WAIT:
						print(">WAIT: %s" % value)
#						yield(controlNode.wait(float(value) * 0.01), "timeout")
					OPCODE_POST:
						print(">POST ACTION CONTROL: %s" % value)
						match(value):
							0:
								print("Post-action disabled")
								state.post = 0
							1:
								print("Post-action enabled for %s's team" % user.name)
								state.post = 1
							2:
								print("Post-action enabled for enemy team")
								state.post = 2
							_:
								print("Undefined, setting %s's team" % user.name)
					OPCODE_EFFECT_AUTOSET:
							print(">EFFECT AUTOSET: ", value)
							if value > 0:
								var _v:int = value - 1
								var _tid = S.linkSkill[_v]
								var _result = variableTarget.hasSkill(_tid)
								if _result != null:
									variableTarget.addEffect(_result[0], _result[1], user)
								else:
									print("Skill TID %s not found." % String(_tid))

# Player only specials #########################################################
					OPCODE_EXP_BONUS:
						print(">EXP BONUS: %s" % value)
						if variableTarget is core.Enemy:
							variableTarget.XPMultiplier += (float(value) * 0.01)
							variableTarget.display.message("EXP BONUS UP!", messageColors.buff)
						else:
							print("EXP_BONUS not applied, target is not an enemy.")
					OPCODE_REPAIR_PARTIAL:
						print(">REPAIR PARTIAL: %s" % value)
						if variableTarget is core.Player:
							variableTarget.partialRepair(value, false)
						else:
							print("Target is not a player.")
					OPCODE_REPAIR_FULL:
						print(">REPAIR FULL: %s" % value)
						if variableTarget is core.Player:
							variableTarget.fullRepair(false)
						else:
							print("Target is not a player.")
					OPCODE_REPAIR_PARTIAL_ALL:
						print(">REPAIR PARTIAL: %s" % value)
						if variableTarget is core.Player:
							variableTarget.partialRepair(value)
						else:
							print("Target is not a player.")
					OPCODE_REPAIR_FULL_ALL:
						print(">REPAIR FULL: %s" % value)
						if variableTarget is core.Player:
							variableTarget.fullRepair()
						else:
							print("Target is not a player.")
					OPCODE_ITEM_RECHARGE:
						print(">ITEM RECHARGE: %s")
						if variableTarget is core.Player and value != 0:
							for i in value:
								variableTarget.group.inventory.checkRecharges()
# Enemy only specials ##########################################################
					OPCODE_ENEMY_REVIVE:
						print(">ENEMY REVIVE: %s" % value)
						if user is core.Enemy:
							if user.group.canRevive():
								user.group.revive(value)
						else:
							print("User is not an enemy, no effect.")
					OPCODE_ENEMY_ARMED:
						print(">ENEMY ARMED STATUS: %s" % value)
						if variableTarget is core.Enemy:
							match(value):
								1:
									print("Set.")
									variableTarget.armed = true
								2:
									print("Unset.")
									variableTarget.armed = false
								_:
									print("No changes made.")
# Flow control #################################################################
					OPCODE_STOP:
						print(">STOP")
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
					OPCODE_GET_LAST_ELEMENT:
						print(">[TODO]GET LAST ELEMENT")
						state.value = variableTarget.battle.chain
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_HEALTH_PERCENT:
						print(">GET HEALTH PERCENT")
						state.value = variableTarget.getHealthN()
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_MAX_HEALTH:
						print(">GET MAX HEALTH")
						state.value = variableTarget.maxHealth()
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_HEALTH:
						print(">GET CURRENT HEALTH")
						state.value = variableTarget.HP
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_LEVEL:
						print(">GET TARGET LEVEL")
						state.value = variableTarget.level
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_ATK:
						print(">GET TARGET ATK")
						state.value = variableTarget.stats.ATK
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_DEF:
						print(">GET TARGET DEF")
						state.value = variableTarget.stats.DEF
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_ETK:
						print(">GET TARGET ETK")
						state.value = variableTarget.stats.ETK
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_EDF:
						print(">GET TARGET EDF")
						state.value = variableTarget.stats.EDF
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_AGI:
						print(">GET TARGET AGI")
						state.value = variableTarget.stats.AGI
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_LUC:
						print(">GET TARGET LUC")
						state.value = variableTarget.stats.LUC
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_DODGES:
						print(">GET DODGES")
						state.value = variableTarget.battle.turnDodges
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_DEFEATED:
						print(">GET DEFEATED")
						state.value = variableTarget.group.getDefeated()
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_RANGE:
						print(">GET_RANGE")
						state.value = getRange(user, state.originalTarget)
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_OVER:
						print(">GET_OVER")
						state.value = variableTarget.battle.over
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_WEAPON_DUR:
						print(">GET WEAPON DURABILITY")
						print("\tGetting durability for %s" % variableTarget.currentWeapon.lib.name)
						if variableTarget is core.Player:
							state.value = variableTarget.currentWeapon.uses
						elif variableTarget is core.Enemy:
							state.value = 100 if variableTarget.armed else 0
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_WORLD_TIME:
						print(">GET WORLD TIME")
						state.value = core.world.time
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_GET_WORLD_DATE:
						print(">GET WORLD DATE")
						state.value = core.world.day
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
					OPCODE_MATH_SUBI:
						print(">MATH_SUB INVERTED: %s - %s = %s" % [value, state.value, value - state.value])
						state.value = value - state.value
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_MUL:
						print(">MATH_MUL: %s * %s = %s" % [state.value, value, state.value * value])
						state.value *= value
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_DIV:
						print(">MATH_DIV: %s / %s = %s" % [state.value, value, state.value / value])
						state.value /= value
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_DIVI:
						print(">MATH_DIV INVERTED: %s / %s = %s" % [value, state.value, value / state.value if state.value != 0 else 1])
						state.value = value / state.value if state.value != 0 else 1
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_MULF:
						print(">MATH_MULF: %s / %s(%s) = %s" % [state.value, value, float(value) * 0.001, state.value * (float(value) * 0.001)])
						state.value = round(float(state.value) * float(value * 0.001)) as int
						print(">>>>>SVAL = %s" % state.value)
					OPCODE_MATH_DIVF:
						print(">MATH_DIVF: %s / %s(%s) = %s" % [state.value, value, float(value) * 0.001, state.value / (float(value) * 0.001)])
						state.value = round(float(state.value) / float(value * 0.001)) as int
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
						if s_if(value != 0, flags):
							print("%s is not zero" % [int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("%s is zero. Aborting execution." % [int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("%s is zero. Skipping next line." % [int(value)])
								skipLine = true
					OPCODE_IF_OVER:
						print(">IF OVER >= %s" % value)
						if s_if(variableTarget.battle.over >= value):
							print("\tOver(%03d%%) >= %s%%, executing next line." % [variableTarget.battle.over, value])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("\tOver(%03d%%) < %s%%. Aborting execution." % [variableTarget.battle.over, int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("\tOver(%03d%%) < %s%%. Skipping next line." % [variableTarget.battle.over, int(value)])
								skipLine = true
					OPCODE_IF_CHANCE:
						print(">IF_CHANCE: %s" % value)
						if s_if(core.chance(value), flags):
							print("Chance check passed, executing next line.")
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("Chance check failed. Aborting execution.")
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("Chance check failed. Skipping next %s." % ('block' if cond_block else 'line'))
								skipLine = true
					OPCODE_IF_CONDITION:
						print(">IF_CONDITION: %s" % value)
						if s_if(variableTarget.checkInflict(), flags):
							print("Target is afflicted, executing next line.")
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("Target is not afflicted. Aborting execution.")
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("Target is not afflicted. Skipping next %s." % ('block' if cond_block else 'line'))
								skipLine = true
					OPCODE_IF_SVAL_EQUAL:
						print(">IF SVAL EQUALS %s" % value)
						if s_if(int(state.value) == int(value), flags):
							print("%s == %s, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("%s != %s. Aborting execution." % [int(state.value),int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("%s != %s. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_SVAL_LESSTHAN:
						print(">IF SVAL IS LESS THAN %s" % value)
						if s_if(int(state.value) < int(value), flags):
							print("%s < %s, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("%s >= %s. Aborting execution." % [int(state.value),int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("%s >= %s. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_SVAL_LESS_EQUAL_THAN:
						print(">IF SVAL IS LESS OR EQUAL THAN %s" % value)
						if s_if(int(state.value) <= int(value), flags):
							print("%s <= %s, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("%s > %s. Aborting execution." % [int(state.value),int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("%s > %s. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_SVAL_MORETHAN:
						print(">IF SVAL IS MORE THAN %s" % value)
						if s_if(int(state.value) > int(value), flags):
							print("%s > %s, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("%s <= %s. Aborting execution." % [int(state.value),int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("%s <= %s. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_SVAL_MORE_EQUAL_THAN:
						print(">IF SVAL IS MORE OR EQUAL THAN %s" % value)
						if s_if(int(state.value) >= int(value), flags):
							print("%s >= %s, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("%s < %s. Aborting execution." % [int(state.value),int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("%s < %s. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_EF_BONUS_LESS_EQUAL_THAN:
						print(">IF ELEMENT FIELD MORE OR EQUAL THAN %s" % value)
						if s_if(core.battle.control.state.field.bonus[state.element] <= value, flags):
							print("Element bonus for %s: %s <= %s, executing next line" % [state.element, core.battle.control.state.field.bonus[state.element], value])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("Element bonus for %s: %s > %s. Aborting execution." % [state.element, core.battle.control.state.field.bonus[state.element], value])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("Element bonus for %s: %s > %s. Skipping next line." % [state.element, core.battle.control.state.field.bonus[state.element], value])
								skipLine = true
					OPCODE_IF_EF_BONUS_MORE_EQUAL_THAN:
						print(">IF ELEMENT FIELD MORE OR EQUAL THAN %s" % value)
						if s_if(core.battle.control.state.field.bonus[state.element] >= value, flags):
							print("Element bonus for %s: %s >= %s, executing next line" % [state.element, core.battle.control.state.field.bonus[state.element], value])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("Element bonus for %s: %s < %s. Aborting execution." % [state.element, core.battle.control.state.field.bonus[state.element], value])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("Element bonus for %s: %s < %s. Skipping next line." % [state.element, core.battle.control.state.field.bonus[state.element], value])
								skipLine = true

					OPCODE_IF_ACT:
						print(">IF TARGET HAS ACTED %s" % value)
						if s_if(variableTarget.battle.turnActed and value != 0, flags):
							print("%s has acted. Executing next line" % [int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("%s has not acted. Aborting execution." % [int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("%s has not acted. Skipping next line." % [int(value)])
								skipLine = true

					OPCODE_IF_CONNECT:
						print(">IF LAST HIT CONNECTED: %s" % value)
						if s_if(state.lastHit and value != 0, flags):
							print("Last hit connected. Executing next line")
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("Last hit not connected. Aborting execution." % [int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("Last hit not connected. Skipping next line." % [int(value)])
								skipLine = true

					OPCODE_IF_GUARDING:
						print(">IF GUARDING %s" % value)
						if s_if(variableTarget.battle.defending, flags):
							print("%s is guarding. Executing next line" % [int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("%s is not guarding. Aborting execution." % [int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("%s is not guarding. Skipping next line." % [int(value)])
								skipLine = true
					OPCODE_IF_FULL_HEALTH:
						print(">IF FULL HEALTH %s" % value)
						if s_if(variableTarget.isFullHealth(), flags):
							print("%s is at full health. Executing next line." % [int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("%s is not at full health. Aborting execution." % [int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("%s is not at full health. Skipping next line." % [int(value)])
								skipLine = true
					OPCODE_IF_SYNERGY_PARTY:
						print(">IF SYNERGY IN PARTY %02d (using %02d)" % [value, value - 1])
						value = int(value - 1)
						if value >= 0 and value < S.synergy.size():
							var synS = core.lib.skill.getIndex(S.synergy[value])
							var synResult = variableTarget.group.findEffects(synS)
							if s_if(synResult, flags):
								print("Skill %s found in party. Executing next line." % [synS.name])
							else:
								if flags & OPFLAG_QUIT_ON_FALSE:
									print("Skill %s not found in party. Aborting execution." % [synS.name])
									return
								else:
									cond_block = (flags & OPFLAG_BLOCK_START)
									print("Skill %s not found in party. Skipping next %s" % [synS.name, 'block' if cond_block else 'line'])
									skipLine = true
						else:
							print("%d not found" % value)
					OPCODE_IF_SYNERGY_TARGET:
						print(">IF SYNERGY IN TARGET %s" % value)
						value = int(value - 1)
						if value >= 0 and value < S.synergy.size():
							var synS = core.lib.skill.getIndex(S.synergy[value])
							var synResult = variableTarget.findEffects(synS)
							if s_if(synResult, flags):
								print("Skill %s found on %s. Executing next line." % [synS.name, variableTarget.name])
							else:
								if flags & OPFLAG_QUIT_ON_FALSE:
									print("Skill %s not found on %s. Aborting execution." % [synS.name, variableTarget.name])
									return
								else:
									cond_block = (flags & OPFLAG_BLOCK_START)
									print("Skill %s not found in %s. Skipping next %s" % [synS.name, variableTarget.name, 'block' if cond_block else 'line'])
									skipLine = true
					OPCODE_IF_RACE_ASPECT:
						print(">IF RACE ASPECT IN TARGET %s" % value)
						var temp2 = false
						if variableTarget is core.Player:
							temp2 = variableTarget.racelib.aspect & int(value)
						else:
							temp2 = variableTarget.lib.aspect & int(value)
						if s_if(temp2,flags):
							print("Race aspect %d found on %s. Executing next line." % [value, variableTarget.name])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("Race aspect %d not found on %s. Aborting execution." % [value, variableTarget.name])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("Race aspect %d not found on %s. Skipping next %s" % [value, variableTarget.name, 'block' if cond_block else 'line'])
								skipLine = true
					OPCODE_IF_DAY:
						print(">IF DAY %s" % value)
						if s_if(core.world.isNight() == false, flags):
							print("It's daytime, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("It's not daytime. Aborting execution." % [int(state.value),int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("It's not daytime. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					OPCODE_IF_NIGHT:
						print(">IF NIGHT %s" % value)
						if s_if(core.world.isNight() == true, flags):
							print("It's night, executing next line" % [int(state.value),int(value)])
						else:
							if flags & OPFLAG_QUIT_ON_FALSE:
								print("It's not night. Aborting execution." % [int(state.value),int(value)])
								return
							else:
								cond_block = (flags & OPFLAG_BLOCK_START)
								print("It's not night. Skipping next line." % [int(state.value),int(value)])
								skipLine = true
					_:
						print(">[!!]UNKNOWN OPCODE: %d VALUE: %s" % [line[0], value])
			else:
				print("[%s]%02d>SKIP %s" % [S.name, j, 'LINE' if not cond_block else 'BLOCK'])
				if cond_block:
					#We are inside a code block.
					if flags & OPFLAG_BLOCK_END or line[0] == OPCODE_STOP: #TODO: Revise this. I sense trouble.
						#This line ends the block.
						cond_block = false
						skipLine = false
						print("%02d>END BLOCK" % j)
					else:
						skipLine = true
				else:
					skipLine = false




func printCode(S, level, code = CODE_MN) -> String:
	var body = ""
	match(code):
		CODE_MN:
			if S.codeMN != null:
				for i in range(S.codeMN.size()):
					var translated = opcodeInfo[S.codeMN[i][0]].name if S.codeMN[i][0] in opcodeInfo else str(S.codeMN[i][0])
					body += "%02d:%s:%03d:%d\n" % [i,translated, S.codeMN[i][level], S.codeMN[i][11]]
	return body


func factoryLine(opcode:int, val:int, flags:int = 0, tag:String = '') -> Array:
	var result:Array = LINE_TEMPLATE.duplicate()
	result[0] = int(opcode)
	for i in range(1, 11): result[i] = int(val)
	result[11] = int(flags)
	result[13] = tag #DGem tag
	return result


func factory(Sp:Dictionary, mods:Array, level:int) -> void:
	var SRANGE:Array     = range(MAX_LEVEL) #Precompute iterator
	var LVAL_RANGE:Array = range(1, 11)     #Iterator for skill LVALs
	Sp.name += "+" #Add a plus to indicate enhancement.
	for mod in mods:
		print("[SKILL][FACTORY] %s on %s" % [mod[0],Sp.name])
		var op:int  = mod[0]
		var val:int = mod[1 + level]
		match(op):
#Data changes, simple.
			DGEM_NONE:
				print("[SKILL][factory] OP:0> do nothing")
			DGEM_EF_MUL:
				print("[SKILL][factory] EF multiplier +%s" % val)
				for i in SRANGE: Sp.fieldEffectMult[i] += val
			DGEM_EF_ADD:
				print("[SKILL][factory] EF effect up +%s" % val)
				for i in SRANGE: Sp.fieldEffectAdd[i] += val
			DGEM_ACC:
				print("[SKILL][factory] Accuracy mod: %s%%" % val)
				for i in SRANGE: Sp.accMod[i] = core.percentMod(Sp.accMod[i], val)
			DGEM_SPD:
				print("[SKILL][factory] Speed mod: %s%%" % val)
				for i in SRANGE: Sp.spdMod[i] = core.percentMod(Sp.spdMod[i], val)
			DGEM_INITAD:
				print("[SKILL][factory] InitAD mod: %s%%" % val)
				for i in SRANGE: Sp.initAD[i] = core.percentMod(Sp.initAD[i], val)
			DGEM_AD:
				print("[SKILL][factory] AD mod: %s%%" % val)
				for i in SRANGE: Sp.AD[i] = core.percentMod(Sp.AD[i], val)
			DGEM_CHARGE_FX:
				print("[SKILL][factory] Charge FX mod: %s" % val)
				for i in SRANGE: Sp.chargeAnim[i] = val
#Data changes, more complicated.
			DGEM_RANGE:
				print("[SKILL][factory] Long range mod: %s" % val)
				if val != 0:
					for i in SRANGE: Sp.ranged[i] = val
			DGEM_TARGET:
				print("[SKILL][factory] Target mod: %s%%" % val)
				if val != 0:
					for i in SRANGE:
						match val:
							1: Sp.target[i] = TARGET_LINE
							2: Sp.target[i] = TARGET_ROW
							3: Sp.target[i] = TARGET_ALL
			DGEM_ELEMENT:
				print("[SKILL][factory] Element mod: %s" % val)
				for i in SRANGE:
					Sp.element[i]    = val
					Sp.animFlags[i] |= ANIMFLAGS_COLOR_FROM_ELEMENT
			DGEM_CHAINMOD:
				print("[SKILL][factory] Chain mod: %s" % val)
				if val != 0:
					match val:
						1:
							if Sp.chain == CHAIN_NONE     : Sp.chain = CHAIN_STARTER
							if Sp.chain == CHAIN_STARTER  : Sp.chain = CHAIN_STARTER_AND_FOLLOW
							if Sp.chain == CHAIN_FOLLOW   : Sp.chain = CHAIN_STARTER_AND_FOLLOW
						2:
							if Sp.chain != CHAIN_FINISHER : Sp.chain = CHAIN_STARTER_AND_FOLLOW
#Code changes.
			DGEM_EX_HIT:
				print("[SKILL][factory] Extra hit: %s" % val)
				var modified:bool = false
				match val:
					1:
						Sp.codeMN.push_back(factoryLine(OPCODE_ATTACK_COMBO, val))
						modified = true
					2:
						Sp.codeMN.push_back(factoryLine(OPCODE_ATTACK, val))
						modified = true
				if modified: print("[SKILL][factory] Appending %s to skill code" % ("OPCODE_ATTACK" if val == 2 else "OPCODE_ATTACK_COMBO"))
			DGEM_POWER:
				print("[SKILL][factory] Power mod: %s%%" % val)
				for i in Sp.codeMN:
					if i[0] in opCodesPowerable:
						print("[SKILL][factory][DGEM_POWER] Found code %s in codeMN." % [i[0]])
						LVALModPercent(i, val)
			DGEM_IGNOREBARRIER:
				print("[SKILL][factory] Ignore barrier: %s" % val)
				var powered:int = 0
				for i in Sp.codeMN:
					if i[0] == OPCODE_IGNORE_BARRIERS:
						LVALModAdd(i, val)
						powered = true
				if not powered:
					print("[SKILL][factory][DGEM_IGNOREBARRIER] Prepending OPCODE_IGNORE_BARRIERS to skill code.")
					Sp.codeMN.push_front(factoryLine(OPCODE_IGNORE_BARRIERS, val))
			DGEM_IGNOREARMOR:
				print("[SKILL][factory] Ignore armor: %s" % val)
				var powered:int = 0
				for i in Sp.codeMN:
					if i[0] == OPCODE_IGNORE_ARMOR:
						LVALModAdd(i, val)
						powered = true
				if not powered:
					print("[SKILL][factory][DGEM_IGNOREARMOR] Prepending OPCODE_IGNORE_ARMOR to skill code.")
					Sp.codeMN.push_front(factoryLine(OPCODE_IGNORE_ARMOR, val))
			DGEM_LIFEDRAIN:
				print("[SKILL][factory] Life Drain: %s%%" % val)
				var powered:int = 0
				for i in Sp.codeMN:
					if i[0] == OPCODE_DRAINLIFE:
						LVALModAdd(i, val)
						powered = true
				if not powered:
					print("[SKILL][factory][DGEM_LIFEDRAIN] Prepending OPCODE_DRAINLIFE to skill code.")
					Sp.codeMN.push_front(factoryLine(OPCODE_DRAINLIFE, val))
			DGEM_COND_BONUS:
				print("[SKILL][factory] Affliction damage bonus: %s" % val)
				var powered:int = 0
				for i in Sp.codeMN:
					if i[0] == OPCODE_DAMAGEBONUS_ON_COND:
						LVALModAdd(i, val)
						powered = true
				if not powered:
					print("[SKILL][factory][DGEM_COND_BONUS] Prepending OPCODE_DAMAGEBONUS_ON_COND to skill code.")
					Sp.codeMN.push_front(factoryLine(OPCODE_DAMAGEBONUS_ON_COND, val))
			DGEM_EXP_BONUS:
				print("[SKILL][factory] EXP Bonus: %s%%" % val)
				var powered:int = 0
				for i in Sp.codeMN:
					if i[0] == OPCODE_EXP_BONUS:
						LVALModAdd(i, val)
						powered = true
				if not powered:
					print("[SKILL][factory][DGEM_EXP_BONUS] Prepending OPCODE_EXP_BONUS to skill code.")
					Sp.codeMN.push_front(factoryLine(OPCODE_EXP_BONUS, val))
			_:
				print("[SKILL][factory][!!] Unknown mod. Value: ", val)

func findOpCode(code:Array, opcode:int) -> int:
	var result:int = -1
	for i in range(code.size()):
		if code[i][0] == opcode: result = i
	return result

func LVALModPercent(line:Array, mod:int) -> void: #Modifies all LVALs in a code line by a percentage.
	for i in range(1, 11): line[i] = core.percentMod(line[i], mod)

func LVALModAdd(line:Array, mod:int) -> void: #Modifies all LVALs in a code line by addition.
	for i in range(1, 11): line[i] = line[i] + mod

func factory2(Sp, mods, level): #Sp is a pointer to skill copy
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
						if Sp.codeMN[j][0] == OPCODE_IF_CONDITION:
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
						Sp.codeMN.push_front(factoryLine(OPCODE_IF_CONDITION, 0, 0))
						print(Sp.codeMN)
				"nonlethal":
					print("[SKILLFACTORY] Nonlethal %s" % mods.nonlethal[level])
					var line = -1
					for j in range(Sp.codeMN.size()):
						if Sp.codeMN[j][0] == OPCODE_NONLETHAL:
							line = j
					if line > -1: #Found an existing OPCODE_IGNORE_DEFS, modify it.
						print("[SKILLFACTORY] Skill already has an OPCODE_NONLETHAL")
						for ii in range(1, 11):
							Sp.codeMN[line][ii] += mods.nonlethal[level]
					else:
						print("[SKILLFACTORY] Prepending OPCODE_IGNORE_DEFS opcode to skill.")
						Sp.codeMN.push_front(factoryLine(OPCODE_NONLETHAL, mods.nonlethal[level]))
						print(Sp.codeMN)
				"extrahit":
					print("[SKILLFACTORY] extrahit: %s" % mods.extrahit[level])
					if mods.extrahit[level] > 0:
						print("[SKILLFACTORY] Appending OPCODE_ATTACK opcode to skill %s." % Sp.name)
						Sp.codeMN.push_back(factoryLine(OPCODE_ATTACK, mods.extrahit[level]))
				"target":
					print("[SKILLFACTORY] spread %s" % mods.target[level])
					for j in range(MAX_LEVEL):
						match(mods.target[level]):
							#TODO: This works under the assumption that all dgems are single target.
							'line':
								for ii in range(10):
									if Sp.target[ii] == TARGET_SINGLE: Sp.target[ii] = TARGET_LINE
							'row':
								for ii in range(10):
									if Sp.target[ii] == TARGET_SINGLE: Sp.target[ii] = TARGET_ROW
							'all':
								for ii in range(10):
									if Sp.target[ii] == TARGET_SINGLE: Sp.target[ii] = TARGET_ALL
				"ignoreBarriers":
					print("[SKILLFACTORY] Ignore barriers %s" % mods.ignoreBarriers[level])
					var line = -1
					for j in range(Sp.codeMN.size()):
						if Sp.codeMN[j][0] == OPCODE_IGNORE_BARRIERS:
							line = j
					if line > -1: #Found an existing OPCODE_IGNORE_BARRIERS, modify it.
						print("[SKILLFACTORY] Skill already has an OPCODE_IGNORE_BARRIERS")
						for ii in range(1, 11):
							Sp.codeMN[line][ii] += mods.ignoreBarriers[level]
					else:
						print("[SKILLFACTORY] Prepending OPCODE_IGNORE_BARRIERS opcode to skill.")
						Sp.codeMN.push_front(factoryLine(OPCODE_IGNORE_BARRIERS, mods.ignoreBarriers[level], 0))
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
				"chase":
					print("[SKILLFACTORY] [!TODO!] Prepending OPCODE_CHASE stuff to %d" % [mods.chase[level]])
				"element":
					for j in range(MAX_LEVEL):
						Sp.element[j] = int( mods.element[level] )
						Sp.animFlags[j] |= ANIMFLAGS_COLOR_FROM_ELEMENT
					print("[SKILLFACTORY] Element changed to %s" % [mods.element[level]])
