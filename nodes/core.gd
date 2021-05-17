extends Node
# Important shared classes ####################################################
const Enemy     = preload("res://classes/char/char_enemy.gd")
const Player    = preload("res://classes/char/char_player.gd")
const Inventory = preload("res://classes/inventory/item.gd")

# Misc utility constants ######################################################
#Encoding/Decoding tables for "base52" encoding. It's not a standard base.
const encode_base52 = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", #00-12
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", #13-24
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", #25-36
	"n", "o", "p", "q", "r", "s", "t" ,"u", "v", "w", "x", "y", "z", #37-48
]
const decode_base52 = {
	'A':00,'B':01,'C':02,'D':03,'E':04,'F':05,'G':06,'H':07,'I':08,'J':09,'K':10,'L':11,'M':12,
	'N':13,'O':14,'P':15,'Q':16,'R':17,'S':18,'T':19,'U':20,'V':21,'W':22,'X':23,'Y':24,'Z':25,
	'a':26,'b':27,'c':28,'d':29,'e':30,'f':31,'g':32,'h':33,'i':34,'j':35,'k':36,'l':37,'m':38,
	'n':39,'o':40,'p':41,'q':42,'r':43,'s':44,'t':45,'u':46,'v':47,'w':48,'x':49,'y':50,'z':51,
}

var scene = null #Current scene
var battle:Dictionary = { #Useful pointers for battle stuff.
	state          = null,
	enemy          = null,
	bgm            = null,
	control        = null,
	displayManager = null,
	skillControl   = null,
	background     = null,
	bg_fx          = null,
}
var world:WorldClass = WorldClass.new()
# Internal Data libraries #####################################################
var lib = {
	skill  = null, #Skill library. Important and must be first.
	race   = null, #Player race library.
	aclass = null, #Player class library.
	weapon = null, #Weapon library.
	item   = null, #Item library.
	dgem   = null, #Dragon Gem library.
	armor  = null, #Armor/Vehicle library.
	enemy  = null, #Enemy library.
	mform  = null, #Enemy formation library.
}
var stats:StatClass = StatClass.new()
var tid:_tid  = _tid.new()
var skill     = null #Pointer to skill class. Important.
var guild     = null #Pointer to player guild.
var init:bool = false
# Important shared constants ##################################################

enum { #General race types
	#TODO: Make use of these for weapon "Brand" stuff, where hitting a target of the
	#specified race gives a damage bonus.
	#TODO: Should be a good time to start implementing "brands".
	RACE_NONE,       #Shouldn't happen.
	RACE_HUMAN,      #A regular human. Or the breed that produces adventurers.
	RACE_CONSTRUCT,  #An artificial, non-strictly-mechanical lifeform.
	RACE_MACHINE,    #An artificial, strictly mechanical lifeform.
	RACE_SPIRIT,     #A spiritual being such as a ghost, youkai or similar.
	RACE_ELEMENTAL,  #A specialized form of spirit born from the forces of the universe.
	RACE_GIANT,      #A creature of extremely large size. Used as a modifier.
	RACE_ANGEL,      #A divine being or beast, usually servants to the ghosts.
	RACE_DEMON,      #A usually malevolent lifeform created by evil desires.
	RACE_DRAGON,     #A powerful being attuned to the primal chaos, usually winged reptiles.
	RACE_FAIRY,      #A powerful being attuned to natural forces.
	RACE_UNDEAD,     #A deceased lifeform kept functioning by external energies.
	RACE_BEAST,      #A primal being of varying characteristics. Usually non-sapient.
	RACE_GOD,        #A powerful being born from the power of faith.
	RACE_ELDRITCH,   #An alien lifeform directly born from primal chaos. Wildcards.
	RACE_ORIGINATOR, #Only for Tiamat and Cromwell. The most powerful beings with the power to create lifeforms.
}

