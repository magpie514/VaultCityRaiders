extends Panel
const AUTOMATA = preload("res://classes/automata/automata.gd").WireworldRGB

# Upgrade system for generators. Test version #################################
# This is a puzzle minigame using cellular automata and some pseudo-electronic
# components to upgrade generator parts for machines.
# Dubbed the ERAS in-game (Energy Routing Analysis System).
###############################################################################

const visual_data:Dictionary = {
	#Additional colors for visual effects.
	"HEAT": { color = Color("#FF2222") },
	"SPRK": { color = Color("#FFFFDD") },
}
const bg_color = Color(.0,.0,.0,.0)

# Cellular automata basics ####################################################
var automata    = null    #Stores the automaton class to use.
var cmap:Array  = core.newArray(2)
var cells:Array = cmap[0] #Cells is a pointer to current world. The worlds are swapped so memory use is under control.
var overlay:Array         #Graphical overlay for pasting, showing preview of lines, copy boundaries, etc.
var width:int   = 0
var height:int  = 0
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
enum { DRAW_PAINT, DRAW_ERASE, DRAW_LINE, DRAW_COPY, DRAW_PASTE }
var image_glow:Image               #A copy of all HEADs and TAILs which is then preprocessed for a nice glow.
var mouse_held:bool = false        #Mouse status. Makes drawing easier.
var brush:int       = 1            #Value to add when drawing. Can bypass palette choice using middle-click.
var palette:int     = 1            #Palette index to draw with.
var cursor:Vector2  = Vector2(0,0) #Cursor position.
var count:float     = 0.0          #Internal time count.
var draw_mode:int   = DRAW_PAINT
var line_start:Vector2 = Vector2(0,0)
# Clipboard ###################################################################
var clipboard:Array
# Precomputed nodes ###########################################################
onready var nodes = {
	parent = get_parent(),
	glows = $Display/Glow,
	stdout = $STDOUT,
	inputs = $INPUTS,
	outputs = $OUTPUTS,
	clipboard_img = $Clipboard,
	brush = $Brush,
	statusbar = $StatusBar,
	status_text = $StatusBar/Label,
	display = $Display,
	component_map = $INPUTS/Control,
}

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
	var automata     = null
	var id:int       = 0
	func init(_parent, pos:int, P:int) -> void:
		self.parent = _parent
		automata = parent.automata
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
	func take_click(event) -> void:
		pass
	func trigger_check(cycle) -> bool:
		return (cycle % period == 0) if overheat == 0 else false
	func reset() -> void:
		heat     = 0
		overheat = 0
	func _to_string() -> String:
		return "ERROR\n Base Component"

class I_Clock extends IO_Component:     #A clock. Emits a HEAD when triggered.
	func _init(parent, pos:int, P:int, val:int) -> void:
		id = 1
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

class IO_FastLane extends IO_Component:
	var units:Array
	func _init(parent, pos:int, P:int, val:int) -> void:
		id = 2
		init(parent, pos, 1)
		units = []
	func step() -> void:
		for i in units:
			var x:int = i[0]
			var y:int = i[1]
			var cell:int = parent.cells[y][x]
			if cell != automata.HEAD_R: continue
			var neighbors:int = 0
			var last:Array = core.newArray(2)
			for off in parent.automata.iter_neighbor_von_neumann:
				if parent.cells[y+off[0]][x+off[1]] == parent.automata.TAIL_R:
					neighbors += 1
					last = [x+off[1],y+off[0]]
			if neighbors == 1:
				print(last)
				print(x-last[0]," ", y-last[1])
				var init_xy = Vector2(x + ((x - last[0]) * 2), y + ((y - last[1]) * 2))
				var dest_x = core.clampi( x + ((x - last[0]) * 64), 0, parent.width)
				var dest_y = core.clampi( y + ((y - last[1]) * 64), 0, parent.height)
				var beam = parent.line_until(init_xy, Vector2(dest_x, dest_y), parent.automata.WIRE_R, parent.cells)
				if beam != null:
					parent.plot_line(init_xy, Vector2(beam[0], beam[1]), Color(.1,0,1, .5), parent.image_glow)
					parent.image_glow.set_pixel(beam[0], beam[1], parent.automata.visual_data[parent.automata.HEAD_R].color)
					parent.image_glow.set_pixel(x, y, parent.automata.visual_data[parent.automata.HEAD_R].color)
	func take_click(event) -> void:
		if event is InputEventMouseButton and event.pressed: #On button press.
			var x:int = round(event.position.x) as int
			var y:int = round(event.position.y) as int
			if event.button_index == BUTTON_LEFT:
				print(x, y)
				units.append([x, y])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = 1
				parent.nodes.component_map.update()
			if event.button_index == BUTTON_RIGHT:
				print(x, y)
				units.erase([x, y])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = 0
				parent.nodes.component_map.update()
	func _to_string() -> String:
		return str("FAST LANE\n")

