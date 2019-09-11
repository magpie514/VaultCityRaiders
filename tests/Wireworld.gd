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
	"WARP": { color = Color(0.05, 0.01, 0.55) },
}
const bg_color = Color(.0,.0,.0,.0)

# Cellular automata basics ####################################################
var automata    = null    #Stores the automaton class to use.
var overlay:Array         #Graphical overlay for pasting, showing preview of lines, copy boundaries, etc.
var width:int   = 0
var height:int  = 0
# Extra components
var inputs:IO_ComponentList   = null
var outputs:IO_ComponentList  = null
var controls:IO_ComponentList = null
# Statistics ##################################################################
var cycle:int = 0         #Internal timer
var output:int = 0        #Output
# Output texture ##############################################################
var image:Image = Image.new()
# UI/Editing related stuff ####################################################
enum { DRAW_PAINT, DRAW_ERASE, DRAW_LINE, DRAW_COPY, DRAW_PASTE }
var image_glow:Image = Image.new() #A copy of all HEADs and TAILs which is then preprocessed for a nice glow.
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
	controls = $CONTROLS,
	outputs = $OUTPUTS,
	clipboard_img = $Clipboard,
	brush = $Brush,
	statusbar = $StatusBar,
	status_text = $StatusBar/Label,
	display = $Display,
	component_map = $CONTROLS/Control,
}

# Component data ##############################################################
#   Components are additions over standard wireworld. While you should indeed be able to
# generate any components you need with standard wireworld rules, we are using boards of limited
# space. Components implement certain logic components in a more compact way.
class IO_ComponentList: #Basic holder.
	enum { TYPE_IO, TYPE_I, TYPE_O }
	const SIZE = 16
	const COMPONENT_DISPLAY_I = preload("res://tests/ERAS_chip_I.tscn")
	const COMPONENT_DISPLAY_O = preload("res://tests/ERAS_chip_O.tscn")
	const COMPONENT_DISPLAY_C = preload("res://tests/ERAS_chip_C.tscn")
	var list:Array
	var cnode:Control = null
	var parent = null
	var type = COMPONENT_DISPLAY_C
	func _init(n, _parent, _type) -> void:
		list = core.valArray(null, SIZE)
		match _type:
			TYPE_IO: type = COMPONENT_DISPLAY_C
			TYPE_I:  type = COMPONENT_DISPLAY_I
			TYPE_O:  type = COMPONENT_DISPLAY_O

		cnode = n
		parent = _parent
	func reset() -> void:
		for i in list:
			if i != null:
				i.component.reset()
				i.refresh(parent.cycle)
	func clear() -> void:
		for i in list:
			if i != null:
				i.component.clear()
				i.refresh(parent.cycle)
	func add(comp, pos:int, P:int, val = 0) -> void:
		var temp = type.instance()
		temp.component = comp.new(parent, temp, pos, P, val)
		temp.parent    = parent
		cnode.add_child(temp)
		temp.rect_position = Vector2(0, 40*pos)
		temp.rect_size     = Vector2(90, 40)
		temp.text_set()
		list[pos] = temp
		temp.component.node = temp
	func step() -> void:
		for i in list:
			if i != null:
				i.step(parent.cycle)

class IO_Component:                     #Base IO component.
	enum { TYPE_IO, TYPE_I, TYPE_O }
	const MAX_HEAT       = 8
	const OVERHEAT_DELAY = 64
	const ROW_OUT    = 63
	const ROW_IN     = 1
	var heat:int     = 0
	var overheat:int = 0
	var period:int   = 6 setget set_period
	var IO_row:int   = 0
	var parent       = null
	var automata     = null
	var id:String    = "NULL"
	var type:int     = TYPE_IO
	var node         = null
	func init(_parent, N, pos:int, P:int) -> void:
		node = N
		parent = _parent
		automata = parent.automata
		heat = 0                #The "heat" of the component.
		#If HEADs backflow into inputs, or enter outputs at the wrong times, heat will go up.
		#If heat exceeds 8, the component will be disabled for 64 cycles.
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
		parent.nodes.display.disconnect("gui_input", self, "take_click")
	func trigger_check(cycle) -> bool:
		return (cycle % period == 0) if overheat == 0 else false
	func reset() -> void:
		heat     = 0
		overheat = 0
		node.refresh(0)
	func clear() -> void:
		reset()
	func output() -> String:
		return ""
	func _to_string() -> String:
		return str(id, " ", output())

