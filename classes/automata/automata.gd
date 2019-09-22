# Cellular automata ###########################################################
class CellularAutomaton:
	#Base cellular automaton. It does nothing at all.
	#It's meant to be inherited from.
	const iter_neighbor_moore = [ #Moore neighborhood. Checks 8 surrounding cells.
		#Same order as Golly rule files.
		#N        NE       E        SE         S        SW       W        NW
		[ 0, 1], [ 1, 1], [ 1, 0], [ 1,-1],   [ 0,-1], [-1,-1], [-1, 0], [-1, 1],
	]
	const iter_neighbor_von_neumann = [  #Von Neumann neighborhood. Checks 4 surrounding cells.
						[-1, 0],
		[ 0,-1],         [ 0, 1],
						[ 1, 0],
	]
	var glow:Array
	var name:String = "NULL"
	var visual_data:Dictionary
	var palette:Array
	var core = null
	func rules(map, x:int, y:int) -> int:
		var cell = map[y][x]
		return cell
	func _to_string() -> String:
		return "Automaton: %s" % name

class ConwayLife extends CellularAutomaton:
	# The famous (much to Conway's half-indignation) cellular automata,
	# "Game of Life". It's a simple machine simulating rough population rules.
	enum { NULL = 0, LIVE = 1 }
	func _init(w:int, h:int) -> void:
		name = "Conway's Game of Life"
		glow = [ LIVE ]
		visual_data = {
			NULL: { color = Color("#00000000"), name = "Empty" },
			LIVE: { color = Color("#88FF88"),   name = "Alive" },
		}
		palette = [ NULL, LIVE ]
#""" 	func rules(map, x:int, y:int) -> int:
#		var cell = map[y][x]
#		var neighbors = 0
#		for off in iter_neighbor_moore: neighbors += 1 if map[y+off[0]][x+off[1]] == LIVE else 0
#		return LIVE if ((neighbors == 3) or (cell == LIVE and neighbors == 2)) else NULL """
	func soft_reset(map, x:int, y:int) -> int: #Turn all to NULL.
		return NULL

class Wireworld extends CellularAutomaton:
	# Wireworld is an automaton invented by Brian Silverman in 1987.
	# Using four simple rules, it's able to simulate the flow of electrons in a
	# wire circuit, including logic gates. Despite its simplicity, it's
	# Turing-complete and at least one working computer has been created using
	# it alone.
	# https://en.wikipedia.org/wiki/Wireworld
	# https://web.archive.org/web/20100526042019if_/http://karl.kiwi.gen.nz/CA-Wireworld.html
	enum { NULL = 0, HEAD, TAIL, WIRE }
	func _init(w:int, h:int) -> void:
		name = "Wireworld"
		glow = [HEAD, TAIL]
		visual_data = {
			NULL: { color = Color("#00000000"), name = "NULL" },
			WIRE: { color = Color("#433300"),   name = "Wire" },
			HEAD: { color = Color("#C4DBFF"),   name = "Electron head" },
			TAIL: { color = Color("#1E4E99"),   name = "Electron tail" },
		}
		palette = [ NULL, WIRE ]
#""" 	func rules(map, x:int, y:int) -> int: #Wireworld automaton rules.
#		var cell = map[y][x]
#		match cell:
#			HEAD: return TAIL
#			TAIL: return WIRE
#			WIRE:
#				var neighbors = 0
#				for off in iter_neighbor_moore: neighbors += 1 if map[y+off[0]][x+off[1]] == HEAD else 0
#				return HEAD if neighbors == 1 or neighbors == 2 else WIRE
#		return cell """