class IO_GLinker extends IO_Component:
	var units:Array
	func _init(parent, pos:int, P:int, val:int) -> void:
		id = 2
		init(parent, pos, 1)
		units = []
	func step() -> void:
		var ok:bool = false
		for i in units:
			var x:int = i[0]
			var y:int = i[1]
			var cell:int = parent.cells[y][x]
			if cell == automata.HEAD_R:
				ok = true
				break
		if ok:
			for i in units:
				parent.cells[i[1]][i[0]] = automata.HEAD_R
				parent.image_glow.set_pixel(i[0], i[1], Color(0.05, 0.01, 0.55))
	func take_click(event) -> void:
		if event is InputEventMouseButton and event.pressed: #On button press.
			var x:int = round(event.position.x) as int
			var y:int = round(event.position.y) as int
			if event.button_index == BUTTON_LEFT:
				print(x, y)
				units.append([x, y])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = 1
				parent.nodes.component_map.update()
			if event.button_index == BUTTON_RIGHT:
				print(x, y)
				units.erase([x, y])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = 0
				parent.nodes.component_map.update()
	func _to_string() -> String:
		return str("G-Linker\n")


class I_BitStream extends IO_Component: #Emits arbitrary amount of bits, one bit per trigger, on a loop.
	var value:Array
	var count:int = 0
	var size:int = 4
	func _init(parent, pos:int, P:int, val:Array) -> void:
		id = 3
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

class I_Octet extends IO_Component:     #Emits 8-bit binary data, one bit per trigger, on a loop.
	var value:Array
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

class I_Nibble extends IO_Component:    #Emits 4-bit binary data, one bit per trigger, on a loop.
	var value:Array
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

class I_Random extends IO_Component:    #Emits a HEAD with a given chance, once per trigger.
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

class O_Output extends IO_Component:    #An output. Watches for a HEAD when triggered, and raises output if found.
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

class O_Value extends IO_Component:     #An output. Watches for a HEAD when triggered, and raises output if found.
	var energy:int = 0
	var value:Array
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

class O_Sound extends IO_Component:     #An output. Watches for a HEAD when triggered, and raises output if found.
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
func set_palette(index:int) -> void:
	palette = index
	brush = automata.palette[palette]
	nodes.brush.color = automata.visual_data[automata.palette[palette]].color
	nodes.brush.get_node("Label2").text = automata.visual_data[automata.palette[palette]].name

func set_color(index:int) -> void:
	brush = index
	nodes.brush.color = automata.visual_data[index].color
	nodes.brush.get_node("Label2").text = automata.visual_data[index].name