class IO_Delayer  extends IO_Component: #Fast lane. Emits a beam that collides with a wire to transfer a HEAD.
	var units:Array
	func _init(parent, N, pos:int, P:int, val:int) -> void:
		id = "Fast Lane"
		type = TYPE_IO
		init(parent, N, pos, 1)
		units = []
	func step() -> void:
		for i in units:
			var x:int = i[0]; var y:int = i[1]
			var cell:int = parent.automata.core.cell_get(x, y)
			if cell != automata.HEAD_R: continue
			var neighbors:int = 0
			var last:Array = core.newArray(2)
			for off in parent.automata.iter_neighbor_von_neumann:
				if parent.automata.core.cell_get(x+off[1], y+off[0]) == parent.automata.TAIL_R:
					neighbors += 1
					last = [x+off[1],y+off[0]]
			if neighbors == 1:
				var init_x = x + ((x - last[0]) * 2)
				var init_y = y + ((y - last[1]) * 2)
				var dest_x = core.clampi( x + ((x - last[0]) * 64), 0, parent.width)
				var dest_y = core.clampi( y + ((y - last[1]) * 64), 0, parent.height)
				var beam = parent.automata.core.line_until(init_x, init_y, dest_x, dest_y, parent.automata.HEAD_R, parent.automata.WIRE_R)
				if beam.x > 0 and beam.y > 0:
					core.plot_line(Vector2(init_x, init_y), Vector2(beam[0], beam[1]), Color(.1,0,1, .5), parent.image_glow)
					parent.image_glow.set_pixel(beam[0], beam[1], parent.automata.visual_data[parent.automata.HEAD_R].color)
					parent.image_glow.set_pixel(x, y, parent.automata.visual_data[parent.automata.HEAD_R].color)
	func take_click(event) -> void:
		if event is InputEventMouseButton and event.pressed and parent.cycle == 0: #On button press.
			var x:int = round(event.position.x) as int
			var y:int = round(event.position.y) as int
			if event.button_index == BUTTON_LEFT:
				units.append([x, y])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = 1
				parent.nodes.component_map.update()
			elif event.button_index == BUTTON_RIGHT:
				units.erase([x, y])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = 0
				parent.nodes.component_map.update()
	func reset() -> void:
		for i in units:
			parent.automata.core.cell_set(i[0], i[1], automata.WIRE_R)
		.reset()
	func clear() -> void:
		for i in units:
			parent.nodes.component_map.map[i[1]][i[0] - 1] = 0
		parent.nodes.component_map.update()
		units.clear()
		.clear()


class IO_FastLane extends IO_Component: #Fast lane. Emits a beam that collides with a wire to transfer a HEAD.
	var units:Array
	func _init(parent, N, pos:int, P:int, val:int) -> void:
		id = "Fast Lane"
		type = TYPE_IO
		init(parent, N, pos, 1)
		units = []
	func step() -> void:
		for i in units:
			var x:int = i[0]; var y:int = i[1]
			var cell:int = parent.automata.core.cell_get(x, y)
			if cell != automata.HEAD_R: continue
			var neighbors:int = 0
			var last:Array = core.newArray(2)
			for off in parent.automata.iter_neighbor_von_neumann:
				if parent.automata.core.cell_get(x+off[1], y+off[0]) == parent.automata.TAIL_R:
					neighbors += 1
					last = [x+off[1],y+off[0]]
			if neighbors == 1:
				var init_x = x + ((x - last[0]) * 2)
				var init_y = y + ((y - last[1]) * 2)
				var dest_x = core.clampi( x + ((x - last[0]) * 64), 0, parent.width)
				var dest_y = core.clampi( y + ((y - last[1]) * 64), 0, parent.height)
				var beam = parent.automata.core.line_until(init_x, init_y, dest_x, dest_y, parent.automata.HEAD_R, parent.automata.WIRE_R)
				if beam.x > 0 and beam.y > 0:
					core.plot_line(Vector2(init_x, init_y), Vector2(beam[0], beam[1]), Color(.1,0,1, .5), parent.image_glow)
					parent.image_glow.set_pixel(beam[0], beam[1], parent.automata.visual_data[parent.automata.HEAD_R].color)
					parent.image_glow.set_pixel(x, y, parent.automata.visual_data[parent.automata.HEAD_R].color)
	func take_click(event) -> void:
		if event is InputEventMouseButton and event.pressed and parent.cycle == 0: #On button press.
			var x:int = round(event.position.x) as int
			var y:int = round(event.position.y) as int
			if event.button_index == BUTTON_LEFT:
				units.append([x, y])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = 1
				parent.nodes.component_map.update()
			elif event.button_index == BUTTON_RIGHT:
				units.erase([x, y])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = 0
				parent.nodes.component_map.update()
	func reset() -> void:
		for i in units:
			parent.automata.core.cell_set(i[0], i[1], automata.WIRE_R)
		.reset()
	func clear() -> void:
		for i in units:
			parent.nodes.component_map.map[i[1]][i[0] - 1] = 0
		parent.nodes.component_map.update()
		units.clear()
		.clear()

