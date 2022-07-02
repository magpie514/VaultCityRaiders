extends "res://classes/library/lib_base.gd"
var skill = core.skill
const LIBEXT_AIPATTERN   = "loaderAIPattern"
const LIBEXT_SKILL_SETUP = "loaderSkillSetup"
const LIBEXT_ENEMY_SKILL = "loaderEnemySkills"
const LIBEXT_BOSSDESC    = "loaderBossDescription"
const LIBEXT_BOSS_PHASE  = "loaderBossPhase"

const SKILLSETUP_ERROR   = [ [ [0,1], [1,1], [2,1], [3,1] ] ]
enum {
	AIPATTERN_SIMPLE,
	AIPATTERN_PICK_RANDOMLY,
	AIPATTERN_PICK_2_IF_WEAK,
	AIPATTERN_PICK_2_IF_RANK,
	AIPATTERN_PICK_2_IF_ALLY_USED_1_ALREADY,
	AIPATTERN_PICK_2_IF_CAN_REVIVE,
	AIPATTERN_PICK_2_IF_NIGHT,
	AIPATTERN_PICK_2_IF_DAY,
}

enum {
	AIPATTERN_LOOP,
	AIPATTERN_LOOP_SKIP_FIRST,
}

enum {
	AITARGET_SELF,
	AITARGET_RANDOM,
	AITARGET_WEAKEST,
	AITARGET_ALLY_WEAKEST,
	AITARGET_SUMMONER
}
var example = {
	"story" : {
		"boss_solarica_prologue" : {
			name = "King Solarica",
			description = {
				subtitle = "King of Nightmares",
				menace = "S",
				victims = 8164824596267147357,
			},
			race = core.RACE_MACHINE, aspect = core.RACEF_SPI|core.RACEF_MEC,
			phases = 3,
			phaseDef = [
				{
					name = "Wake of the Destroyer",
					description = "Endure", #Use no punctuation.
					statSpread = [
						#HP    ATK  DEF  ETK  EDF  AGI  LUC
						[0045, 010, 010, 010, 010, 010, 010],
						[0500, 100, 100, 100, 100, 100, 100]
					],
					#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
					conditionDefs = [ 02, 05, 03, 03, 09, 08, 02, 09, 99, 08],
					OFF = [ 100,100,100,  150,100,100,  100,100,  100,100 ],
					RES = [ 075,075,125,  005,125,050,  100,100,  100,110 ],
					skills     = [ "debug/alertstc", "debug/defdown", "debug/shoot", "core/defend" ],
					skillSetup = [ [ [0,1], [1,1], [2,1], [3,1] ] ],
				},{
					name = "Bloody Star",
					description = "Survive",
					statSpread = [
						#HP    ATK  DEF  ETK  EDF  AGI  LUC
						[0045, 010, 010, 010, 010, 010, 010],
						[0500, 100, 100, 100, 100, 100, 100]
					],
					#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
					conditionDefs = [ 02, 05, 03, 03, 09, 08, 02, 09, 99, 08],
					OFF = [ 100,100,100,  150,100,100,  100,100,  100,100 ],
					RES = [ 075,075,125,  005,125,050,  100,100,  100,110 ],
					skills     = [ "debug/alertstc", "debug/defdown", "debug/shoot", "core/defend" ],
					skillSetup = [ [ [0,1], [1,1], [2,1], [3,1] ] ],
				},{
					name = "Apocalypse",
					description = "Pray",
					statSpread = [
						#HP    ATK  DEF  ETK  EDF  AGI  LUC
						[0045, 010, 010, 010, 010, 010, 010],
						[0500, 100, 100, 100, 100, 100, 100]
					],
					#                PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
					conditionDefs = [ 02, 05, 03, 03, 09, 08, 02, 09, 99, 08],
					OFF = [ 100,100,100,  150,100,100,  100,100,  100,100 ],
					RES = [ 075,075,125,  005,125,050,  100,100,  100,110 ],
					skills     = [ "debug/alertstc", "debug/defdown", "debug/shoot", "core/defend" ],
					skillSetup = [ [ [0,1], [1,1], [2,1], [3,1] ] ],
				}
			]
		}
	}
}

func initTemplate() -> Dictionary:
	return {
		"name"         : { loader = LIBSTD_STRING },                      #Enemy name
		"spriteFile"   : { loader = LIBSTD_STRING, default = "res://resources/images/Char/debug.json"},
		"energyColor"  : { loader = LIBSTD_STRING, default = "#AAFFFF" }, #Energy effect color.
		"summons"      : { loader = LIBSTD_SUMMONS },                     #Summoner (or reinforcement) data.
		"description"  : { loader = LIBEXT_BOSSDESC },                    #Enemy description.
		"statSpread"   : { loader = LIBSTD_STATSPREAD },                  #Stat spread.
		# Condition defenses                                         PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
		"conditionDefs": { loader = LIBSTD_CONDITIONDEFS, default = [ 03, 04, 04, 04, 03, 03, 03, 03, 03, 03] },
		"armed"        : { loader = LIBSTD_BOOL, default = false },       #If enemy is supposed to be wielding a weapon or not.
		"OFF"          : { loader = LIBSTD_ELEMENTDATA, default = [ 100,100,100, 100,100,100, 100,100, 100,100 ] }, #Elemental offense.
		"RES"          : { loader = LIBSTD_ELEMENTDATA, default = [ 100,100,100, 100,100,100, 100,100, 100,100 ] }, #Elemental defense.
		"race"         : { loader = LIBSTD_INT },                         #Race type (for "slayer/brand" effects)
		"aspect"       : { loader = LIBSTD_INT },                         #Race aspects (BIO/MEC/SPI), affects vulnerability to certain effects.
		"defeatMsg"    : { loader = LIBSTD_STRING, default = "%s was defeated!" },	#Message to display when defeated. "%s倒した！"
		"ai"           : { loader = LIBSTD_INT },                         #AI mode
		"aiPattern"    : { loader = LIBEXT_AIPATTERN },	                  #AI pattern
		"skills"       : { loader = LIBEXT_ENEMY_SKILL },                 #Enemy skill list.
		"skillSetup"   : { loader = LIBEXT_SKILL_SETUP, default = [ [ [0,1], [1,1], [2,1], [3,1] ] ] },  #Skill setup [skill array index, level]
	}