func init(_width:int, _height:int) -> void:
	#The ranges are precomputed, so no new arrays are generated by the simulation during run.
	#Components are another story but we don't really care as much there.
	width = _width
	height = _height
	rangex = range(1, _width)
	rangey = range(1, _height)

	automata = AUTOMATA.new() #AUTOMATA holds the class for the automaton.

	brush = automata.palette[1]
	set_palette(1)
	#Prepare the textures for drawing.
	image = Image.new();
	image_glow = Image.new()
	image.create(_width + 1, _height + 1, false, Image.FORMAT_RGBA8)
	image.fill(bg_color)
	image_glow.create(_width + 1, _height + 1, true, Image.FORMAT_RGBA8)
	nodes.display.texture = ImageTexture.new()
	nodes.glows.texture = ImageTexture.new()
	nodes.display.texture.create_from_image(image, 0)
	nodes.brush.get_node("Palette").init(automata)
	#Our "board" is nested arrays for cells. Stored in row, column order, so access with [y][x].
	cmap[0] = core.newArray(_height + 1)
	for i in range(cmap[0].size()):
		cmap[0][i] = PoolByteArray(core.newArray(_width + 1))
	cells = cmap[0] #Point cells to our new array. From now on cells is a pointer to the map.
	clear() # Clear the board here, so it's all fresh and initialized.
	cmap[1] = cmap[0].duplicate(true)
	copy(Vector2(0,0), Vector2(_width, _height)) #Set clipboard to the empty thing so it's initialized visually.
	$Display/Overlay.init(automata, _width, _height, cmap[0])
	overlay = cmap[0].duplicate(true)
	nodes.status_text.text = "Welcome to ERAS Dashboard, <PLAYER>. Control of <ITEM>: Granted" #Show a "hell no" message for the Hollow Engine.
	#Set some components.
	#TODO: Load them from generator data.
	if automata.name == "WireworldRGB":
		nodes.component_map.init(width, height)
		inputs  = IO_ComponentList.new(nodes.inputs , self)
		outputs = IO_ComponentList.new(nodes.outputs, self)
		inputs.add(I_Clock, 0, 3)
		inputs.add(I_Clock, 1, 4)
		inputs.add(I_Clock, 2, 5)
		inputs.add(I_Clock, 3, 6)
		inputs.add(I_Clock, 4, 7)
		inputs.add(IO_FastLane, 5, 3)
		inputs.add(I_Octet, 6, 6, 64)
		inputs.add(I_Nibble, 7, 6, 13)
		inputs.add(I_Random, 8, 6, 50)
		inputs.add(I_Octet, 9, 3, 89)
		inputs.add(IO_GLinker, 10, 0)
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
	nodes.display.texture.create_from_image(image, 0)
	nodes.glows.texture.create_from_image(image_glow)
	nodes.glows.update()
	update()

func clear(what:Array = cells) -> void: #Completely erase a board.
	for y in rangey:
		for x in rangex:
			what[y][x] = automata.palette[0]

func encode() -> String: #Encode the board for storage.
	#This is a pretty apathetic RLE compression.
	#It's not quite ideal but will do for now.
	var result:String = 'WW:'
	var _count:int = 0;
	var temp:int = 0
	for y in range(64):
		for x in range(65):
			var temp2:int = cells[y][x]
			if temp2 == temp: _count += 1
			else:
				result += "%s%d" % [ core.encode_base52[temp], _count ]
				temp = temp2
				_count = 0
	result +="%s%d" % [ core.encode_base52[temp], _count ] #Add remaining count at the end.
	return result

func decode(s:String) -> void: #Decode a saved string.
	clear()
	if s.begins_with('WW:'):
		s = s.substr(3)
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
			var cell:int = core.decode_base52[s.left(1)]
			var _count:int = int(s.substr(1))
			for __ in range(_count + 1):
				x = (pointer % 65) - 1
				y = (pointer / 65)
				cells[y][x] = cell
				pointer += 1
		#reset()
		nodes.stdout.text = str("Successfully loaded:\n", s)
	else:
		nodes.stdout.text = str("Invalid data:\n", s)
	image_update()

func reset() -> void: #Reset the board.
	#We don't really store original state.
	#Instead we just set every cell that isn't NULL to WIRE. We only care about the wires
	#for our purposes here.
	for y in rangey:
		for x in rangex:
			var cell = cells[y][x]
			if cell != 0:
				cells[y][x] = automata.soft_reset(cells, x, y)
	inputs.reset()
	outputs.reset()
	cycle  = 0
	output = 0
	image_update()

func step() -> void:  #Advance the simulation.
	var map = cells
	var ticks = OS.get_ticks_usec()
	cmap_swap() #Swap maps.
	image.lock();
	image_glow.fill(bg_color); #Reset glows before locking.
	image_glow.lock()
	for y in rangey:
		for x in rangex:
			if map[y][x] in automata.no_op:
				cells[y][x] = map[y][x]
			else:
				var res:int = automata.rules(map, x, y)
				cells[y][x] = res
				if res in automata.glow: image_glow.set_pixel(x, y, automata.visual_data[res].color)
				else: image.set_pixel(x, y, automata.visual_data[res].color)
	var ticks_cycle = OS.get_ticks_usec() - ticks
	$CycleTimer.text = str(ticks_cycle)
	cycle += 1
	#Component processing.
	inputs.step()
	outputs.step()
	#Display updating.
	var ticks_component = (OS.get_ticks_usec() - ticks) - ticks_cycle
	$CompTimer.text = str(ticks_component)
	image.unlock(); image_glow.unlock()
	nodes.display.texture.create_from_image(image, 0)
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