class IO_Soup     extends IO_Component: #????. Generates a random "soup" with random palette values.
	var units:Array
	func _init(parent, N, pos:int, P:int, val:int) -> void:
		id = "????"
		type = TYPE_IO
		init(parent, N, pos, 1)
	func step() -> void:
		for i in units:
			var x:int = i[0]; var y:int = i[1]
			var cell:int = parent.automata.core.cell_get(x, y)
			if cell != automata.HEAD_R: continue
			if i[2] > 0:
				i[2] -= 1
				if i[2] == 0:
					parent.automata.core.cell_set(x, y, automata.NULL)
	func take_click(event) -> void:
		if event is InputEventMouseButton and event.pressed: #On button press.
			parent.nodes.display.disconnect("gui_input", self, "take_click")
			if event.button_index == BUTTON_LEFT:
				parent.automata.core.random(9)
				parent.image_update()

class IO_Fuse     extends IO_Component: #Fuse. Breaks after a HEAD passes through it.
	var units:Array
	func _init(parent, N, pos:int, P:int, val:int) -> void:
		id = "Fuse"
		type = TYPE_IO
		init(parent, N, pos, 1)
		units = []
	func step() -> void:
		for i in units:
			var x:int = i[0]; var y:int = i[1]
			var cell:int = parent.automata.core.cell_get(x, y)
			if cell != automata.HEAD_R: continue
			if i[2] > 0:
				i[2] -= 1
				if i[2] == 0:
					parent.automata.core.cell_set(x, y, automata.NULL)
	func take_click(event) -> void:
		if event is InputEventMouseButton and event.pressed: #On button press.
			var x:int = round(event.position.x) as int
			var y:int = round(event.position.y) as int
			if event.button_index == BUTTON_LEFT:
				units.append([x, y, 2])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = [self, units.size()]
				parent.nodes.component_map.update()
			elif event.button_index == BUTTON_RIGHT:
				var temp = parent.nodes.component_map.map[y][x - 1]
				if temp != null:
					units.remove(temp[1])
					parent.nodes.display.disconnect("gui_input", self, "take_click")
					parent.nodes.component_map.map[y][x - 1] = null
					parent.nodes.component_map.update()
	func reset() -> void:
		for i in units:
			parent.automata.core.cell_set(i[0], i[1], automata.WIRE_R)
			i[2] = 2
		.reset()
	func clear() -> void:
		for i in units:
			parent.nodes.component_map.map[i[1]][i[0] - 1] = 0
		parent.nodes.component_map.update()
		units.clear()
		.clear()

class IO_GLinker  extends IO_Component: #G-Linker. Any of its outputs activates the others to transfer a HEAD.
	var units:Array
	func _init(parent, N, pos:int, P:int, val:int) -> void:
		id = "G-Linker"
		type = TYPE_IO
		init(parent, N, pos, 1)
		units = []
	func step() -> void:
		var active:bool = false
		for i in units:
			var x:int = i[0]
			var y:int = i[1]
			var cell:int = parent.automata.core.cell_get(x, y)
			if cell == automata.HEAD_R:
				active = true
				continue
		if active:
			for i in units:
				parent.automata.core.cell_set(i[0], i[1], automata.HEAD_R)
				parent.image_glow.set_pixel(i[0], i[1], visual_data['WARP'].color)
	func take_click(event) -> void:
		if event is InputEventMouseButton and event.pressed and parent.cycle == 0: #On button press.
			var x:int = round(event.position.x) as int
			var y:int = round(event.position.y) as int
			if event.button_index == BUTTON_LEFT:
				units.append([x, y])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = 1
				parent.nodes.component_map.update()
			if event.button_index == BUTTON_RIGHT:
				units.erase([x, y])
				parent.nodes.display.disconnect("gui_input", self, "take_click")
				parent.nodes.component_map.map[y][x - 1] = 0
				parent.nodes.component_map.update()
	func reset() -> void:
		for i in units:
			parent.automata.core.cell_set(i[0], i[1], automata.WIRE_R)
		.reset()
	func clear() -> void:
		for i in units:
			parent.nodes.component_map.map[i[1]][i[0] - 1] = 0
		parent.nodes.component_map.update()
		units.clear()
		.clear()

