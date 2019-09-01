extends TextureRect

# Upgrade system for generators. Test version #################################
# This is a puzzle minigame using cellular automata and some pseudo-electronic
# components to upgrade generator parts for machines.
###############################################################################

const visual_data:Dictionary = {
	#Additional colors for visual effects.
	"HEAT": { color = Color("#FF2222") },
	"SPRK": { color = Color("#FFFFDD") },
}
const bg_color = Color(.0,.0,.0,.0)
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

# Cellular automata basics ####################################################
var automata    = null    #Stores the automaton class to use.
var cmap:Array  = core.newArray(2)
var cells:Array = cmap[0] #Cells is a pointer to current world. The worlds are swapped so memory use is under control.
var rangex:Array          #X iterator. They are precomputed so we minimize creation of new arrays.
var rangey:Array          #Y iterator. Same.
# Extra components
var inputs:IO_ComponentList  = null
var outputs:IO_ComponentList = null
# Statistics ##################################################################
var cycle:int = 0         #Internal timer
var output:int = 0        #Output
# Output texture ##############################################################
var image:Image
# UI/Editing related stuff ####################################################
enum { DRAW_PAINT, DRAW_LINE, DRAW_COPY }
var image_glow:Image               #A copy of all HEADs and TAILs which is then preprocessed for a nice glow.
var overlay:Image                  #Overlay for previews and other effects.
var mouse_held:bool = false        #Mouse status. Makes drawing easier.
var brush:int       = 1            #Value to add when drawing.
var palette:int     = 1            #Palette index to draw with.
var cursor:Vector2  = Vector2(0,0) #Cursor position.
var count:float     = 0.0          #Internal time count.
var draw_mode:int   = DRAW_PAINT
var line_start:Vector2 = Vector2(0,0)
# Clipboard ###################################################################
var clipboard:PoolByteArray
var clipboard_image:Image
# Precomputed nodes ###########################################################
onready var nodes = {
	parent = get_parent(),
	glows = $TextureRect,
	label = get_parent().get_node("STDOUT"),
	inputs = get_parent().get_node("INPUTS"),
	outputs = get_parent().get_node("OUTPUTS"),
	clipboard_img = get_parent().get_node("TextureRect"),
	brush = get_parent().get_node("BrushColor"),
	statusbar = get_parent().get_node("StatusBar"),
}


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
			TAIL_G: { color = Color("#94CE69"), name = "Green electron tail" },
			WIRE_B: { color = Color("#121083"), name = "Blue wire" },
			HEAD_B: { color = Color("#9090FF"), name = "Blue electron head" },
			TAIL_B: { color = Color("#6060DF"), name = "Blue electron tail" },
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
				elif neighbors_g == 1 and neighbors_b == 0: return HEAD_B
				else: return WIRE_B
		return cell
	func _to_string() -> String:
		return "Automaton: Wireworld_RGB"


# Component data ##############################################################
#   Components are additions over standard wireworld. While you should indeed be able to
# generate any components you need with standard wireworld rules, we are using boards of limited
# space. Components implement certain logic components in a more compact way.


class IO_ComponentList: #Basic holder.
	const SIZE = 16
	const COMPONENT_DISPLAY = preload("res://tests/Wireworld_Component.tscn")
	var list:Array
	var cnode:Control = null
	var parent = null
	func _init(n, _parent) -> void:
		list = core.valArray(null, SIZE)
		cnode = n
		parent = _parent
	func reset() -> void:
		for i in list:
			if i != null:
				i.component.reset()
				i.refresh(parent.cycle)
	func add(comp, pos:int, P:int, val = 0) -> void:
		var temp = COMPONENT_DISPLAY.instance()
		temp.component = comp.new(parent, pos, P, val)
		cnode.add_child(temp)
		temp.rect_position = Vector2(0, 40*pos)
		temp.rect_size = Vector2(90, 40)
		temp.text_set()
		list[pos] = temp
	func step() -> void:
		for i in list:
			if i != null:
				i.step(parent.cycle)