static func line(from:Vector2, to:Vector2, _brush:int, map:Array): #TODO: Move to core, might need it there.
	#Boilerplate Bresenham integer line plotting algorithm.
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(to.x) as int;   var y1:int = round(to.y) as int
	var delta_x:int = abs(x1 - x0) as int
	var delta_y:int = abs(y1 - y0) as int
	var sx:int = -1 if x0 > x1 else 1
	var sy:int = -1 if y0 > y1 else 1
	var err:int = ((delta_x if delta_x > delta_y else -delta_y) as float / 2.0) as int
	while true:
		map[y0][x0] = _brush
		if (x0 == x1 and y0 == y1): break
		var e2 = err
		if e2 > -delta_x:
			err -= delta_y; x0 += sx
		if e2 < delta_y:
			err += delta_x; y0 += sy

static func merge(from:Vector2, _brush:Array, map:Array, skip_zero:bool = true) -> void:
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(min(x0 + _brush[0].size(), 64)) as int
	var y1:int = round(min(y0 + _brush.size(), 64)) as int
	for y in range(y0, y1):
		for x in range(x0, x1):
			if skip_zero:
				map[y][x] = _brush[y-y0][x-x0] if _brush[y-y0][x-x0] != 0 else map[y][x]
			else:
				map[y][x] = _brush[y-y0][x-x0]

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

static func line_until(from:Vector2, to:Vector2, stop:int, map:Array): #TODO: Move to core, might need it there.
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(to.x) as int;   var y1:int = round(to.y) as int
	var delta_x:int = abs(x1 - x0) as int
	var delta_y:int = abs(y1 - y0) as int
	var sx:int = -1 if x0 > x1 else 1
	var sy:int = -1 if y0 > y1 else 1
	var err:int = ((delta_x if delta_x > delta_y else -delta_y) as float / 2.0) as int
	while true or map[y0][x0] == stop:
		if map[y0][x0] == stop:
			map[y0][x0] = 1;
			return [x0, y0]
		if (x0 == x1 and y0 == y1): break
		var e2 = err
		if e2 > -delta_x:
			err -= delta_y; x0 += sx
		if e2 < delta_y:
			err += delta_x; y0 += sy
	return null

func rotate(map:Array):
	var h:int = map.size()
	var w:int = map[0].size()
	var result:Array = core.newMatrix2D(h,w)
	for y in range(h):
		for x in range(w):
			result[x][w-1-y] = map[y][x]
	nodes.clipboard_img.init(automata, h, w, result)
	print("H:", h, " W:", w, " NH:", result.size(), " NW:", result[0].size())
	clipboard = result

func rectangle(from:Vector2, to:Vector2, _brush:int, map:Array):
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(to.x) as int;   var y1:int = round(to.y) as int
	var left = x0 if x0 < x1 else x1
	var top  = y0 if y0 < y1 else y1
	var delta_x:int = abs(x1 - x0) as int
	var delta_y:int = abs(y1 - y0) as int
	line(Vector2(left, top), Vector2(left+delta_x, top), _brush, map)
	line(Vector2(left, top), Vector2(left, top+delta_y), _brush, map)
	line(Vector2(left+delta_x, top), Vector2(left+delta_x, top+delta_y), _brush, map)
	line(Vector2(left+delta_x, top+delta_y), Vector2(left, top+delta_y), _brush, map)

func copy(from:Vector2, to:Vector2) -> void:
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(to.x) as int;   var y1:int = round(to.y) as int
	var left = x0 if x0 < x1 else x1
	var top  = y0 if y0 < y1 else y1
	var delta_x:int = abs(x1 - x0) as int + 1
	var delta_y:int = abs(y1 - y0) as int + 1
	print("Copy:", delta_x, ",", delta_y)
	var result:Array
	result.resize(delta_y)
	for y in range(delta_y):
		result[y] = []
		result[y].resize(delta_x)
		for x in range(delta_x):
			result[y][x] = cells[top+y][left+x]
	nodes.clipboard_img.init(automata, delta_x, delta_y, result)
	clipboard = result

# UI Signals ##################################################################

func _on_BClear_pressed() -> void: #Clear the entire board.
	cycle = 0
	output = 0
	clear()
	image_update()
	update()

func _on_BQuit_pressed() -> void: #Exit.
	#TODO: Actually go to the previous screen. This is just for debugging.
	core.changeScene("res://tests/debug_menu.tscn")