class I_Clock     extends IO_Component: #A clock. Emits a HEAD when triggered.
	func _init(parent, N, pos:int, P:int, val:int) -> void:
		id = "Clock"
		init(parent, N, pos, P)
		parent.automata.core.cell_set(1, IO_row, 3)
	func step() -> void:
		if trigger_check(parent.cycle):
			parent.automata.core.cell_set(1, IO_row, 1)
			parent.image_glow.set_pixel(1, IO_row, visual_data['SPRK'].color)
		else:
			if parent.automata.core.cell_get(1, IO_row) == 1:
				heat += 1
				parent.image_glow.set_pixel(1, IO_row, visual_data['HEAT'].color)
		heat_check(parent.cycle)
	func reset() -> void:
		parent.automata.core.cell_set(ROW_IN, IO_row, 3)
		.reset()

class I_BitStream extends IO_Component: #Emits arbitrary amount of bits, one bit per trigger, on a loop.
	var value:Array
	var count:int = 0
	var size:int  = 4
	func _init(parent, N, pos:int, P:int, val:Array) -> void:
		id = "ROM"
		type = TYPE_IO
		init(parent, N, pos, P)
		parent.automata.core.cell_set(1, IO_row, 3)
		size = val.size()
		value.resize(size)
		for i in range(size): value[i] = val[i]
	func step() -> void:
		if trigger_check(parent.cycle):
			if value[count] == 1:
				parent.automata.core.cell_set(1, IO_row, 1)
				parent.image_glow.set_pixel(1, IO_row, visual_data['SPRK'].color)
			count = (count + 1) % size
		else:
			if parent.automata.core.cell_get(1, IO_row) == 1: heat += 1
		heat_check(parent.cycle)
	func reset() -> void:
		parent.automata.core.cell_set(ROW_IN, IO_row, 3)
		count = 0
		.reset()
	func output() -> String:
		return str("STEP=%d.%d" % [count, size])

class I_Octet     extends IO_Component: #Emits 8-bit binary data, one bit per trigger, on a loop.
	var value:Array
	var count:int = 0
	func _init(parent, N, pos:int, P:int, val:int) -> void:
		id = "Octet"
		type = TYPE_I
		init(parent, N, pos, P)
		parent.automata.core.cell_set(1, IO_row, 3)
		value = core.itoba8(val)
	func step() -> void:
		if trigger_check(parent.cycle):
			if value[count] == 1:
				parent.automata.core.cell_set(1, IO_row, 1)
				parent.image_glow.set_pixel(1, IO_row, visual_data['SPRK'].color)
			count = (count + 1) % 8
		else:
			if parent.automata.core.cell_get(1, IO_row) == 1: heat += 1
		heat_check(parent.cycle)
	func reset() -> void:
		parent.automata.core.cell_set(ROW_IN, IO_row, 3)
		count = 0
		.reset()
	func output() -> String:
		return str(core.batos(value), "\nSTEP=%d" % count)

class I_Nibble    extends IO_Component: #Emits 4-bit binary data, one bit per trigger, on a loop.
	var value:Array
	var count:int = 0
	func _init(parent, N, pos:int, P:int, val:int) -> void:
		id = "Nibble"
		type = TYPE_I
		init(parent, N, pos, P)
		parent.automata.core.cell_set(ROW_IN, IO_row, 3)
		value = core.itoba4(val)
	func step() -> void:
		if trigger_check(parent.cycle):
			if value[count] == 1:
				parent.automata.core.cell_set(1, IO_row, 1)
				parent.image_glow.set_pixel(1, IO_row, visual_data['SPRK'].color)
			count = (count + 1) % 4
		else:
			if parent.automata.core.cell_get(1, IO_row) == 1: heat += 1
		heat_check(parent.cycle)
	func reset() -> void:
		parent.automata.core.cell_set(ROW_IN, IO_row, 3)
		count = 0
		.reset()
	func output() -> String:
		return str(core.batos(value), "\nSTEP=%d" % count)

class I_Random    extends IO_Component: #Emits a HEAD with a given chance, once per trigger.
	var value:int = 0
	func _init(parent, N, pos:int, P:int, val:int) -> void:
		id = "Random"
		type = TYPE_I
		init(parent, N, pos, P)
		value = val
		parent.automata.core.cell_set(1, IO_row, 3)
	func step() -> void:
		if trigger_check(parent.cycle):
			if core.chance(value):
				parent.automata.core.cell_set(1, IO_row, 1)
				parent.image_glow.set_pixel(1, IO_row, visual_data['SPRK'].color)
		else:
			if parent.automata.core.cell_get(1, IO_row) == 1: heat += 1
		heat_check(parent.cycle)
	func reset() -> void:
		parent.automata.core.cell_set(ROW_IN, IO_row, 3)
		.reset()
	func output() -> String:
		return str("CHANCE=%d" % value)

