extends Node

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
var battle = {
	enemy = null,
	bgm = null,
	control = null,
	skillControl = null,
	background = null,
	bg_fx = null,
}
var world : WorldClass = WorldClass.new()
# Internal Data libraries #####################################################
var lib = {
	skill = null,
	race = null,
	aclass = null,
	weapon = null,
	item = null,
	dgem = null,
	armor = null,
	enemy = null,
	mform = null,
}
var stats = StatClass.new()
var tid = _tid.new()
var skill = null
var guild = null
var init = false

# Important shared classes ####################################################
const Enemy = preload("res://classes/char/char_enemy.gd")
const Player = preload("res://classes/char/char_player.gd")
const Inventory = preload("res://classes/inventory/item.gd")

class WorldClass:
	var time:int = 0        #30 steps or turns => one hour.
	var day:int = 0         #30 days => one month.
	var IDcounter:int = 0   #Internal counter for enemy/monster IDs.

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

	func _init(val:int = 0):
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
		"normal" : ["1A3477", "A0DAE0", "3B67A7", "B0fae0"],
		"select" : ["5A8457", "FFFFFF", "8A6427", "FFFFFF"],
		"damage" : ["771A1A", "FFB666", "882A2A", "FFC676"],
		"status" : ["773477", "75EEFF", "9764A7", "95FEFF"],
		"stasis" : ["77347788", "75EEFF88", "87448788", "85FEFF88"],
		"defeat" : ["888888", "AAAAAA", "A8A8A8", "CFCFCF"],
	}
	var style = null 				#StyleBox for the panel.
	var styleName = ""			#Godot's style path
	var node = null					#Node to control
	var theme = "normal"		#Theme key
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
			core.skill.STATUS_NONE:
				setTheme("normal")
			core.skill.STATUS_DOWN:
				setTheme("damage")
			core.skill.STATUS_STASIS:
				setTheme("stasis")
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
			TYPE_STRING:
				return fromString(a)
			TYPE_ARRAY:
				return fromArray(a)
			TYPE_STRING_ARRAY:
				return fromArray(a)
			_:
				return create("debug", "debug")

	func copy(tid) -> PoolStringArray: #Makes a copy of a TID.
		return create(tid[0], tid[1])

	func string(tid) -> String: #Prints a TID as a string in the format "section/item"
		var result:String = "%s/%s" % [tid[0], tid[1]]
		return result

	func compare(tid1, tid2) -> bool: #Compare two TIDs.
		return true if (tid1[0] == tid2[0] and tid1[1] == tid2[2]) else false