class WireworldRGB extends CellularAutomaton:
	# Wireworld_RGB is a variant of Wireworld invented by Lode Vandevenne in 2017.
	# It features 3 colors of wire that interact with each other in slightly different ways.
	# This allows for much more compact and fast designs while allowing total compatibility with
	# Wireworld if you use only red wire, making it the most interesting variant in my opinion.
	# https://lodev.org/ca/wireworldrgb.html
	# Example board for Golly: https://lodev.org/ca/Patterns/wireworld_rgb.mc
	const CORE = preload("res://classes/automata/WireworldRGB.cs")
	const data = {
		"DIODE"     : { name = "Diode"         , period = "0", desc = "Diode. Ensures flow cannot go back. Blue wire is forward.",
			data = [ [0,0,0,0], [3,3,6,9], [0,0,0,0] ], },
		"AND"       : { name = "AND Gate"      , period = "" , desc = "AND gate.",
			data = [ [3,6,9,0,0], [0,0,0,9,3], [3,6,9,0,0] ], },
		"OR"        : { name = "OR Gate"       , period = "" , desc = "OR gate",
			data = [ [3,6,9,0,0], [0,0,0,3,3], [3,6,9,0,0] ], },
		"XOR"       : { name = "XOR Gate"      , period = "" , desc = "XOR gate",
			data = [ [3,3,6,0,0], [0,0,0,9,3], [3,3,6,0,0] ], },
		"ANDNOT"    : { name = "ANDNOT Gate"   , period = "" , desc = "ANDNOT gate",
			data = [ [3,6,9,0,0], [0,0,0,9,3], [3,3,6,0,0] ], },
		"NOT"       : { name = "NOT Gate"      , period = "" , desc = "NOT gate" },
		"NOR"       : { name = "NOR Gate"      , period = "" , desc = "NOR gate" },
		"NAND"      : { name = "NAND Gate"     , period = "" , desc = "NAND gate" },
		"XNOR"      : { name = "XNOR Gate"     , period = "" , desc = "XNOR gate" },
		"CROSS"     : { name = "Wire Crossing" , period = "3", desc = "Wire crossing.",
			data = [ [0,6,0,0,0], [3,0,9,3,3], [0,6,0,0,0], [3,0,9,3,3], [0,6,0,0,0] ], },
		"SRL3"      : { name = "SR Latch"      , period = "3", desc = "SR Latch for period 3 streams." },
		"SRL4"      : { name = "SR Latch"      , period = "4", desc = "SR Latch for period 4 streams." },
		"SRL6"      : { name = "SR Latch"      , period = "6", desc = "" },
		"TFF3"      : { name = "T Flip-Flop"   , period = "3", desc = "" },
		"TFF4"      : { name = "T Flip-Flop"   , period = "4", desc = "" },
		"TFF6"      : { name = "T Flip-Flop"   , period = "6", desc = "" },
		"DFF6"      : { name = "D Flip-Flop"   , period = "6", desc = "" },
		"BINCOUNT4" : { name = "Binary Counter", period = "3", desc = "" },
		"BINCOUNT8" : { name = "Binary Counter", period = "3", desc = "" },
	}
	enum { NULL = 0, HEAD_R, TAIL_R, WIRE_R, HEAD_G, TAIL_G, WIRE_G, HEAD_B, TAIL_B, WIRE_B }
	func _init(w:int, h:int) -> void:
		name = "WireworldRGB"
		glow = [HEAD_R, TAIL_R, HEAD_G, TAIL_G, HEAD_B, TAIL_B]
		visual_data = {
			NULL: { color = Color("#00000000"), name = "NULL" },
			WIRE_R: { color = Color("#430000"), name = "Red wire" },
			HEAD_R: { color = Color("#FF90D0"), name = "Red electron head" },
			TAIL_R: { color = Color("#994E1E"), name = "Red electron tail" },
			WIRE_G: { color = Color("#004300"), name = "Green wire" },
			HEAD_G: { color = Color("#B4FFB0"), name = "Green electron head" },
			TAIL_G: { color = Color("#64FF69"), name = "Green electron tail" },
			WIRE_B: { color = Color("#121083"), name = "Blue wire" },
			HEAD_B: { color = Color("#C0C0FF"), name = "Blue electron head" },
			TAIL_B: { color = Color("#7060DF"), name = "Blue electron tail" },
		}
		palette = [ NULL, WIRE_R, WIRE_G, WIRE_B, HEAD_R, HEAD_G, HEAD_B, TAIL_R, TAIL_G, TAIL_B ]
		core = CORE.new()
		core.init(w, h, visual_data)