class O_Output    extends IO_Component: #An output. Watches for a HEAD when triggered, and raises output if found.
	var energy:int = 0
	func _init(parent, N, pos:int, P:int, val:int) -> void:
		id = "Output"
		type = TYPE_O
		init(parent, N, pos, P)
		parent.automata.core.cell_set(ROW_OUT, IO_row, 3)
	func step() -> void:
		if trigger_check(parent.cycle):
			if parent.automata.core.cell_get(63, IO_row) == 1:
				energy += 1
				parent.image_glow.set_pixel(63, IO_row, visual_data['SPRK'].color)
		else:
			if parent.automata.core.cell_get(63, IO_row) == 1:
				heat += 1
				parent.image_glow.set_pixel(63, IO_row, visual_data['HEAT'].color)
		heat_check(parent.cycle)
	func reset() -> void:
		energy = 0
		parent.automata.core.cell_set(ROW_OUT, IO_row, 3)
		.reset()

class O_Value     extends IO_Component: #Raises output if the proper binary sequence is provided.
	var energy:int = 0
	var value:Array
	func _init(parent, N, pos:int, P:int, val:Array) -> void:
		id = "Value"
		type = TYPE_O
		init(parent, N, pos, P)
	func step() -> void:
		if trigger_check(parent.cycle):
			if parent.automata.core.cell_get(ROW_OUT, IO_row) == 1:
				energy += 1
				parent.image_glow.set_pixel(63, IO_row, visual_data['SPRK'].color)
		else:
			if parent.automata.core.cell_get(ROW_OUT, IO_row) == 1:
				heat += 1
				parent.image_glow.set_pixel(63, IO_row, visual_data['HEAT'].color)
		heat_check(parent.cycle)
	func reset() -> void:
		energy = 0
		parent.automata.core.cell_set(ROW_OUT, IO_row, 3)
		.reset()
	func output() -> String:
		return str(core.batos(value))

class O_Sound     extends IO_Component: #Beep boop.
	var pitch:float = 0
	var fx_channel:int = 0
	func _init(parent, N, pos:int, P:int, val:Array) -> void:
		id = "Output"
		type = TYPE_O
		init(parent, N, pos, 1)
		parent.automata.core.cell_set(ROW_OUT, IO_row, 3)
		pitch = val[0] as float / 32.0
		fx_channel = val[1] % 4
	func step() -> void:
		if parent.automata.core.cell_get(63, IO_row) == 1:
			parent.get_node(str("Audio",fx_channel)).pitch_scale = pitch
			parent.get_node(str("Audio",fx_channel)).play()
			parent.image_glow.set_pixel(63, IO_row, Color(0,1,0,1.00))
			parent.image_glow.set_pixel(62, IO_row, Color(0,1,0,0.80))
			parent.image_glow.set_pixel(61, IO_row, Color(0,1,0,0.60))
			parent.image_glow.set_pixel(60, IO_row, Color(0,1,0,0.40))
			parent.image_glow.set_pixel(59, IO_row, Color(0,1,0,0.20))
	func reset() -> void:
		parent.automata.core.cell_set(ROW_OUT, IO_row, 3)
		.reset()

