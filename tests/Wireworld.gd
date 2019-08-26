extends TextureRect

# Upgrade system for generators, Wireworld test version #######################
# This is a basic implementation of the cellular automaton "Wireworld" by
# Brian Silverman circa 1987.
# It's a simple automaton that effectively simulates a simplistic electronic
# circuit. Additional "components" are also available, to reduce the amount
# of space required to make a successful circuit and to provide outputs that
# can be linked to stats for a given generator.
# It's supposed to be a relatively difficult logic puzzle.
# More information about Wireworld:
# https://en.wikipedia.org/wiki/Wireworld
# https://web.archive.org/web/20100526042019if_/http://karl.kiwi.gen.nz/CA-Wireworld.html
###############################################################################

enum { NULL=0, HEAD=1, TAIL=2, WIRE=3 }
const wiredata:Dictionary = {
	NULL: { color = Color("#00000000") },
	WIRE: { color = Color("#433300") },
	HEAD: { color = Color("#C4DBFF") },
	TAIL: { color = Color("#1E4E99") },
	#Additional colors for visual effects.
	"HEAT": { color = Color("#FF2222") },
	"SPRK": { color = Color("#FFFFDD") },
}

const iter_neighbor = [
	[-1,-1], [-1, 0], [-1, 1],
	[ 0,-1],          [ 0, 1],
	[ 1,-1], [ 1, 0], [ 1, 1]
]
const null_color = Color(.0,.0,.0,.0)

# Wireworld maps
var cmap:Array = core.newArray(2)
var cells:Array = cmap[0] #Cells is a pointer to current world. The worlds are swapped so memory use is under control.
var rangex:Array          #X iterator. They are precomputed so we minimize creation of new arrays.
var rangey:Array          #Y iterator. Same.

# Statistics ##################################################################
var cycle:int = 0         #Internal timer
var HEADs:int = 0         #Count of HEADs per turn.
var output:int = 0        #Output

# Output texture ##############################################################
var image:Image

# UI/Editing related stuff ####################################################
var image_glow:Image              #A copy of all HEADs and TAILs which is then preprocessed for a nice glow.
var mouse_held:bool = false       #Mouse status. Makes drawing easier.
var brush:int = WIRE              #Value to add when drawing.
var cursor:Vector2 = Vector2(0,0) #Cursor position.
var count:float = 0.0             #Internal time count.

# Precomputed nodes ###########################################################
onready var nodes = {
	parent = get_parent(),
	glows = $TextureRect,
	label = get_parent().get_node("STDOUT"),
	inputs = get_parent().get_node("INPUTS"),
	outputs = get_parent().get_node("OUTPUTS"),
}

# Component data ##############################################################
#   Components are additions over standard wireworld. While you should indeed be able to
# generate any components you need with standard wireworld rules, we are using boards of limited
# space. Components implement certain logic components in a more compact way.
var inputs:IO_ComponentList  = null
var outputs:IO_ComponentList = null

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
		temp.text = str(temp.component)
		cnode.add_child(temp)
		temp.rect_position = Vector2(0, 40*pos)
		temp.rect_size = Vector2(90, 40)
		list[pos] = temp
	func step() -> void:
		for i in list:
			if i != null:
				i.step(parent.cycle, parent)

class IO_Component: #Base IO component.
	var heat:int     = 0
	var overheat:int = 0
	var period:int   = 6 setget set_period
	var IO_row:int   = 0
	const MAX_HEAT       = 16
	const OVERHEAT_DELAY = 64
	func init(pos:int, P:int) -> void:
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
		#elif heat > 0 and parent.cycle % 2 == 0:
		#	heat -= 1
	func trigger_check(cycle) -> bool:
		return (cycle % period == 0) if overheat == 0 else false
	func reset() -> void:
		heat     = 0
		overheat = 0
	func _to_string() -> String:
		return "ERROR: Base Component"

class I_Clock extends IO_Component: #A clock. Emits a HEAD when triggered.
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(pos, P)
		parent.cells[IO_row][1] = WIRE
	func step(parent) -> void:
		if trigger_check(parent.cycle):
			parent.cells[IO_row][1] = HEAD
			parent.image_glow.set_pixel(1, IO_row, wiredata['SPRK'].color)
		else:
			if parent.cells[IO_row][1] == HEAD:
				heat += 1
				parent.image_glow.set_pixel(1, IO_row, wiredata['HEAT'].color)
		heat_check(parent.cycle)
	func _to_string() -> String:
		return str("INPUT\nP=",period," H=", heat)