func _on_BSave_pressed() -> void: #Save board.
	nodes.stdout.text = encode()
	decode(encode())

func _on_BCopy_pressed() -> void: #Copy board to system clipboard.
	OS.clipboard = encode()

func _on_BPaste_pressed() -> void: #Paste board from system clipboard.
	decode(OS.clipboard)

func _on_BStep_pressed() -> void: #Advance simulation one step.
	step()
	update()

func _on_BPlayStop_pressed() -> void: #Start/Stop simulation.
	if is_processing():
		set_process(false)
		get_node("BPlayStop").text = 'PLAY'
		nodes.statusbar.color = Color("#280032")
		nodes.status_text.text = "Status: Stopped"
	else:
		set_process(true)
		get_node("BPlayStop").text = 'STOP'
		nodes.statusbar.color = Color("#282882")
		nodes.status_text.text = "Status: Test cycle"

func _on_BReset_pressed() -> void: #Remove all HEADs and TAILs, resetting the circuit.
	reset()
	update()

func _on_Display_gui_input(event:InputEvent) -> void:  #Interpret mouse input over the canvas.
	if event is InputEventMouseButton and event.pressed: #On button press.
		var x:int = round(event.position.x) as int
		var y:int = round(event.position.y) as int
		if event.button_index == BUTTON_LEFT and not event.control:
			if draw_mode == DRAW_PASTE:
				merge(event.position, clipboard, cells)
				draw_mode = DRAW_PAINT
				mouse_held = false
				image_update()
			else:
				mouse_held = true
				cells[y][x] = brush
				line_start = event.position
				image_update()
		elif event.button_index == BUTTON_RIGHT and not event.control:
			mouse_held = true
			draw_mode = DRAW_ERASE
			cells[y][x] = automata.palette[0]
			line_start = event.position
			image_update()
		elif event.button_index == BUTTON_WHEEL_UP:
			if draw_mode == DRAW_PASTE:
				rotate(clipboard)
			else:
				palette = (palette + 1) % automata.palette.size()
				if palette < 1: palette = 1
				set_palette(palette)
				return
		elif event.button_index == BUTTON_WHEEL_DOWN:
			palette = palette - 1
			if palette < 1: palette = automata.palette.size() - 1
			set_palette(palette)
		elif event.button_index == BUTTON_MIDDLE:
			set_color(cells[y][x])
		if event.shift:
			mouse_held = true
			line_start = event.position
			draw_mode = DRAW_LINE
		elif event.control:
			mouse_held = true
			line_start = event.position
			draw_mode = DRAW_COPY
	elif event is InputEventMouseButton and not event.pressed: #On button release.
		mouse_held = false
		clear(overlay)
		$Display/Overlay.image_update(overlay)
		match(draw_mode):
			DRAW_LINE:
				line(line_start, event.position, brush, cells)
				image_update()
			DRAW_COPY:
				copy(line_start, event.position)
				image_update()
		draw_mode = DRAW_PAINT
		nodes.display.update()
	elif event is InputEventMouseMotion: #On mouse movement.
		cursor = event.position
		if mouse_held:
			if draw_mode == DRAW_PAINT or draw_mode == DRAW_ERASE:
				var x:int = round(event.position.x) as int
				var y:int = round(event.position.y) as int
				if ((0 < x) and (x < 64)) and ((0 < y) and (y < 64)):
					cells[y][x] = brush if draw_mode == DRAW_PAINT else automata.palette[0]
				image_update()
			elif draw_mode == DRAW_LINE:
				clear(overlay)
				line(line_start, event.position, brush, overlay)
				$Display/Overlay.image_update(overlay)
			elif draw_mode == DRAW_COPY:
				clear(overlay)
				rectangle(line_start, event.position, 1, overlay)
				$Display/Overlay.image_update(overlay)
		else:
			if draw_mode == DRAW_PASTE:
				clear(overlay)
				merge(event.position, clipboard, overlay)
				$Display/Overlay.image_update(overlay)

		nodes.display.update()

func _on_Clipboard_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed: #On button press.
		var x:int = round(event.position.x) as int
		var y:int = round(event.position.y) as int
		if event.button_index == BUTTON_LEFT and not event.control:
			draw_mode = DRAW_PASTE
		elif event.button_index == BUTTON_WHEEL_UP:
			rotate(clipboard)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			pass
		elif event.button_index == BUTTON_MIDDLE:
			pass