class O_Bitmap    extends IO_Component: #Produces a 2D image from the output.
	const binmap = preload("res://nodes/UI/BinMap.tscn")
	var width:int  = 0
	var height:int = 0
	var display = null
	var point:int  = 0
	var ok:bool    = 0
	func _init(parent, N, pos:int, P:int, val:Array) -> void:
		id = "Bitmap"
		type = TYPE_O
		init(parent, N, pos, P)
		parent.automata.core.cell_set(63, IO_row, 3)
		display = binmap.instance()
		width  = val[0]
		height = val[1]
		display.init(width, height)
		node.get_node("Info").add_child(display)
		node.set_anchors_preset(Control.PRESET_WIDE)
	func step() -> void:
		if trigger_check(parent.cycle) and not ok:
			if parent.automata.core.cell_get(63, IO_row) == automata.HEAD_R:
				ok = true
				point = 0
				display.update()
		if trigger_check(parent.cycle) and ok:
			var x:int = point % width
			var y:int = point / width
			if parent.automata.core.cell_get(63, IO_row) == automata.HEAD_R:
				display.set(x, y, 1)
			else:
				display.set(x, y, 0)
			if point == (width * height) -1:
				ok = false
			point = (point + 1) % (width * height)
			display.cursor = Vector2(point % width, point / width)
			display.update()
	func reset() -> void:
		ok = false
		point = 0
		display.cursor = Vector2(0, 0)
		display.update()
		.reset()

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
	width = _width; height = _height

	automata  = AUTOMATA.new(width, height) #AUTOMATA holds the class for the automaton.
	automata.core.init(width, height, automata.visual_data)

	brush = automata.palette[1]
	set_palette(1)

	#Prepare the textures for drawing.
	image.create(_width, _height, false, Image.FORMAT_RGBA8)
	image.fill(bg_color)
	image_glow.create(_width, _height, true, Image.FORMAT_RGBA8)
	nodes.display.texture.create_from_image(image, 0)
	nodes.brush.get_node("Palette").init(automata)
	#Our "board" is nested arrays for cells. Stored in row, column order, so access with [y][x].
	overlay = core.newMatrix2D(_width + 1, _height + 1)
	automata.core.clear() # Clear the board here, so it's all fresh and initialized.
	copy(Vector2(0,0), Vector2(_width, _height)) #Set clipboard to the empty thing so it's initialized visually.
	$Display/Overlay.init(automata, _width, _height, overlay)
	nodes.status_text.text = "Welcome to ERAS Dashboard, <PLAYER>. Control of <ITEM>: Granted" #Show a "hell no" message for the Hollow Engine.
	#Set some components.
	#TODO: Load them from generator data.
	if automata.name == "WireworldRGB":
		nodes.component_map.init(width, height)
		inputs   = IO_ComponentList.new(nodes.inputs ,  self, IO_Component.TYPE_I)
		outputs  = IO_ComponentList.new(nodes.outputs,  self, IO_Component.TYPE_O)
		controls = IO_ComponentList.new(nodes.controls, self, IO_Component.TYPE_IO)
		inputs.add(I_Clock,  0, 3)
		inputs.add(I_Clock,  1, 4)
		inputs.add(I_Clock,  2, 5)
		inputs.add(I_Clock,  3, 6)
		inputs.add(I_Clock,  4, 7)
		inputs.add(I_Octet,  5, 6, 64)
		inputs.add(I_Nibble, 6, 6, 13)
		inputs.add(I_Random, 7, 6, 50)
		inputs.add(I_Octet,  8, 3, 89)
		inputs.add(I_BitStream, 9, 3, [
			1,0,1,0, 0,1,0,0, 0,1,0,1, 0,1,0,0,
			1,0,1,0, 0,1,0,1, 0,1,0,1, 0,1,0,0,
			1,1,1,0, 0,1,1,0, 1,1,0,1, 1,1,0,1])
		outputs.add(O_Output, 0, 6)
		outputs.add(O_Sound,  1, 6, [32,0])
		outputs.add(O_Sound,  2, 6, [16,1])
		outputs.add(O_Sound,  3, 6, [8,2])
		outputs.add(O_Value,  3, 6, [8,2])
		outputs.add(O_Bitmap, 4, 3, [16, 3])
		controls.add(IO_FastLane, 0, 3)
		controls.add(IO_GLinker,  1, 0)
		controls.add(IO_Fuse,     2, 0)
		controls.add(IO_Soup,     3, 0)
	update()

func image_update() -> void: #Redraw the board and glow textures.
	image.fill(bg_color);      image.lock();
	image_glow.fill(bg_color); image_glow.lock()
	automata.core.draw(image, image_glow)
	image.unlock(); image_glow.unlock()
	nodes.display.texture.create_from_image(image, 0)
	nodes.glows.texture.create_from_image(image_glow, ImageTexture.FLAG_FILTER)

static func clear(arr) -> void: #Completely erase a board.
	for i in arr:
		for j in range(i.size()):
			i[j] = 0

func encode() -> String: #Encode the board for storage.
	#This is a pretty apathetic RLE compression.
	#It's not quite ideal but will do for now.
	var result:String = 'ERAS:'
	var _count:int = 0;
	var temp:int = 0
	for y in range(height):
		for x in range(width):
			var temp2:int = automata.core.cell_get(x, y)
			if temp2 == temp: _count += 1
			else:
				result += "%s%d" % [ core.encode_base52[temp], _count ]
				temp = temp2
				_count = 0
	result +="%s%d" % [ core.encode_base52[temp], _count ] #Add remaining count at the end.
	return result

func decode(s:String) -> void: #Decode a saved string.
	_on_BClear_pressed()
	if s.begins_with('ERAS:'):
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
				x = (pointer % width) - 1
				y = (pointer / width)
				pointer += 1
				if x > 0: automata.core.cell_set(x, y, cell)
		#reset()
		nodes.stdout.text = str("Successfully loaded:\n", s)
	else:
		nodes.stdout.text = str("Invalid data:\n", s)
	image_update()