class I_Octet extends IO_Component: #Emits 8-bit binary data, one bit per trigger, on a loop.
	var value:PoolByteArray
	var count:int = 0
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(pos, P)
		parent.cells[IO_row][1] = WIRE
		value = core.itoba8(val)
		reset()
	func step(parent) -> void:
		if trigger_check(parent.cycle):
			if value[count] == 1:
				parent.cells[IO_row][1] = HEAD
				parent.image_glow.set_pixel(1, IO_row, wiredata[HEAD].color)
			count = (count + 1) % 8
		else:
			if parent.cells[IO_row][1] == HEAD: heat += 1
		heat_check(parent.cycle)
	func reset() -> void:
		count = 0
		.reset()
	func _to_string() -> String:
		return str("OCTET ", core.batos(value), "\nP=", period, " S=", count)

class I_Nibble extends IO_Component: #Emits 4-bit binary data, one bit per trigger, on a loop.
	var value:PoolByteArray
	var count:int = 0
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(pos, P)
		parent.cells[IO_row][1] = WIRE
		value = core.itoba4(val)
		reset()
	func step(parent) -> void:
		if trigger_check(parent.cycle):
			if value[count] == 1:
				parent.cells[IO_row][1] = HEAD
				parent.image_glow.set_pixel(1, IO_row, wiredata[HEAD].color)
			count = (count + 1) % 4
		else:
			if parent.cells[IO_row][1] == HEAD: heat += 1
		heat_check(parent.cycle)
	func reset() -> void:
		count = 0
		.reset()
	func _to_string() -> String:
		return str("NIBB ", core.batos(value), "\nP=", period, " S=", count)

class I_Random extends IO_Component: #Emits a HEAD with a given chance, once per trigger.
	var value:int = 0
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(pos, P)
		value = val
		parent.cells[IO_row][1] = WIRE
	func step(parent) -> void:
		if trigger_check(parent.cycle):
			if core.chance(value):
				parent.cells[IO_row][1] = HEAD
				parent.image_glow.set_pixel(1, IO_row, wiredata[HEAD].color)
		else:
			if parent.cells[IO_row][1] == HEAD: heat += 1
		heat_check(parent.cycle)
	func _to_string() -> String:
		return str("RANDOM\nP=",period," V=", value)

class O_Output extends IO_Component: #An output. Watches for a HEAD when triggered, and raises output if found.
	var energy:int = 0
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(pos, P)
		parent.cells[IO_row][63] = WIRE
		reset()
	func step(parent) -> void:
		if trigger_check(parent.cycle):
			if parent.cells[IO_row][63] == HEAD:
				energy += 1
				parent.image_glow.set_pixel(63, IO_row, wiredata['SPRK'].color)
		else:
			if parent.cells[IO_row][63] == HEAD:
				heat += 1
				parent.image_glow.set_pixel(63, IO_row, wiredata['HEAT'].color)
		heat_check(parent.cycle)
	func reset() -> void:
		energy = 0
		.reset()
	func _to_string() -> String:
		return str("OUTPUT\nP=",period," H=", heat, " E=", energy)

class O_Value extends IO_Component: #An output. Watches for a HEAD when triggered, and raises output if found.
	var energy:int = 0
	func _init(parent, pos:int, P:int, val:int) -> void:
		init(pos, P)
		parent.cells[IO_row][63] = WIRE
		reset()
	func step(parent) -> void:
		if trigger_check(parent.cycle):
			if parent.cells[IO_row][63] == HEAD:
				energy += 1
				parent.image_glow.set_pixel(63, IO_row, wiredata['SPRK'].color)
		else:
			if parent.cells[IO_row][63] == HEAD:
				heat += 1
				parent.image_glow.set_pixel(63, IO_row, wiredata['HEAT'].color)
		heat_check(parent.cycle)
	func reset() -> void:
		energy = 0
		.reset()
	func _to_string() -> String:
		return str("O.STREAM\nP=",period," H=", heat, " E=", energy)

class O_Sound extends IO_Component: #An output. Watches for a HEAD when triggered, and raises output if found.
	var pitch:float = 0
	var fx_channel:int = 0
	func _init(parent, pos:int, P:int, val:Array) -> void:
		init(pos, 1)
		parent.cells[IO_row][63] = WIRE
		pitch = val[0] as float / 32.0
		fx_channel = val[1] % 4
		reset()
	func step(parent) -> void:
		if parent.cells[IO_row][63] == HEAD:
			parent.get_node(str("Audio",fx_channel)).pitch_scale = pitch
			parent.get_node(str("Audio",fx_channel)).play()
			parent.image_glow.set_pixel(63, IO_row, Color(0,1,0,1.00))
			parent.image_glow.set_pixel(62, IO_row, Color(0,1,0,0.80))
			parent.image_glow.set_pixel(61, IO_row, Color(0,1,0,0.60))
			parent.image_glow.set_pixel(60, IO_row, Color(0,1,0,0.40))
			parent.image_glow.set_pixel(59, IO_row, Color(0,1,0,0.20))
	func _to_string() -> String:
		return str("AUDIO\nP=",period, " PITCH=", pitch)