#TODO: Write some sort of function to check if all lists like this have a proper match.
const racetypes = {
	RACE_NONE       : { name = "Unknown", desc = "???" },
	RACE_HUMAN      : { name = "Human", desc = "" },
	RACE_CONSTRUCT  : { name = "Construct", desc = "" },
	RACE_MACHINE    : { name = "Machine", desc = "" },
	RACE_SPIRIT     : { name = "Spirit", desc = "" },
	RACE_ELEMENTAL  : { name = "Elemental", desc = "" },
	RACE_GIANT      : { name = "Giant", desc = "" },
	RACE_ANGEL      : { name = "Angel", desc = "" },
	RACE_DEMON      : { name = "Demon", desc = "" },
	RACE_DRAGON     : { name = "Dragon", desc = "" },
	RACE_FAIRY      : { name = "Fairy", desc = "" },
	RACE_UNDEAD     : { name = "Undead", desc = "" },
	RACE_BEAST      : { name = "Beast", desc = "" },
	RACE_GOD        : { name = "God", desc = "" },
	RACE_ELDRITCH   : { name = "Eldritch", desc = "" },
	RACE_ORIGINATOR : { name = "Originator", desc = "" },
}

enum { #Race Aspect
	RACEF_NON = 0b000,
	RACEF_MEC = 0b001, #Race has mechanical parts
	RACEF_BIO = 0b010, #Race has organic parts
	RACEF_SPI = 0b100, #Race has a soul
}

#TODO: This might be more convenient elsewhere.
enum { #Weapon classes
	WPCLASS_NONE = 0,     # None: Nothing whatsoever.
	WPCLASS_FIST,         # Fist: Fists, gloves and arms. Martial skills and all that stuff.
	WPCLASS_SHORTSWORD,   # Short Swords: Knives, daggers, machetes, any sort of short blade.
	WPCLASS_LONGSWORD,    # Long Swords: Bastard swords, nihon-tou, zweihanders, ideal for your spiky haired characters.
	WPCLASS_POLEARM,      # Polearms: Spears, lances, glaives, naginatas, the works.
	WPCLASS_HAMMER,       # Hammers: Bats, maces, stun batons, staves, general blunt things.
	WPCLASS_AXE,          # Axes: Hammers with blades. Hatchets, war axes, not a broad category but effective.
	WPCLASS_HANDGUN,      # Handguns: Pistols, stun guns, revolvers, SMGs. Portable and lightweight firearms.
	WPCLASS_FIREARM,      # Firearms: Shotguns, rifles, grenade launchers. Bigger caliber guns, like law enforcement tier.
	WPCLASS_ARTILLERY,    # Artillery: Cannons, missile launchers, howitzers. Powerful weaponry, military tier and above.
	WPCLASS_SHIELD,       # Shields: Portable defensive devices.
	WPCLASS_ONBOARD,      # Onboard: Special weapons available only to vehicles and robot equipment.
}

const weapontypes = {
	WPCLASS_NONE       : { name = "???", icon = "" },
	WPCLASS_FIST       : { name = "Fists", icon = "" },
	WPCLASS_SHORTSWORD : { name = "Short Sword", icon = "" },
	WPCLASS_LONGSWORD  : { name = "Long Sword", icon = "" },
	WPCLASS_POLEARM    : { name = "Polearm", icon = "" },
	WPCLASS_HAMMER     : { name = "Hammer", icon = "" },
	WPCLASS_AXE        : { name = "Axe", icon = "" },
	WPCLASS_HANDGUN    : { name = "Handgun", icon = "" },
	WPCLASS_FIREARM    : { name = "Firearm", icon = "" },
	WPCLASS_ARTILLERY  : { name = "Artillery", icon = "" },
	WPCLASS_SHIELD     : { name = "Shield", icon = "" },
	WPCLASS_ONBOARD    : { name = "Onboard", icon = "" },
}
# Condition defenses, default.  PAR CRY SEA DWN BLI STU CUR PAN ARM DMG
const CONDITIONDEFS_DEFAULT = [ 02, 04, 04, 03, 02, 02, 02, 03, 02, 02]