#""" 	func rules(map, x:int, y:int) -> int: #Wireworld_RGB automaton rules.
#		var cell = map[y][x]
#		if cell == NULL: return NULL
#		match cell:
#			HEAD_R: return TAIL_R
#			HEAD_G: return TAIL_G
#			HEAD_B: return TAIL_B
#			TAIL_R: return WIRE_R
#			TAIL_G: return WIRE_G
#			TAIL_B: return WIRE_B
#			WIRE_R:
#				var neighbors_r:int = 0
#				var neighbors_b:int = 0
#				for off in iter_neighbor_moore:
#					if map[y+off[0]][x+off[1]] == HEAD_R: neighbors_r += 1
#					if map[y+off[0]][x+off[1]] == HEAD_B: neighbors_b += 1
#				if   neighbors_r == 1 or neighbors_r == 2: return HEAD_R
#				elif neighbors_b == 1 or neighbors_b == 2: return HEAD_R
#				else: return WIRE_R
#			WIRE_G:
#				var neighbors_r:int = 0
#				var neighbors_g:int = 0
#				for off in iter_neighbor_moore:
#					if map[y+off[0]][x+off[1]] == HEAD_R: neighbors_r += 1
#					if map[y+off[0]][x+off[1]] == HEAD_G: neighbors_g += 1
#				if   neighbors_g == 1: return HEAD_G
#				elif neighbors_r == 1: return HEAD_G
#				else: return WIRE_G
#			WIRE_B:
#				var neighbors_b:int = 0
#				var neighbors_g:int = 0
#				for off in iter_neighbor_moore:
#					if map[y+off[0]][x+off[1]] == HEAD_B: neighbors_b += 1
#					if map[y+off[0]][x+off[1]] == HEAD_G: neighbors_g += 1
#				if   neighbors_b == 2: return HEAD_B
#				elif neighbors_g == 1 and neighbors_b == 0: return HEAD_B #n_b==0 is important or it won't work.
#				else: return WIRE_B
#		return cell """

class Bullets extends CellularAutomaton:
	# A rough simulation of light. Has some available timers and logic gates possible.
	# Fun to play with.
	# By ConwayLife forums user Redstoneboi.
	enum { NULL = 0, HEAD, TAIL, WALL }
	const custom_iter:Array = [0, 2, 4, 6] #Even though this automaton uses moore neighborhoods, it's faster to just check up/down/left/right.
	func _init() -> void:
		name = "Bullets"
		glow = [ HEAD, TAIL ]
		visual_data = {
			NULL: { color = Color("#00000000"), name = "NULL" },
			HEAD: { color = Color("#C488FF"),   name = "Photon Head"},
			TAIL: { color = Color("#302090"),   name = "Photon Tail"},
			WALL: { color = Color("#104E51"),   name = "Wall"}
		}
		palette = [ NULL, WALL, HEAD, TAIL ]
#""" 	func rules(map, x:int, y:int) -> int: #Bullets automaton rules.
#		var cell = map[y][x]
#		if   cell == HEAD: return TAIL
#		elif cell == TAIL: return NULL
#		elif cell == NULL:
#			var temp2 = 0
#			var l = 0
#			var r = 0
#			for i in custom_iter:
#				if map[y+iter_neighbor_moore[i][0]][x+iter_neighbor_moore[i][1]] == HEAD:
#					l = map[y+iter_neighbor_moore[i-1][0]][x+iter_neighbor_moore[i-1][1]]
#					r = map[y+iter_neighbor_moore[i+1][0]][x+iter_neighbor_moore[i+1][1]]
#					if   (l == NULL and r == TAIL) or (r == NULL and l == TAIL): return NULL
#					temp2 += 1
#			if temp2 > 0: return HEAD
#
#		return cell """

class Diamonds extends CellularAutomaton:
	# This is just silly.
	enum { NULL = 0, HEAD, TAIL, WALL }
	func _init() -> void:
		name = "Bullets"
		glow = [ HEAD, TAIL ]
		visual_data = {
			NULL: { color = Color("#00000000"), name = "NULL" },
			HEAD: { color = Color("#0088FF"), name = "Photon Head"},
			TAIL: { color = Color("#000088"), name = "Photon Tail"},
		}
		palette = [ NULL, WALL, HEAD, TAIL ]
#""" 	func rules(map, x:int, y:int) -> int: #Wireworld automaton rules.
#		var cell = map[y][x]
#		match cell:
#			NULL:
#				var transition_table:Array = []
#				var temp = 0
#				var temp2 = 0
#				var temp3 = 0
#				for off in iter_neighbor_moore:
#					temp = map[y+off[0]][x+off[1]]
#					transition_table.append(temp)
#				temp = 0
#				for i in [1,3,4,6]:
#					if transition_table[i] == HEAD:
#						temp += 1
#					if (transition_table[i-1] == TAIL) or (transition_table[i+1 % 8] == TAIL):
#						temp2 += 1
#					if (transition_table[i-1] == NULL) or (transition_table[i+1 % 8] == NULL):
#						temp3 += 1
#				return HEAD if temp > 0 else NULL
#			HEAD: return TAIL
#			TAIL: return NULL
#		return cell
# """