class IO_Component: #Base IO component.
	const MAX_HEAT       = 16
	const OVERHEAT_DELAY = 64
	const ROW_OUT    = 63
	const ROW_IN     = 1
	var heat:int     = 0
	var overheat:int = 0
	var period:int   = 6 setget set_period
	var IO_row:int   = 0
	var parent       = null
	func init(_parent, pos:int, P:int) -> void:
		self.parent = _parent
		heat = 0                #The "heat" of the component.
		#If HEADs backflow into inputs, or enter outputs at the wrong times, heat will go up.
		#If heat exceeds 16, the component will be disabled for 64 cycles.
		period = P              #The period at which the component operates.
		#When the period matches the internal cycle such as cycle % period == 0, it will "trigger".
		IO_row = (pos * 4) + 3  #Precalculate IO row.
	func set_period(val:int) -> void: #Keep period within certain values.
		if val < 3:    val = 3  #Wireworld automata "wires" don't allow a period lower than 3.
		elif val > 32: val = 32 #No real reason why 32, but at that point it should be too slow.
		period = val
	func heat_check(val:int) -> void:
		if overheat > 0:
			overheat -= 1
			if overheat == 0: heat = 0
		elif heat > MAX_HEAT:
			overheat = OVERHEAT_DELAY
	func trigger_check(cycle) -> bool:
		return (cycle % period == 0) if overheat == 0 else false
	func reset() -> void:
		heat     = 0
		overheat = 0
	func _to_string() -> String:
		return "ERROR\n Base Component"

class I_Clock extends IO_Component: #A clock. Emits a HEAD when triggered.
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(parent, pos, P)
		parent.cells[IO_row][1] = 3
	func step() -> void:
		if trigger_check(parent.cycle):
			parent.cells[IO_row][1] = 1
			parent.image_glow.set_pixel(1, IO_row, visual_data['SPRK'].color)
		else:
			if parent.cells[IO_row][1] == 1:
				heat += 1
				parent.image_glow.set_pixel(1, IO_row, visual_data['HEAT'].color)
		heat_check(parent.cycle)
	func _to_string() -> String:
		return str("PULSE\n")

class I_BitStream extends IO_Component: #Emits arbitrary amount of bits, one bit per trigger, on a loop.
	var value:PoolByteArray
	var count:int = 0
	var size:int = 4
	func _init(parent, pos:int, P:int, val:PoolByteArray) -> void:
		init(parent, pos, P)
		parent.cells[IO_row][1] = 3
		size = val.size()
		value.resize(size)
		for i in range(size):
			value[i] = val[i]
		reset()
	func step() -> void:
		if trigger_check(parent.cycle):
			if value[count] == 1:
				parent.cells[IO_row][1] = 1
				parent.image_glow.set_pixel(1, IO_row, visual_data['SPRK'].color)
			count = (count + 1) % size
		else:
			if parent.cells[IO_row][1] == 1: heat += 1
		heat_check(parent.cycle)
	func reset() -> void:
		count = 0
		.reset()
	func _to_string() -> String:
		return str("ROM\nS=", count)

class I_Octet extends IO_Component: #Emits 8-bit binary data, one bit per trigger, on a loop.
	var value:PoolByteArray
	var count:int = 0
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(parent, pos, P)
		parent.cells[IO_row][1] = 3
		value = core.itoba8(val)
		reset()
	func step() -> void:
		if trigger_check(parent.cycle):
			if value[count] == 1:
				parent.cells[IO_row][1] = 1
				parent.image_glow.set_pixel(1, IO_row, visual_data['SPRK'].color)
			count = (count + 1) % 8
		else:
			if parent.cells[IO_row][1] == 1: heat += 1
		heat_check(parent.cycle)
	func reset() -> void:
		count = 0
		.reset()
	func _to_string() -> String:
		return str(core.batos(value), "\nS=", count)

class I_Nibble extends IO_Component: #Emits 4-bit binary data, one bit per trigger, on a loop.
	var value:PoolByteArray
	var count:int = 0
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(parent, pos, P)
		parent.cells[IO_row][1] = 3
		value = core.itoba4(val)
		reset()
	func step() -> void:
		if trigger_check(parent.cycle):
			if value[count] == 1:
				parent.cells[IO_row][1] = 1
				parent.image_glow.set_pixel(1, IO_row, visual_data['SPRK'].color)
			count = (count + 1) % 4
		else:
			if parent.cells[IO_row][1] == 1: heat += 1
		heat_check(parent.cycle)
	func reset() -> void:
		count = 0
		.reset()
	func _to_string() -> String:
		return str(core.batos(value), "\nS=", count)

class I_Random extends IO_Component: #Emits a HEAD with a given chance, once per trigger.
	var value:int = 0
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(parent, pos, P)
		value = val
		parent.cells[IO_row][1] = 3
	func step() -> void:
		if trigger_check(parent.cycle):
			if core.chance(value):
				parent.cells[IO_row][1] = 1
				parent.image_glow.set_pixel(1, IO_row, visual_data['SPRK'].color)
		else:
			if parent.cells[IO_row][1] == 1: heat += 1
		heat_check(parent.cycle)
	func _to_string() -> String:
		return str("RANDOM\nV=", value)