func reset() -> void: #Reset the board.
	cycle  = 0
	output = 0
	automata.core.reset()
	if automata.name == "WireworldRGB":
		inputs.reset()
		outputs.reset()
		controls.reset()
	image_update()

func step() -> void:  #Advance the simulation.
	cycle += 1
	image.fill(bg_color)
	image.lock();
	image_glow.fill(bg_color); #Reset glows before locking.
	image_glow.lock()
	var res:int = 0
	var ticks_test = OS.get_ticks_usec()
	automata.core.step_draw(image, image_glow)
	ticks_test = OS.get_ticks_usec() - ticks_test
	$CycleTimer.text = str(ticks_test)
	var ticks_component = OS.get_ticks_usec()
	#Component processing.
	if automata.name == "WireworldRGB":
		inputs.step()
		outputs.step()
		controls.step()
	#Display updating.
	$CompTimer.text = str(OS.get_ticks_usec() - ticks_component)
	image.unlock(); image_glow.unlock()
	nodes.display.texture.create_from_image(image, 0)
	nodes.glows.texture.create_from_image(image_glow, ImageTexture.FLAG_FILTER)

func _ready() -> void:
	set_process(false)
	nodes.display.texture = ImageTexture.new()
	nodes.glows.texture =   ImageTexture.new()
	init(64, 64)
	image_update()

func _process(delta: float) -> void:
	count += delta
	if count > 0.08:
		count = 0
		step()

static func merge(from:Vector2, _brush:Array, map:Array, skip_zero:bool = true) -> void:
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(min(x0 + _brush[0].size(), 64)) as int
	var y1:int = round(min(y0 + _brush.size(), 64)) as int
	for y in range(y0, y1):
		for x in range(x0, x1):
			if skip_zero:
				if _brush[y-y0][x-x0] != 0: map[y][x] = _brush[y-y0][x-x0]
			else:
				map[y][x] = _brush[y-y0][x-x0]

func merge2(from:Vector2, _brush:Array, skip_zero:bool = true) -> void:
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(min(x0 + _brush[0].size(), 64)) as int
	var y1:int = round(min(y0 + _brush.size(), 64)) as int
	for y in range(y0, y1):
		for x in range(x0, x1):
			if skip_zero:
				if _brush[y-y0][x-x0] != 0: automata.core.cell_set(x, y, _brush[y-y0][x-x0])
			else:
				automata.core.set_cell(x, y, _brush[y-y0][x-x0])

func rotateCW(map:Array): #Rotate clipboard contents clockwise.
	var h:int = map.size()
	var w:int = map[0].size()
	var result:Array = core.newMatrix2D(h,w)
	for y in range(h):
		for x in range(w):
			var temp = map[y][x]
			result[x][h-1-y] = map[y][x]
	nodes.clipboard_img.init(automata, h, w, result)
	clipboard = result

func rotateCCW(map:Array): #Rotate clipboard contents counter-clockwise.
	var h:int = map.size()
	var w:int = map[0].size()
	var result:Array = core.newMatrix2D(h,w)
	for y in range(h):
		for x in range(w):
			var temp = map[y][x]
			result[w-1-x][y] = map[y][x]
	nodes.clipboard_img.init(automata, h, w, result)
	clipboard = result

func rectangle(from:Vector2, to:Vector2, _brush:int, map:Array):
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(to.x) as int;   var y1:int = round(to.y) as int
	var left = x0 if x0 < x1 else x1
	var top  = y0 if y0 < y1 else y1
	var delta_x:int = abs(x1 - x0) as int
	var delta_y:int = abs(y1 - y0) as int
	core.line(Vector2(left, top), Vector2(left+delta_x, top), _brush, map)
	core.line(Vector2(left, top), Vector2(left, top+delta_y), _brush, map)
	core.line(Vector2(left+delta_x, top), Vector2(left+delta_x, top+delta_y), _brush, map)
	core.line(Vector2(left+delta_x, top+delta_y), Vector2(left, top+delta_y), _brush, map)

func copy(from:Vector2, to:Vector2) -> void:
	var x0:int = round(from.x) as int; var y0:int = round(from.y) as int
	var x1:int = round(to.x) as int;   var y1:int = round(to.y) as int
	var left = x0 if x0 < x1 else x1
	var top  = y0 if y0 < y1 else y1
	var delta_x:int = abs(x1 - x0) as int + 0
	var delta_y:int = abs(y1 - y0) as int + 0
	print("Copy:", delta_x, ",", delta_y)
	var result:Array
	result.resize(delta_y)
	for y in range(delta_y):
		result[y] = []
		result[y].resize(delta_x)
		for x in range(delta_x):
			result[y][x] = automata.core.cell_get(left+x, top+y)
	nodes.clipboard_img.init(automata, delta_x, delta_y, result)
	clipboard = result