class WorldClass:
	#|        Night                          |      Morning |        Day                       |     Evening  | Night        |
	#| 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 |
	# 000  030  060  090  120  150  180  210  240  270  300  330  360  390  420  450  480  510  540  570  600  630  660  690
	var time:int = 0        #30 steps or turns => one hour.
	var day:int = 0         #30 days => one month.
	var IDcounter:int = 0   #Internal counter for enemy/monster IDs.
	func periodOfDay() -> int:
		if   (time > 630) or (time > 0 and time < 240): return 0 #Night
		elif time > 240 and time < 330:                 return 1 #Morning
		elif time > 330 and time < 540:                 return 2 #Day
		elif time > 540 and time < 630:                 return 3 #Evening
		else:                                           return 0 #????

	func isNight() -> bool:
		return true if periodOfDay() == 0 else false

	func init(data) -> void:
		time = int(data.time)
		day = int(data.day)
		IDcounter = int(data.IDcounter)

	func save()	-> Dictionary: #Get data structured for savefile.
		var result : Dictionary = {
			time = time,
			day = day,
			IDcounter = IDcounter,
		}
		return result

	func passTime(amount:int = 1): #Pass one or more "time units".
		var oldtime = time
		var oldhour = int(float(time) / 30)
		time = time + amount
		print("[WORLD][passTime] Passing %d time units (%d)." % [amount, time])
		var newhour = int(float(time) / 30)
		print("[WORLD][passTime] %d hours pass." % (newhour-oldhour))
		for i in range(newhour - oldhour):
			core.guild.on_hour_pass()
		while time >= 720:
			day += 1
			print("[WORLD][passTime] Day passed. Current day is %d" % day)
			time -= 720

class CounterClass: #Simple incrementing counter.
	var count:int = 0
	var limit:int = 65535 #Default to something that fits in 16 bits.

	func _init(val:int = 0) -> void:
		count = val

	func next() -> int:
		count += 1
		return count

	func current() -> int:
		return count


class _charPanel:
	var UIthemes = {
	# ID         STANDARD             HIGHLIGHT
	#            MAIN       BORDER    MAIN      BORDER
		"normal" : ["000273", "A0DAE0", "3B67A7", "B0fae0"],
		"select" : ["5A8457", "FFFFFF", "8A6427", "FFFFFF"],
		"damage" : ["771A1A", "FFB666", "882A2A", "FFC676"],
		"status" : ["773477", "75EEFF", "9764A7", "95FEFF"],
		"defeat" : ["888888", "AAAAAA", "A8A8A8", "CFCFCF"],
		"disable": ["88888888", "88AAAAAA", "88888888", "88AAAAAA"],
	}
	var style     = null 				#StyleBox for the panel.
	var styleName = ""			#Godot's style path
	var node      = null					#Node to control
	var theme     = "normal"		#Theme key
	func _init(_node, stylepath, stylename):
		node = _node
		style = load(stylepath).duplicate()
		styleName = stylename

	func setColors(c1, c2):
		style.bg_color = c1
		style.border_color = c2
		node.set(styleName, style)

	func setTheme(th):
		theme = th
		var T = UIthemes[theme]
		setColors(T[0], T[1])

	func fromStatus(st):
		match st:
			core.skill.CONDITION_GREEN:
				setTheme("normal")
			core.skill.CONDITION_DOWN:
				setTheme("damage")
			_:
				setTheme("status")

	func setTemp(th):
		var T = UIthemes[th]
		setColors(T[0], T[1])

	func highlight(b):
		var T = UIthemes[theme]
		setColors(T[2] if b else T[0], T[3] if b else T[1])

	func highlight2(b): #Gross hack for spread and line selects
		var T
		if b: #Spread damage highlight
			T = UIthemes["select"]
			setColors(T[2], T[3])
		else: #Back to normal theme
			T = UIthemes[theme]
			setColors(T[0], T[1])

