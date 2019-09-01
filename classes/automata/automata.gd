# Cellular automata ###########################################################
class CellularAutomaton:
	#Base cellular automaton. It does nothing at all.
	#It's meant to be inherited from.
	const iter_neighbor_moore = [ #Moore neighborhood. Checks 8 surrounding cells.
		[-1,-1], [-1, 0], [-1, 1],
		[ 0,-1],          [ 0, 1],
		[ 1,-1], [ 1, 0], [ 1, 1]
	]
	const iter_neighbor_von_neumann = [  #Von Neumann neighborhood. Checks 4 surrounding cells.
						[-1, 0],
		[ 0,-1],         [ 0, 1],
						[ 1, 0],
	]
	var glow:Array
	var visual_data:Dictionary
	var palette:Array
	func rules(map, x:int, y:int) -> int:
		var cell = map[y][x]
		return cell
	func soft_reset(map, x:int, y:int) -> int: #Do nothing.
		return map[y][x]
	func _to_string() -> String:
		return "Automaton: NULL"

class ConwayLife extends CellularAutomaton:
	# The famous (much to Conway's half-indignation) cellular automata,
	# "Game of Life". It's a simple machine simulating rough population rules.
	enum { NULL = 0, LIVE = 1 }
	func _init() -> void:
		glow = [ LIVE ]
		visual_data = {
			NULL: { color = Color("#00000000"), name = "Empty" },
			LIVE: { color = Color("#88FF88"),   name = "Alive" },
		}
		palette = [ NULL, LIVE ]
	func rules(map, x:int, y:int) -> int:
		var cell = map[y][x]
		var neighbors = 0
		for off in iter_neighbor_moore: neighbors += 1 if map[y+off[0]][x+off[1]] == LIVE else 0
		return LIVE if ((neighbors == 3) or (cell == LIVE and neighbors == 2)) else NULL
	func soft_reset(map, x:int, y:int) -> int: #Turn all to NULL.
		return NULL
	func _to_string() -> String:
		return "Automaton: Conway's Life"

class Wireworld extends CellularAutomaton:
	# Wireworld is an automaton invented by Brian Silverman in 1987.
	# Using four simple rules, it's able to simulate the flow of electrons in a
	# wire circuit, including logic gates. Despite its simplicity, it's
	# Turing-complete and at least one working computer has been created using
	# it alone.
	# https://en.wikipedia.org/wiki/Wireworld
	# https://web.archive.org/web/20100526042019if_/http://karl.kiwi.gen.nz/CA-Wireworld.html
	enum { NULL = 0, HEAD, TAIL, WIRE }
	func _init() -> void:
		glow = [HEAD, TAIL]
		visual_data = {
			NULL: { color = Color("#00000000"), name = "NULL" },
			WIRE: { color = Color("#433300"),   name = "Wire" },
			HEAD: { color = Color("#C4DBFF"),   name = "Electron head" },
			TAIL: { color = Color("#1E4E99"),   name = "Electron tail" },
		}
		palette = [ NULL, WIRE ]
	func rules(map, x:int, y:int) -> int: #Wireworld automaton rules.
		var cell = map[y][x]
		match cell:
			HEAD: return TAIL
			TAIL: return WIRE
			WIRE:
				var neighbors = 0
				for off in iter_neighbor_moore: neighbors += 1 if map[y+off[0]][x+off[1]] == HEAD else 0
				return HEAD if neighbors == 1 or neighbors == 2 else WIRE
		return cell
	func soft_reset(map, x:int, y:int) -> int: #Turn all to wire.
		return WIRE if map[y][x] != NULL else NULL
	func _to_string() -> String:
		return "Automaton: Wireworld"

class WireworldRGB extends CellularAutomaton:
	# Wireworld_RGB is a variant of Wireworld invented by Lode Vandevenne in 2017.
	# It features 3 colors of wire that interact with each other in slightly different ways.
	# This allows for much more compact and fast designs while allowing total compatibility with
	# Wireworld if you use only red wire, making it the most interesting variant in my opinion.
	# https://lodev.org/ca/wireworldrgb.html
	# Example board for Golly: https://lodev.org/ca/Patterns/wireworld_rgb.mc
	enum { NULL = 0, HEAD_R, TAIL_R, WIRE_R, HEAD_G, TAIL_G, WIRE_G, HEAD_B, TAIL_B, WIRE_B }
	func _init() -> void:
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
		palette = [ NULL, WIRE_R, HEAD_R, TAIL_R, WIRE_G, HEAD_G, TAIL_G, WIRE_B, HEAD_B, TAIL_B ]
	func rules(map, x:int, y:int) -> int: #Wireworld_RGB automaton rules.
		var cell = map[y][x]
		match cell:
			HEAD_R: return TAIL_R
			HEAD_G: return TAIL_G
			HEAD_B: return TAIL_B
			TAIL_R: return WIRE_R
			TAIL_G: return WIRE_G
			TAIL_B: return WIRE_B
			WIRE_R:
				var neighbors_r:int = 0
				var neighbors_b:int = 0
				for off in iter_neighbor_moore:
					if map[y+off[0]][x+off[1]] == HEAD_R: neighbors_r += 1
					if map[y+off[0]][x+off[1]] == HEAD_B: neighbors_b += 1
				if   neighbors_r == 1 or neighbors_r == 2: return HEAD_R
				elif neighbors_b == 1 or neighbors_b == 2: return HEAD_R
				else: return WIRE_R
			WIRE_G:
				var neighbors_r:int = 0
				var neighbors_g:int = 0
				for off in iter_neighbor_moore:
					if map[y+off[0]][x+off[1]] == HEAD_R: neighbors_r += 1
					if map[y+off[0]][x+off[1]] == HEAD_G: neighbors_g += 1
				if   neighbors_g == 1: return HEAD_G
				elif neighbors_r == 1: return HEAD_G
				else: return WIRE_G
			WIRE_B:
				var neighbors_b:int = 0
				var neighbors_g:int = 0
				for off in iter_neighbor_moore:
					if map[y+off[0]][x+off[1]] == HEAD_B: neighbors_b += 1
					if map[y+off[0]][x+off[1]] == HEAD_G: neighbors_g += 1
				if   neighbors_b == 2: return HEAD_B
				elif neighbors_g == 1 and neighbors_b == 0: return HEAD_B #n_b==0 is important or it won't work.
				else: return WIRE_B
		return cell
	func soft_reset(map, x:int, y:int) -> int: #Turn all to wire.
		var cell = map[y][x]
		if cell == HEAD_R or cell == TAIL_R: return WIRE_R
		if cell == HEAD_G or cell == TAIL_G: return WIRE_G
		if cell == HEAD_B or cell == TAIL_B: return WIRE_B
		return cell
	func _to_string() -> String:
		return "Automaton: Wireworld_RGB"