# UI Signals ##################################################################

func _on_BClear_pressed() -> void: #Clear the entire board.
	cycle = 0
	output = 0
	if automata.name == "WireworldRGB":
		inputs.clear()
		outputs.clear()
		controls.clear()
	automata.core.clear()
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
		nodes.status_text.text = "Status: Stopped (Cycle %d)" % cycle
	else:
		set_process(true)
		get_node("BPlayStop").text = 'STOP'
		nodes.statusbar.color = Color("#282882")
		nodes.status_text.text = "Status: Test cycle"

func _on_BReset_pressed() -> void: #Remove all HEADs and TAILs, resetting the circuit.
	reset()
	$GridBG.dirty = false
	$GridBG.update()
	update()

func _on_Display_gui_input(event:InputEvent) -> void:  #Interpret mouse input over the canvas.
	if event is InputEventMouseButton and event.pressed: #On button press.
		var x:int = round(event.position.x) as int
		var y:int = round(event.position.y) as int
		if event.button_index == BUTTON_LEFT and not event.control:
			if draw_mode == DRAW_PASTE:
				merge2(event.position, clipboard)
				draw_mode = DRAW_PAINT
				mouse_held = false
				image_update()
				if cycle != 0 and $GridBG.dirty == false:
					$GridBG.dirty = true
					$GridBG.update()
			else:
				mouse_held = true
				draw_mode = DRAW_PAINT
				automata.core.cell_set(x, y, brush)
				line_start = event.position
				image_update()
				if cycle != 0 and $GridBG.dirty == false:
					$GridBG.dirty = true
					$GridBG.update()
		elif event.button_index == BUTTON_RIGHT and not event.control:
			mouse_held = true
			draw_mode = DRAW_ERASE
			automata.core.cell_set(x, y, 0)
			line_start = event.position
			image_update()
			if cycle != 0 and $GridBG.dirty == false:
				$GridBG.dirty = true
				$GridBG.update()
		elif event.button_index == BUTTON_WHEEL_UP:
			if draw_mode == DRAW_PASTE:
				rotateCW(clipboard)
				clear(overlay)
				merge(event.position, clipboard, overlay)
				$Display/Overlay.image_update(overlay)
				return
			else:
				palette = (palette + 1) % automata.palette.size()
				if palette < 1: palette = 1
				set_palette(palette)
				return
		elif event.button_index == BUTTON_WHEEL_DOWN:
			if draw_mode == DRAW_PASTE:
				rotateCCW(clipboard)
				clear(overlay)
				merge(event.position, clipboard, overlay)
				$Display/Overlay.image_update(overlay)
				nodes.display.update()
				return
			else:
				palette = palette - 1
				if palette < 1: palette = automata.palette.size() - 1
				set_palette(palette)
				return
		elif event.button_index == BUTTON_MIDDLE:
			set_color(automata.core.cell_get(x, y))
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
		match(draw_mode):
			DRAW_LINE:
				clear(overlay)
				$Display/Overlay.image_update(overlay)
				automata.core.line(round(line_start.x) as int, round(line_start.y) as int, round(event.position.x) as int, round(event.position.y) as int, brush)
				image_update()
				draw_mode = DRAW_PAINT
				if cycle != 0 and $GridBG.dirty == false:
					$GridBG.dirty = true
					$GridBG.update()
			DRAW_COPY:
				clear(overlay)
				$Display/Overlay.image_update(overlay)
				copy(line_start, event.position + Vector2(1, 1))
				image_update()
				draw_mode = DRAW_PAINT
	elif event is InputEventMouseMotion: #On mouse movement.
		cursor = event.position
		if mouse_held:
			if draw_mode == DRAW_PAINT or draw_mode == DRAW_ERASE:
				if ((0 < event.position.x) and (event.position.x < width)) and ((0 < event.position.y) and (event.position.y < height)):
					var x:int = round(event.position.x) as int
					var y:int = round(event.position.y) as int
					automata.core.cell_set(x, y, brush if draw_mode == DRAW_PAINT else 0)
				image_update()
				if cycle != 0:
					$GridBG.dirty = true
					$GridBG.update()
			elif draw_mode == DRAW_LINE:
				clear(overlay)
				core.line(line_start, event.position, brush, overlay)
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
			rotateCW(clipboard)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			rotateCCW(clipboard)
		elif event.button_index == BUTTON_MIDDLE:
			pass