#TODO: Unify the code for binary data emitters.

# Main functions ##############################################################

func init(_width:int, _height:int) -> void:
	#The ranges are precomputed, so no new arrays are generated by the simulation during run.
	#Components are another story but we don't really care as much there.
	rangex = range(1, _width)
	rangey = range(1, _height)

	#Prepare the textures for drawing.
	image = Image.new();
	image_glow = Image.new()
	image.create(_width + 1, _height + 1, false, Image.FORMAT_RGBA8)
	image.fill(null_color)
	image_glow.create(_width + 1, _height + 1, true, Image.FORMAT_RGBA8)
	texture = ImageTexture.new()
	nodes.glows.texture = ImageTexture.new()
	texture.create_from_image(image, 0)

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
	outputs.add(O_Output, 0, 6)
	outputs.add(O_Sound, 1, 6, [32,0])
	outputs.add(O_Sound, 2, 6, [16,1])
	outputs.add(O_Sound, 3, 6, [8,2])
	update()

func cmap_swap() -> void: #Swap our predefined arrays.
	cells = cmap[1] if cycle % 2 else cmap[0]

func image_update() -> void: #Redraw the board and glow textures.
	image.lock();
	image_glow.fill(null_color); image_glow.lock()
	for y in rangey:
		for x in rangex:
			if cells[y][x] == HEAD or cells[y][x] == TAIL:
				if cells[y][x] == HEAD: HEADs += 1
				image_glow.set_pixel(x, y, wiredata[cells[y][x]].color)
			image.set_pixel(x, y, wiredata[cells[y][x]].color)
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
			cells[y][x] = NULL
	image_update()

func reset() -> void: #Reset the board.
	#We don't really store original state.
	#Instead we just set every cell that isn't NULL to WIRE. We only care about the wires
	#for our purposes here.
	for y in rangey:
		for x in rangex:
			var cell = cells[y][x]
			if cell != NULL:
				cells[y][x] = WIRE
	inputs.reset()
	outputs.reset()
	image_update()

func rules(map, x, y) -> int: #Wireworld automaton rules.
	var cell = map[y][x]
	match cell:
		HEAD: return TAIL
		TAIL: return WIRE
		WIRE:
			var neighbors = 0
			for off in iter_neighbor: neighbors += 1 if map[y+off[0]][x+off[1]] == HEAD else 0
			return HEAD if neighbors == 1 or neighbors == 2 else WIRE
	return cell

func step() -> void:
	var map = self.cells
	cmap_swap() #Swap maps.
	image.lock();
	image_glow.fill(null_color); image_glow.lock()

	HEADs = 0
	for y in rangey:
		for x in rangex:
			cells[y][x] = rules(map, x, y)
			if cells[y][x] == HEAD or cells[y][x] == TAIL:
				if cells[y][x] == HEAD: HEADs += 1
				image_glow.set_pixel(x, y, wiredata[cells[y][x]].color)
			if cells[y][x] == WIRE: image.set_pixel(x, y, wiredata[cells[y][x]].color)
	cycle += 1
	#Component processing.
	inputs.step()
	outputs.step()
	#Display updating.
	image.unlock(); image_glow.unlock()
	texture.create_from_image(image, 0)
	nodes.glows.texture.create_from_image(image_glow)
	nodes.glows.update()
	nodes.label.bbcode_text = "Cycle: %.05d, Generator Period: %0.2d, Heads: %0.4d, Output: %0.5d" % [cycle, 6, HEADs, output]

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
	draw_rect(Rect2(Vector2(round(cursor.x), round(cursor.y)), Vector2(1,1)), wiredata['SPRK'].color, false)

func _on_Control_gui_input(event:InputEvent) -> void: #Interpret mouse input over the canvas.
	if event is InputEventMouseButton and event.pressed:
		var x:int = round(event.position.x) as int
		var y:int = round(event.position.y) as int
		if event.button_index == BUTTON_LEFT:
			brush = WIRE
		elif event.button_index == BUTTON_RIGHT:
			brush = NULL
		cells[y][x] = brush
		mouse_held = true
		image_update()
	elif event is InputEventMouseButton and not event.pressed:
		mouse_held = false
	elif event is InputEventMouseMotion:
		cursor = event.position
		if mouse_held:
			var x:int = round(event.position.x) as int
			var y:int = round(event.position.y) as int
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