class _tid: #TID (Thing ID) helper class.
	#A TID is a way to organize data in a nested dictionary. "Libraries" use this format to store data as section/item.
	func create(a, b) -> PoolStringArray: #Create a new TID array from two strings.
		return PoolStringArray([str(a), str(b)])

	func validateArray(tid) -> bool: #Validate a TID array.
		#Validation rules.
		if tid.size() != 2: return false #TID isn't the right size.
		if tid[0] == null:  return false #Value 1 is not valid.
		if tid[1] == null:  return false #Value 2 is not valid.
		#All basic fail checks pass. It's valid.
		return true

	func validateString(tid:String) -> bool: #Validate a TID string.
		#Validation rules.
		if tid.split('/', true, 2).size() < 2: return false #Must use / as a separator.
		#All basic fail checks pass. It's valid.
		return true

	func fromArray(a) -> PoolStringArray: #Create a TID using an array in the format ["section", "item"]
		if validateArray(a):
			return create(a[0], a[1])
		else:
			return create("debug", "debug")

	func fromString(st) -> PoolStringArray: #Create a TID using a string in the format "section/item"
		if validateString(st):
			var parts = st.split('/', false, 2)
			return create(parts[0], parts[1])
		else:
			return create("debug", "debug")

	func from(a) -> PoolStringArray: #Create a TID from an unknown definition.
		#print("[TID][from] ", a, " ", typeof(a))
		match(typeof(a)):
			TYPE_STRING       : return fromString(a)
			TYPE_ARRAY        : return fromArray(a)
			TYPE_STRING_ARRAY : return fromArray(a)
			_                 : return create('debug', 'debug')

	func copy(tid) -> PoolStringArray: #Makes a copy of a TID.
		return create(tid[0], tid[1])

	func string(tid) -> String: #Prints a TID as a string in the format "section/item"
		var result:String = "%s/%s" % [tid[0], tid[1]]
		return result

	func compare(tid1, tid2) -> bool: #Compare two TIDs.
		return true if (tid1[0] == tid2[0] and tid1[1] == tid2[1]) else false