class O_Output extends IO_Component: #An output. Watches for a HEAD when triggered, and raises output if found.
	var energy:int = 0
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(parent, pos, P)
		parent.cells[IO_row][63] = 3
		reset()
	func step() -> void:
		if trigger_check(parent.cycle):
			if parent.cells[IO_row][63] == 1:
				energy += 1
				parent.image_glow.set_pixel(63, IO_row, visual_data['SPRK'].color)
		else:
			if parent.cells[IO_row][63] == 1:
				heat += 1
				parent.image_glow.set_pixel(63, IO_row, visual_data['HEAT'].color)
		heat_check(parent.cycle)
	func reset() -> void:
		energy = 0
		.reset()
	func _to_string() -> String:
		return str("OUTPUT\nE=", energy)

class O_Value extends IO_Component: #An output. Watches for a HEAD when triggered, and raises output if found.
	var energy:int = 0
	var value:PoolByteArray
	func _init(parent, pos:int, P:int, val:Array) -> void:
		init(parent, pos, P)
		reset()
	func step() -> void:
		if trigger_check(parent.cycle):
			if parent.cells[IO_row][ROW_OUT] == 1:
				energy += 1
				parent.image_glow.set_pixel(63, IO_row, visual_data['SPRK'].color)
		else:
			if parent.cells[IO_row][ROW_OUT] == 1:
				heat += 1
				parent.image_glow.set_pixel(63, IO_row, visual_data['HEAT'].color)
		heat_check(parent.cycle)
	func reset() -> void:
		energy = 0
		parent.cells[IO_row][ROW_OUT] = 3
		.reset()
	func _to_string() -> String:
		return str("O.STREAM\nE=", energy)

class O_Sound extends IO_Component: #An output. Watches for a HEAD when triggered, and raises output if found.
	var pitch:float = 0
	var fx_channel:int = 0
	func _init(parent, pos:int, P:int, val:Array) -> void:
		init(parent, pos, 1)
		parent.cells[IO_row][63] = 3
		pitch = val[0] as float / 32.0
		fx_channel = val[1] % 4
		reset()
	func step() -> void:
		if parent.cells[IO_row][63] == 1:
			parent.get_node(str("Audio",fx_channel)).pitch_scale = pitch
			parent.get_node(str("Audio",fx_channel)).play()
			parent.image_glow.set_pixel(63, IO_row, Color(0,1,0,1.00))
			parent.image_glow.set_pixel(62, IO_row, Color(0,1,0,0.80))
			parent.image_glow.set_pixel(61, IO_row, Color(0,1,0,0.60))
			parent.image_glow.set_pixel(60, IO_row, Color(0,1,0,0.40))
			parent.image_glow.set_pixel(59, IO_row, Color(0,1,0,0.20))
	func _to_string() -> String:
		return str("AUDIO\nPITCH=", pitch)

#TODO: Unify the code for binary data emitters.

# Main functions ##############################################################
func set_palette(index:int):
	palette = index
	nodes.brush.color = automata.visual_data[automata.palette[palette]].color
	nodes.brush.get_node("Label2").text = automata.visual_data[automata.palette[palette]].name

func init(_width:int, _height:int) -> void:
	#The ranges are precomputed, so no new arrays are generated by the simulation during run.
	#Components are another story but we don't really care as much there.
	rangex = range(1, _width)
	rangey = range(1, _height)

	automata = WireworldRGB.new()
	brush = automata.palette[1]
	set_palette(1)
	#Prepare the textures for drawing.
	image = Image.new();
	image_glow = Image.new()
	image.create(_width + 1, _height + 1, false, Image.FORMAT_RGBA8)
	image.fill(bg_color)
	image_glow.create(_width + 1, _height + 1, true, Image.FORMAT_RGBA8)
	texture = ImageTexture.new()
	nodes.glows.texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	#nodes.clipboard_img.texture = ImageTexture.new()

	#Our "board" is nested arrays for cells. Stored in row, column order, so access with [y][x].
	cmap[0] = core.newArray(_height + 1)
	for i in range(cmap[0].size()):
		cmap[0][i] = PoolByteArray(core.newArray(_width + 1)) #PoolByteArray should be a bit more efficient.
	cells = cmap[0] #Point cells to our new array. From now on cells is a pointer to the map.
	clear() # Clear the board here, so it's all fresh and initialized.
	cmap[1] = cmap[0].duplicate(true)
	#Set some components.
	#TODO: Load them from generator data.
	inputs  = IO_ComponentList.new(nodes.inputs, self)
	outputs = IO_ComponentList.new(nodes.outputs, self)
	inputs.add(I_Clock, 0, 3)
	inputs.add(I_Clock, 1, 4)
	inputs.add(I_Clock, 2, 5)
	inputs.add(I_Clock, 3, 6)
	inputs.add(I_Clock, 4, 7)
	inputs.add(I_Clock, 5, 8)
	inputs.add(I_Octet, 6, 6, 64)
	inputs.add(I_Nibble, 7, 6, 13)
	inputs.add(I_Random, 8, 6, 50)
	inputs.add(I_Octet, 9, 3, 89)
	outputs.add(O_Output, 0, 6)
	outputs.add(O_Sound, 1, 6, [32,0])
	outputs.add(O_Sound, 2, 6, [16,1])
	outputs.add(O_Sound, 3, 6, [8,2])
	update()

