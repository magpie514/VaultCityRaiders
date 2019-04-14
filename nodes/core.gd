extends Node
var scene = null #Current scene
var battle = {
	enemy = null,
	bgm = null,
	control = null,
	skillControl = null
}
var lib = {
	race = null,
	aclass = null,
	weapon = null,
	monster = null,
	mform = null,
	skill = null,
	item = null
}
var stats = StatClass.new()
var tid = _tid.new()
var skill = null
var guild = null
var init = false

var Enemy = load("res://classes/char/char_enemy.gd")
var Player = load("res://classes/char/char_player.gd")


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
class _tid:
	func create(a, b):
		return [str(a), str(b)]

	func validateArray(tid):
		if typeof(tid) != TYPE_ARRAY: return false
		else:
			if tid[0] == null: return false
			if tid[1] == null: return false
			return true

	func fromArray(a):
		if validateArray(a):
			return create(a[0], a[1])
		else:
			return create("debug", "debug")

	func copy(tid):
		create(tid[0], tid[1])
class StatClass:
	const STAT_CAP = 255
	const MAX_DMG = 32000
	const STATS = [ "MHP", "ATK", "DEF", "ETK", "EDF", "AGI", "LUC" ]
	enum STAT { MHP, ATK, DEF, ETK, EDF, AGI, LUC	}
	enum ELEMENTS {
		DMG_UNTYPED = 0,	#Cannot be resisted
		DMG_CUT,					#Slash or wind attacks
		DMG_PIERCE,				#Perforating or earth attacks.
		DMG_BLUNT,				#Blunt/explosive or water attacks.
		DMG_FIRE,					#Fire attacks
		DMG_ICE,					#Ice attacks
		DMG_ELEC,					#Electric attacks
		DMG_ULTIMATE,			#Spirit/Gravity/Light/Dark attacks (Use sparingly)
		DMG_KINETIC,			#Supertype for all physical damage
		DMG_ENERGY,				#Supertype for all energy damage
	}
	const ELEMENT_CONV = [
		"DMG_UNTYPED",
		"DMG_CUT",
		"DMG_PIERCE",
		"DMG_BLUNT",
		"DMG_FIRE",
		"DMG_ICE",
		"DMG_ELEC",
		"DMG_ULTIMATE",
	]
	const ELEMENT_DATA = [
		{name = "untyped", color = "CCCCCC", icon = "res://resources/icons/untyped.svg"},
		{name = "cut", color = "72E36E", icon = "res://resources/icons/cut.svg"},
		{name = "pierce", color = "E26EE3", icon = "res://resources/icons/pierce.svg"},
		{name = "blunt", color = "6EA4E3", icon = "res://resources/icons/bash.svg"},
		{name = "fire", color = "E36E6E", icon = "res://resources/icons/fire.svg"},
		{name = "ice", color = "6ED8E3", icon = "res://resources/icons/ice.svg"},
		{name = "elec", color = "E2E36E", icon = "res://resources/icons/elec.svg"},
		{name = "ultimate", color = "000000", icon = "res://resources/icons/void.svg"}
	]


	func getElementKey(element):
		var e
		e = int(0) if element < 0 else element
		e = e if e < ELEMENT_CONV.size() else int(0)
		return ELEMENT_CONV[e]

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

	static func interpolateStat(spread, key, level):
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

	func resetElementData(E):
		for i in ELEMENTS:
			E[i] = int(100)

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

static func newArray(size) -> Array:
	var a = []
	a.resize(size)
	return a

static func valArray(val, size):
	var a = []
	a.resize(size)
	for i in a:
		i = val
	return a

static func copyArray(array):
	var result = []
	var size = array.size()
	result.resize(size)
	for i in range(size):
		result[i] = array[i]
	return result

static func chance(val) -> bool:
	if val >= 100: return true
	else:	return true if val > (randi() % 100) else false

static func normalize(v:int, m:int) -> float: #I was tired of doing the casting by hand don't judge me.
	return float(float(v) / float(m))

static func percent(v:int) -> float:
	return float(v) * .01

static func randomPick(val):
	match typeof(val):
		TYPE_ARRAY:
			var r = randi() % val.size()
			return val[r]


func quit():
	get_tree().quit()

func playMusic(path):
	var bgm = load(path)
	if bgm != null:
		$AudioStreamPlayer.set_stream(bgm)
		$AudioStreamPlayer.playing = true

func stopMusic():
	$AudioStreamPlayer.playing = false

func initLibs():
	skill = load("res://classes/skill/skill.gd").new()
	lib.skill = load("res://classes/library/lib_skill.gd").new()
	lib.skill.loadDebug()
	lib.race = load("res://classes/library/lib_race.gd").new()
	lib.race.loadDebug()
	lib.aclass = load("res://classes/library/lib_class.gd").new()
	lib.aclass.loadDebug()
	lib.monster = load("res://classes/library/lib_monster.gd").new()
	lib.monster.loadDebug()
	lib.weapon = load("res://classes/library/lib_weapon.gd").new()
	lib.weapon.loadDebug()
	lib.mform = load("res://classes/library/lib_group_enemy.gd").new()
	lib.mform.loadDebug()
	lib.item = load("res://classes/library/lib_item.gd").new()
	lib.item.loadDebug()
	lib.dgem = load("res://classes/library/lib_gem.gd").new()
	lib.dgem.loadDebug()


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
	scene.free()
	scene = load(path).instance()
	get_tree().get_root().add_child(scene)
	get_tree().set_current_scene(scene)