class StatClass:
	const STAT_CAP = 255
	const MAX_DMG = 32000
	const STATS = [ 'MHP', 'ATK', 'DEF', 'ETK', 'EDF', 'AGI', 'LUC' ]
	const EXTRA_STATS = [ 'MEP', 'OVR', 'CRI' ]
	enum STAT { MHP, ATK, DEF, ETK, EDF, AGI, LUC }
	enum ELEMENTS {
		DMG_UNTYPED  = 0,	#Cannot be resisted
		DMG_CUT      , #Slash or wind attacks
		DMG_PIERCE   , #Perforating or earth attacks.
		DMG_STRIKE   , #Strike/explosive or water attacks.
		DMG_FIRE     , #Fire attacks
		DMG_ICE      , #Ice attacks
		DMG_ELEC     , #Electric attacks
		DMG_UNKNOWN  , #Time/Light/Spirit attacks (Use sparingly)
		DMG_ULTIMATE , #Gravity/Dark attacks (Use sparingly)
		DMG_KINETIC  , #Supertype for all physical damage
		DMG_ENERGY   , #Supertype for all energy damage
	}
	enum { #Condition defense table
		COND_PARALYSIS    = 00,
		COND_CRYO         = 01,
		COND_SEAL         = 02,
		COND_DEFEAT       = 03,
		COND_BLIND        = 04,
		COND_STUN         = 05,
		COND_CURSE        = 06,
		COND_PANIC        = 07,
		COND_DISABLE_ARMS = 08,
		COND_DAMAGE       = 09
	}
	var CONDITION_DATA = {
		COND_PARALYSIS    : { name = "Paralisis"    , desc = "paralized"    , color = "FFFF00", short = 'PAR'},
		COND_CRYO         : { name = "Cryostasis"   , desc = "frozen"       , color = "3388FF", short = 'CRY'},
		COND_SEAL         : { name = "Seal"         , desc = "sealed"       , color = "118822", short = 'SEA'},
		COND_DEFEAT       : { name = "Incapacitated", desc = "incapacitated", color = "FF0000", short = 'DWN'},
		COND_STUN         : { name = "Stun"         , desc = "stunned"      , color = "BBBB22", short = 'STU'},
		COND_BLIND        : { name = "Blind"        , desc = "blinded"      , color = "333333", short = 'BLI'},
		COND_CURSE        : { name = "Curse"        , desc = "cursed"       , color = "660000", short = 'CUR'},
		COND_PANIC        : { name = "Panic"        , desc = "paniced"      , color = "448800", short = 'PAN'},
		COND_DISABLE_ARMS : { name = "Stasis"       , desc = "warped"       , color = "440088", short = 'ARM'},
		COND_DAMAGE       : { name = "Damage"       , desc = "hurt"         , color = "FF00FF", short = 'DMG'},
	}

	const CONDITION_CONV = {
		'CON_PAR': COND_PARALYSIS   ,
		'CON_CRY': COND_CRYO        ,
		'CON_SEA': COND_SEAL        ,
		'CON_DWN': COND_DEFEAT      ,
		'CON_BLI': COND_BLIND       ,
		'CON_STU': COND_STUN        ,
		'CON_CUR': COND_CURSE       ,
		'CON_PAN': COND_PANIC       ,
		'CON_ARM': COND_DISABLE_ARMS,
		'CON_DMG': COND_DAMAGE      ,
	}
	const ELEMENT_CONV = [
		"DMG_UNTYPED",
		"DMG_CUT",
		"DMG_PIERCE",
		"DMG_STRIKE",
		"DMG_FIRE",
		"DMG_ICE",
		"DMG_ELEC",
		"DMG_UNKNOWN",
		"DMG_ULTIMATE",
	]
	const ELEMENT_MOD_TABLE = [
		'OFF_CUT', 'OFF_PIE', 'OFF_STK', 'OFF_FIR', 'OFF_ICE', 'OFF_ELE', 'OFF_UNK', 'OFF_ULT', 'OFF_KIN', 'OFF_ENE',
		'RES_CUT', 'RES_PIE', 'RES_STK', 'RES_FIR', 'RES_ICE', 'RES_ELE', 'RES_UNK', 'RES_ULT', 'RES_KIN', 'RES_ENE',
		'ALL_CUT', 'ALL_PIE', 'ALL_STK', 'ALL_FIR', 'ALL_ICE', 'ALL_ELE', 'ALL_UNK', 'ALL_ULT', 'ALL_KIN', 'ALL_ENE',
	]
	const ELEMENT_DATA = [
		{name = "untyped", color = "CCCCCC", icon = "res://resources/icons/untyped.svg"},
		{name = "cut", color = "72E36E", icon = "res://resources/icons/cut.svg"},
		{name = "pierce", color = "E26EE3", icon = "res://resources/icons/pierce.svg"},
		{name = "strike", color = "6EA4E3", icon = "res://resources/icons/bash.svg"},
		{name = "fire", color = "E36E6E", icon = "res://resources/icons/fire.svg"},
		{name = "ice", color = "6ED8E3", icon = "res://resources/icons/ice.svg"},
		{name = "elec", color = "E2E36E", icon = "res://resources/icons/elec.svg"},
		{name = "unknown", color = "EEEECC", icon = "res://resources/icons/luminous.svg"},
		{name = "ultimate", color = "080016", icon = "res://resources/icons/void.svg"},
	]

	func create():
		var result = {}
		for i in STATS: result[i] = int(000)
		result.OFF = createElementData()
		result.RES = createElementData()
		return result

	func print(S):
		var result = ""
		for i in STATS: result += "%s: %s " % [i, S[i]]
		result += printElementData(S.OFF)
		result += printElementData(S.RES)
		return result

	func reset(S, elementVal:int = 100) -> void:
		for i in STATS: S[i] = 0
		resetElementData(S.OFF, elementVal)
		resetElementData(S.RES, elementVal)

		#Handle special stats from equipment and passives.
		for i in EXTRA_STATS:
			if i in S:
				S[i] = 0
		if 'SKL' in S:
			S.SKL.clear()

	func setFromArray(S, aStat, aOFF, aRES, aRESscan):
		if aStat != null:
			for i in range(STATS.size()):
				S[STATS[i]] = int(aStat[i])
		if aOFF != null: setElementDataFromArray(S.OFF, aOFF)
		if aRES != null: setElementDataFromArray(S.RES, aRES)

	func setFromSpread(S, spread, level):
		if spread != null:
			for i in range(STATS.size()):
				S[STATS[i]] = interpolateStat(spread, i, level)

	func copy(S, stats):
		if stats != null:
			for i in STATS: S[i] = int(stats[i])
			copyElementData(S.OFF, stats.OFF)
			copyElementData(S.RES, stats.RES)

	func sum(S, stats):
		if stats != null:
			for i in STATS:
				S[i] = int(S[i] + stats[i])
			sumElementData(S.OFF, stats.OFF)
			sumElementData(S.RES, stats.RES)

	func sumInto(S, stats1, stats2):
		if stats1 != null and stats2 != null:
			for i in STATS:
				S[i] = int(stats1[i] + stats2[i])
			sumElementDataInto(S.OFF, stats1.OFF, stats2.OFF)
			sumElementDataInto(S.RES, stats1.RES, stats2.RES)

	func clipStats(S) -> void:
		for i in STATS:
			if i != "MHP":
				if S[i] < 0: S[i] = int(000)
				if S[i] > STAT_CAP: S[i] = STAT_CAP
			else:
				if S[i] < 0: S[i] = int(000)

	static func interpolateStat(spread, key, level:int) -> int:
		return int( lerp( float(spread[0][key]), float(spread[1][key]), float(level) * .01 ) )

	func createElementData() -> Dictionary:
		var result:Dictionary = {}
		for i in ELEMENTS: result[i] = int(000)
		return result

	func printElementData(E) -> String:
		var result:String = ""
		for i in ELEMENTS: result += "%s: %s " % [i, E[i]]
		return result

	func resetElementData(E, val:int = 100) -> void:
		for i in ELEMENTS: E[i] = val

	func setElementDataFromArray(E, a):
		if a != null:
			for i in ELEMENTS:
				E[i] = int(a[ELEMENTS[i]])

	func copyElementData(E, data):
		if data != null:
			for i in ELEMENTS:
				E[i] = int(data[i])

	func sumElementData(E, data):
		if data != null:
			for i in ELEMENTS:
				E[i] = int(E[i] + data[i])

	func sumElementDataInto(E, data1, data2):
		if data1 != null and data2 != null:
			for i in ELEMENTS:
				E[i] = int(data1[i] + data2[i])

	func clipElementData(E:Array) -> void:
		for i in ELEMENTS:
			if E[i] < 001: E[i] = int(001)
			if E[i] > 999: E[i] = int(999)

	func createCondDefsArray() -> Array: #Creates an array for condition defenses.
		var s:int = core.CONDITIONDEFS_DEFAULT.size()
		var result:Array = core.newArray(s)
		for i in range(s): result[i] = 0
		return result

	func conditionDefReset(a:Array) -> void:
		for i in range(core.CONDITIONDEFS_DEFAULT.size()): a[i] = 0

	func conditionDefStringValidate(st:String) -> bool:
		return true if st in CONDITION_CONV else false

	func conditionDefApply(stats, mod:String, val:int) -> void:
		if conditionDefStringValidate(mod):
			var what:int = CONDITION_CONV[mod]
			stats.CON[what] += val

	func getElementKey(element) -> String:
		var e:int = 0 if element < 0 else element
		e = e if e < ELEMENT_CONV.size() else 0
		return ELEMENT_CONV[e]

	func elementalModStringConvert(st:String) -> PoolStringArray:
		st = st.to_upper() #We want this ALLCAPS.
		if st in ELEMENT_MOD_TABLE: #String is valid.
			var result:PoolStringArray = st.split('_', true, 2)
			if result.size() == 2:
				var CONV = {
					'CUT' : 'DMG_CUT',
					'PIE' : 'DMG_PIERCE',
					'STK' : 'DMG_STRIKE',
					'FIR' : 'DMG_FIRE',
					'ICE' : 'DMG_ICE',
					'ELE' : 'DMG_ELEC',
					'UNK' : 'DMG_UNKNOWN',
					'ULT' : 'DMG_ULTIMATE',
					'KIN' : 'DMG_KINETIC',
					'ENE' : 'DMG_ENERGY',
				}
				if result[0] in ['OFF', 'RES', 'ALL']:
					if result[1] in CONV:
						result[1] = CONV[result[1]]
						return result
		return PoolStringArray(['ERR'])

	func elementalModStringValidate(st:String) -> bool:
		var result = elementalModStringConvert(st)
		return false if result[0] == 'ERR' else true

	func elementalModApply(stats, mod:String, val:int) -> void:
		var what:PoolStringArray = elementalModStringConvert(mod)
		if what[0] != 'ERR':
			if what[0] == 'ALL':
				stats.OFF[what[1]] += val
				stats.RES[what[1]] -= val
			else:
				stats[what[0]][what[1]] += val
		else:
			print("[STATS][elementalModApply] Unknown target %s (%s)" % [what[0], what])