func cmap_swap() -> void: #Swap our predefined arrays.
	cells = cmap[1] if cycle % 2 else cmap[0]

func image_update() -> void: #Redraw the board and glow textures.
	image.lock();
	image_glow.fill(bg_color); image_glow.lock()
	for y in rangey:
		for x in rangex:
			if cells[y][x] in automata.glow: image_glow.set_pixel(x, y, automata.visual_data[cells[y][x]].color)
			image.set_pixel(x, y, automata.visual_data[cells[y][x]].color)
	image.unlock(); image_glow.unlock()
	texture.create_from_image(image, 0)
	nodes.glows.texture.create_from_image(image_glow)
	nodes.glows.update()
	update()

func clear() -> void: #Completely erase the board.
	cycle = 0
	output = 0
	for y in rangey:
		for x in rangex:
			cells[y][x] = automata.palette[0]
	image_update()

func encode() -> String: #Encode the board for storage.
	#This is a pretty apathetic RLE compression.
	#It's not quite ideal but will do for now.
	var result:String = ''
	var _count:int = 0;
	var temp:int = 0
	for y in range(64):
		for x in range(65):
			var temp2:int = cells[y][x]
			if temp2 == temp: _count += 1
			else:
				result += "%s%d" % [ encode_base52[temp], _count ]
				temp = temp2
				_count = 0
	return result + str("%s%d" % [ encode_base52[temp], _count ]) #Add remaining count at the end.

func decode(s:String) -> void: #Decode a saved string.
	clear()
	var stream:Array = []
	var regex = RegEx.new()
	regex.compile('[a-zA-Z][0-9]+')
	var temp2 = regex.search_all(s)
	for a in temp2:
		stream.append(a.get_strings())
	var pointer = 0 #0,0
	var x:int = 0; var y:int = 0
	for i in stream:
		s = i[0]
		var cell:int = decode_base52[s.left(1)]
		var _count:int = int(s.substr(1))
		for __ in range(_count + 1):
			x = (pointer % 65) - 1
			y = (pointer / 65)
			cells[y][x] = cell
			pointer += 1
	#reset()
	image_update()

func reset() -> void: #Reset the board.
	#We don't really store original state.
	#Instead we just set every cell that isn't NULL to WIRE. We only care about the wires
	#for our purposes here.
	for y in rangey:
		for x in rangex:
			var cell = cells[y][x]
			if cell != 0:
				cells[y][x] = 1
	inputs.reset()
	outputs.reset()
	cycle  = 0
	output = 0
	image_update()

func step() -> void:
	var map = self.cells
	cmap_swap() #Swap maps.
	image.lock();
	image_glow.fill(bg_color); image_glow.lock()
	for y in rangey:
		for x in rangex:
			cells[y][x] = automata.rules(map, x, y)
			image.set_pixel(x, y, automata.visual_data[cells[y][x]].color)
			if cells[y][x] in automata.glow: image_glow.set_pixel(x, y, automata.visual_data[cells[y][x]].color)
	cycle += 1
	#Component processing.
	inputs.step()
	outputs.step()
	#Display updating.
	image.unlock(); image_glow.unlock()
	texture.create_from_image(image, 0)
	nodes.glows.texture.create_from_image(image_glow)
	nodes.glows.update()

func _ready() -> void:
	init(64, 64)
	set_process(false)
	image_update()

func _process(delta: float) -> void:
	count += delta
	if count > 0.10:
		count = 0
		step()