class StatClass:
	const STAT_CAP = 255
	const MAX_DMG = 32000
	const STATS = [ 'MHP', 'ATK', 'DEF', 'ETK', 'EDF', 'AGI', 'LUC' ]
	const GEAR_STATS = [ 'MEP', 'SKL' ]
	enum STAT { MHP, ATK, DEF, ETK, EDF, AGI, LUC	}
	enum ELEMENTS {
		DMG_UNTYPED = 0,	#Cannot be resisted
		DMG_CUT,					#Slash or wind attacks
		DMG_PIERCE,				#Perforating or earth attacks.
		DMG_STRIKE,				#Strike/explosive or water attacks.
		DMG_FIRE,					#Fire attacks
		DMG_ICE,					#Ice attacks
		DMG_ELEC,					#Electric attacks
		#DMG_UNKNOWN,			#Time/Light/Spirit attacks (Use sparingly)
		DMG_ULTIMATE,			#Gravity/Dark attacks (Use sparingly)
		DMG_KINETIC,			#Supertype for all physical damage
		DMG_ENERGY,				#Supertype for all energy damage
	}
	const ELEMENT_CONV = [
		"DMG_UNTYPED",
		"DMG_CUT",
		"DMG_PIERCE",
		"DMG_STRIKE",
		"DMG_FIRE",
		"DMG_ICE",
		"DMG_ELEC",
		#"DMG_UNKNOWN",
		"DMG_ULTIMATE",
	]
	const ELEMENT_MOD_TABLE = [
		'OFF_CUT', 'OFF_PIE', 'OFF_STK', 'OFF_FIR', 'OFF_ICE', 'OFF_ELE', 'OFF_LUM', 'OFF_ULT', 'OFF_KIN', 'OFF_ENE',
		'RES_CUT', 'RES_PIE', 'RES_STK', 'RES_FIR', 'RES_ICE', 'RES_ELE', 'RES_LUM', 'RES_ULT', 'RES_KIN', 'RES_ENE',
		'ALL_CUT', 'ALL_PIE', 'ALL_STK', 'ALL_FIR', 'ALL_ICE', 'ALL_ELE', 'ALL_LUM', 'ALL_ULT', 'ALL_KIN', 'ALL_ENE',
	]
	const ELEMENT_DATA = [
		{name = "untyped", color = "CCCCCC", icon = "res://resources/icons/untyped.svg"},
		{name = "cut", color = "72E36E", icon = "res://resources/icons/cut.svg"},
		{name = "pierce", color = "E26EE3", icon = "res://resources/icons/pierce.svg"},
		{name = "strike", color = "6EA4E3", icon = "res://resources/icons/bash.svg"},
		{name = "fire", color = "E36E6E", icon = "res://resources/icons/fire.svg"},
		{name = "ice", color = "6ED8E3", icon = "res://resources/icons/ice.svg"},
		{name = "elec", color = "E2E36E", icon = "res://resources/icons/elec.svg"},
		#{name = "unknown", color = "EEEECC", icon = "res://resources/icons/void.svg"},
		{name = "ultimate", color = "000000", icon = "res://resources/icons/void.svg"},
	]



	func getElementKey(element):
		var e
		e = int(0) if element < 0 else element
		e = e if e < ELEMENT_CONV.size() else int(0)
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
					#'LUM' : 'DMG_LUMINOUS',
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

	func create():
		var result = {}
		for i in STATS:
			result[i] = int(000)
		result.OFF = createElementData()
		result.RES = createElementData()
		return result

	func print(S):
		var result = ""
		for i in STATS:
			result += "%s: %s " % [i, S[i]]
		result += printElementData(S.OFF)
		result += printElementData(S.RES)
		return result

	func reset(S, elementVal:int = 100) -> void:
		for i in STATS:
			S[i] = 0
		resetElementData(S.OFF, elementVal)
		resetElementData(S.RES, elementVal)

		#Handle special stats from items or such.
		for i in [ 'MEP', 'WRD', 'DUR' ]:
			if i in S:
				S[i] = 0
		if 'SKL' in S:
			S.SKL.clear()

	func setFromArray(S, aStat, aOFF, aRES, aRESscan):
		if aStat != null:
			for i in range(STATS.size()):
				S[STATS[i]] = int(aStat[i])
		if aOFF != null:
			setElementDataFromArray(S.OFF, aOFF)
		if aRES != null:
			setElementDataFromArray(S.RES, aRES)

	func setFromSpread(S, spread, level):
		if spread != null:
			for i in range(STATS.size()):
				S[STATS[i]] = interpolateStat(spread, i, level)

	func copy(S, stats):
		if stats != null:
			for i in STATS:
				S[i] = int(stats[i])
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

	func clipStats(S):
		for i in STATS:
			if i != "MHP":
				if S[i] < 0: S[i] = int(000)
				if S[i] > STAT_CAP: S[i] = STAT_CAP
			else:
				if S[i] < 0: S[i] = int(000)

	static func interpolateStat(spread, key, level:int):
		return int( lerp( float(spread[0][key]), float(spread[1][key]), float(level) * .01 ) )

	func createElementData():
		var result = {}
		for i in ELEMENTS:
			result[i] = int(000)
		return result

	func printElementData(E):
		var result = ""
		for i in ELEMENTS:
			result += "%s: %s " % [i, E[i]]
		return result

	func resetElementData(E, val:int = 100):
		for i in ELEMENTS:
			E[i] = val

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

	func clipElementData(E):
		for i in ELEMENTS:
			if E[i] < 1: E[i] = int(001)
			if E[i] > 999: E[i] = int(999)





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



static func valArray(val, size) -> Array: #Creates an array of given size where all values are val.
	var a = []
	a.resize(size)
	for i in a:
		i = val
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

static func clampi(x:int, mi:int, ma:int) -> int: #Equivalent to clamp() but uses ints only.
	return clamp(x, mi, ma) as int

static func randomPick(val): #TODO: Don't gdscript arrays have this feature already?
	match typeof(val):
		TYPE_ARRAY:
			var r = randi() % val.size()
			return val[r]


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


func _ready():
	seed(OS.get_unix_time())
	var root = get_tree().get_root()
	scene = root.get_child(root.get_child_count() - 1)


func initBattle(form, elv = 0, music = "res://resources/music/EOIV_Storm.ogg"):
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