#

# Helper functions ############################################################
static func newArray(size:int) -> Array: #Creates and returns an array with the given size.
	var a:Array = []
	a.resize(size)
	return a

static func newMatrix2D(w:int, h:int) -> Array:
	var a:Array = []
	a.resize(h)
	for i in range(h):
		a[i] = []
		a[i].resize(w)
		for j in range(w):
			a[i][j] = 0
	return a

static func valArray(val, size:int) -> Array: #Creates an array of given size where all values are val.
	var a:Array = []
	a.resize(size)
	for i in range(size):
		a[i] = val
	return a

static func itoba8(val:int) -> PoolByteArray:
	var result:PoolByteArray = PoolByteArray([0,0,0,0, 0,0,0,0])
	val = val % 256
	for i in range(8):
		result[i] = (val % 2)
		val = floor(val / 2.0) as int
	return result

static func itoba4(val:int) -> PoolByteArray:
	var result:PoolByteArray = PoolByteArray([0,0,0,0])
	val = val % 256
	for i in range(4):
		result[i] = (val % 2)
		val = floor(val / 2.0) as int
	return result

static func batos(val:PoolByteArray) -> String:
	val.invert()
	var result:String = ""
	for i in val:
		result += str(i)
	return result

static func itobs(val:int) -> String:
	var result:String = ""
	val = val % 256
	while val > 0:
		result = str(val % 2, result)
		val = floor(val / 2.0) as int
	return result