func _draw() -> void: #Draw a cursor. It's more precise this way.
	draw_rect(Rect2(Vector2(round(cursor.x), round(cursor.y)), Vector2(1,1)), visual_data['SPRK'].color, false)
	if mouse_held and draw_mode == DRAW_LINE:
		draw_line(line_start, Vector2(cursor.x, cursor.y), Color(1,1,1,.5), 1.1, true)

func line(from:Vector2, to:Vector2, _brush:int):
	#Boilerplate Bresenham integer line plotting algorithm.
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(to.x) as int;   var y1:int = round(to.y) as int
	var delta_x:int = abs(x1 - x0) as int
	var delta_y:int = abs(y1 - y0) as int
	var sx:int = -1 if x0 > x1 else 1
	var sy:int = -1 if y0 > y1 else 1
	var err:int = ((delta_x if delta_x > delta_y else -delta_y) as float / 2.0) as int
	while true:
		cells[y0][x0] = _brush
		if (x0 == x1 and y0 == y1): break
		var e2 = err
		if e2 > -delta_x:
			err -= delta_y; x0 += sx
		if e2 < delta_y:
			err += delta_x; y0 += sy

func copy(from:Vector2, to:Vector2) -> void:
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(to.x) as int;   var y1:int = round(to.y) as int
	var left = x0 if x0 < x1 else x1
	var top  = y0 if y0 < y1 else y1
	var delta_x:int = abs(x1 - x0) as int + 1
	var delta_y:int = abs(y1 - y0) as int + 1
	var result:Array
	result.resize(delta_y)
	clipboard_image = Image.new()
	clipboard_image.create(delta_x, delta_y, false, Image.FORMAT_RGBA8)
	clipboard_image.lock()
	for y in range(delta_y):
		result[y] = PoolByteArray()
		result[y].resize(delta_x)
		for x in range(delta_x):
			var tmp:int = cells[top+y][left+x]
			result[y].append(tmp)
			clipboard_image.set_pixel(x, y, automata.visual_data[tmp].color)
	clipboard_image.unlock()
	nodes.clipboard_img.texture.create_from_image(clipboard_image, 0)
	nodes.clipboard_img.update()

func _on_Control_gui_input(event:InputEvent) -> void: #Interpret mouse input over the canvas.
	if event is InputEventMouseButton and event.pressed:
		var x:int = round(event.position.x) as int
		var y:int = round(event.position.y) as int
		if event.button_index == BUTTON_LEFT:
			brush = automata.palette[palette]
			mouse_held = true
			cells[y][x] = brush
			line_start = event.position
			image_update()
		elif event.button_index == BUTTON_RIGHT:
			brush = automata.palette[0]
			mouse_held = true
			cells[y][x] = brush
			line_start = event.position
			image_update()
		elif event.button_index == BUTTON_WHEEL_UP:
			palette = (palette + 1) % automata.palette.size()
			if palette < 1: palette = 1
			set_palette(palette)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			set_palette(1)
		if event.shift: draw_mode = DRAW_LINE
		elif event.control: draw_mode = DRAW_COPY
	elif event is InputEventMouseButton and not event.pressed:
		mouse_held = false
		if draw_mode == DRAW_LINE:
			line(line_start, event.position, brush)
		if draw_mode == DRAW_COPY:
			copy(line_start, event.position)
		draw_mode = DRAW_PAINT
		image_update()
	elif event is InputEventMouseMotion:
		cursor = event.position
		if mouse_held and draw_mode == DRAW_PAINT:
			var x:int = round(event.position.x) as int
			var y:int = round(event.position.y) as int
			if ((0 < x) and (x < 64)) and ((0 < y) and (y < 64)):
				cells[y][x] = brush
			image_update()
		update()

func _on_Button_pressed() -> void: #Advance simulation one step.
	step()
	update()

func _on_Button2_pressed() -> void: #Start/Stop simulation.
	if is_processing():
		set_process(false)
		get_parent().get_node("BPlayStop").text = 'PLAY'
	else:
		set_process(true)
		get_parent().get_node("BPlayStop").text = 'STOP'

func _on_Button3_pressed() -> void: #Remove all HEADs and TAILs, resetting the circuit.
	reset()
	update()

func _on_BClear_pressed() -> void: #Remove all HEADs, TAILs and WIREs, deleting the entire board.
	clear()
	update()

func _on_BQuit_pressed() -> void: #Exit.
	#TODO: Actually go to the previous screen. This is just for debugging.
	core.changeScene("res://tests/debug_menu.tscn")

func _on_BSave_pressed() -> void: #Save board.
	nodes.label.text = encode()
	decode(encode())