static func copyArray(array) -> Array: #TODO: Maybe it should be a duplicate() instead?
	var result = []
	var size = array.size()
	result.resize(size)
	for i in range(size):
		result[i] = array[i]
	return result

static func chance(val) -> bool: #Calculate a random chance in a way humans can understand it easily.
	if val >= 100: return true
	else:	return true if val > (randi() % 100) else false

static func normalize(v:int, m:int) -> float: #I was tired of doing the casting by hand don't judge me.
	return float(float(v) / float(m))

static func percent(v:int) -> float: #Cast a X% number into something more suitable for multiplications.
	return float(v) * .01

static func percentMod(x:int, y:int) -> int: #Modify an integer x by y%. Done here to simplify things.
	return round(x as float * (y as float * .01)) as int

static func clampi(x:int, mi:int, ma:int) -> int: #Equivalent to clamp() but uses ints only.
	return clamp(x, mi, ma) as int

static func randomPick(val): #TODO: Don't gdscript arrays have this feature already?
	match typeof(val):
		TYPE_ARRAY:
			var r = randi() % val.size()
			return val[r]

static func line(from:Vector2, to:Vector2, brush:int, map:Array): #Draw a line in a given 2D nested array matrix.
	#Boilerplate Bresenham integer line plotting algorithm.
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(to.x) as int;   var y1:int = round(to.y) as int
	var delta_x:int = abs(x1 - x0) as int
	var delta_y:int = abs(y1 - y0) as int
	var sx:int = -1 if x0 > x1 else 1
	var sy:int = -1 if y0 > y1 else 1
	var err:int = ((delta_x if delta_x > delta_y else -delta_y) as float / 2.0) as int
	while true:
		map[y0][x0] = brush
		if (x0 == x1 and y0 == y1): break
		var e2 = err
		if e2 > -delta_x:
			err -= delta_y; x0 += sx
		if e2 < delta_y:
			err += delta_x; y0 += sy


static func plot_line(from:Vector2, to:Vector2, col:Color, map:Image): #TODO: Move to core, might need it there.
	#Boilerplate Bresenham integer line plotting algorithm.
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(to.x) as int;   var y1:int = round(to.y) as int
	var delta_x:int = abs(x1 - x0) as int
	var delta_y:int = abs(y1 - y0) as int
	var sx:int = -1 if x0 > x1 else 1
	var sy:int = -1 if y0 > y1 else 1
	var err:int = ((delta_x if delta_x > delta_y else -delta_y) as float / 2.0) as int
	while true:
		map.set_pixel(x0, y0, col)
		if (x0 == x1 and y0 == y1): break
		var e2 = err
		if e2 > -delta_x:
			err -= delta_y; x0 += sx
		if e2 < delta_y:
			err += delta_x; y0 += sy


###############################################################################



func quit(): #Quits the game.
	get_tree().quit()

func playMusic(path): #Plays music file at path in default audio stream player.
	var bgm = load(path)
	if bgm != null:
		$AudioStreamPlayer.set_stream(bgm)
		$AudioStreamPlayer.playing = true

func stopMusic():
	$AudioStreamPlayer.playing = false

func initLibs() -> void:
	#Load skill interpreter and keep in memory.
	skill = load("res://classes/skill/skill.gd").new()
	#Skill library.
	lib.skill = load("res://classes/library/lib_skill.gd").new();           lib.skill.loadDebug()
	#Player race library
	lib.race = load("res://classes/library/lib_race.gd").new();             lib.race.loadDebug()
	#Adventurer class library.
	lib.aclass = load("res://classes/library/lib_class.gd").new();          lib.aclass.loadDebug()
	#Weapon library.
	lib.weapon = load("res://classes/library/lib_weapon.gd").new();         lib.weapon.loadDebug()
	#Item library.
	lib.item = load("res://classes/library/lib_item.gd").new();             lib.item.loadDebug()
	#Dragon gem library.
	lib.dgem = load("res://classes/library/lib_gem.gd").new();              lib.dgem.loadDebug()
	#Armor/Vehicle/Frame parts library.
	lib.armorparts = load("res://classes/library/lib_armorparts.gd").new(); lib.armorparts.loadDebug()
	#Armor/Vehicle/Frame library.
	lib.armor = load("res://classes/library/lib_armor.gd").new();           lib.armor.loadDebug()
	#Enemy library.
	lib.enemy = load("res://classes/library/lib_enemy.gd").new();           lib.enemy.loadDebug()
	#TODO: Mon library
	#Enemy formation library.
	lib.mform = load("res://classes/library/lib_group_enemy.gd").new();     lib.mform.loadDebug()

func getSkillPtr(TID):
	return lib.skill.getIndex(TID)


func initGameState(_seed):
	if init:
		return
	else:
		seed(_seed)
		initLibs()
		init = true


func _ready() -> void:
	seed(OS.get_unix_time())
	var root = get_tree().get_root()
	scene    = root.get_child(root.get_child_count() - 1)


func initBattle(form, elv:int = 0, music = "res://resources/music/情動カタルシス.mp3"):
	var formation = load("res://classes/group/group_enemy.gd").new()
	formation.init(form, elv)
	battle.enemy = formation
	battle.music = music
	changeScene("res://tests/ctrltest.tscn")

func initGuild(file):
	guild = load("res://classes/group/group_guild.gd").new()
	guild.loadDebug()
	if guild == null:
		print("****************************ERROR*********************************")

func changeScene(path):
	call_deferred("changeScene2", path)

func changeScene2(path):
	if scene != null: scene.free()
	var newscene = load(path).instance()
	var tree = get_tree()
	var root = tree.get_root()
	scene = newscene
	root.add_child(newscene)
	tree.set_current_scene(newscene)
