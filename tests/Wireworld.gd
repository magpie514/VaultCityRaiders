extends TextureRect
enum { NULL=0, HEAD=1, TAIL=2, WIRE=3 }
const wiredata:Dictionary = {
	NULL: { color = Color("#00000000") },
	WIRE: { color = Color("#433300") },
	HEAD: { color = Color("#C4DBFF") },
	TAIL: { color = Color("#1E4E99") },
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

onready var nodes = { parent = get_parent(), glows = $TextureRect, label = get_parent().get_node("STDOUT") }

# Component data ##############################################################
#   Components are additions over standard wireworld. While you should indeed be able to
# generate any components you need with standard wireworld rules, we are using boards of limited
# space. Components implement certain logic components in a more compact way.

var components:Array

class Component:
	var x:int = 0
	var y:int = 0
	func step(parent) -> void:
		pass

class Clock extends Component:
	var period:int = 6 #Emits a HEAD when cycle%period == 0
	func _init(px:int, py:int, p:int) -> void:
		x = px; y = py
		period = p
	func step(parent) -> void:
		if not parent.cycle % period:
			parent.cells[y][x] = HEAD
			parent.image_glow.set_pixel(x, y, wiredata[HEAD].color)

class Output extends Component:
	func _init(px:int, py:int) -> void:
		x = px; y = py
	func step(parent) -> void:
		if parent.cells[y][x] == HEAD:
			parent.output += 1

# Main functions ##############################################################

func init(_width:int, _height:int) -> void:
	rangex = range(1, _width)
	rangey = range(1, _height)
	image = Image.new();
	image_glow = Image.new()
	image.create(_width + 1, _height + 1, false, Image.FORMAT_RGBA8)
	image.fill(null_color)
	image_glow.create(_width + 1, _height + 1, true, Image.FORMAT_RGBA8)

	texture = ImageTexture.new()
	nodes.glows.texture = ImageTexture.new()
	texture.create_from_image(image, 0)

	cmap[0] = core.newArray(_height + 1)
	for i in range(cmap[0].size()):
		cmap[0][i] = PoolByteArray(core.newArray(_width + 1)) #PoolByteArray should be a bit more efficient.
	cells = cmap[0]
	#Set down a clock at 2,2 with period 6, and an output at 10, 2.
	components = []
	components.append(Clock.new(2, 2, 6))
	components.append(Output.new(10, 2))
	clear()
	cmap[1] = cmap[0].duplicate(true)
	update()


func cmap_swap() -> void: #Swap our predefined arrays.
	cells = cmap[1] if cycle % 2 else cmap[0]

func image_update() -> void:
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


func clear() -> void:
	cycle = 0
	output = 0
	for y in rangey:
		for x in rangex:
			cells[y][x] = NULL
	image_update()

func reset() -> void:
	#We don't really store original state.
	#Instead we just set every cell that isn't NULL to WIRE. We only care about the wires
	#for our purposes here.
	for y in rangey:
		for x in rangex:
			var cell = cells[y][x]
			if cell != NULL:
				cells[y][x] = WIRE
	image_update()

func rules(map, x, y) -> int:
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
	for i in components: i.step(self)
	#Display updating.
	image.unlock(); image_glow.unlock()
	texture.create_from_image(image, 0)
	nodes.glows.texture.create_from_image(image_glow)
	nodes.glows.update()
	nodes.label.bbcode_text = "Cycle: %0.5d, Generator Period: %0.2d, Heads: %0.4d, Output: %0.5d" % [cycle, 6, HEADs, output]


func _ready() -> void:
	init(64, 64)
	set_process(false)
	image_update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	count += delta
	if count > 0.12:
		count = 0
		step()

func _draw() -> void: #Draw a cursor. It's more precise this way.
	draw_rect(Rect2(Vector2(round(cursor.x), round(cursor.y)), Vector2(1,1)), "#FFFF00", false)

#Process mouse stuff over the canvas.
func _on_Control_gui_input(event: InputEvent) -> void:
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



func _on_Button_pressed() -> void:
	step()
	update()


func _on_Button2_pressed() -> void:
	if is_processing():
		set_process(false)
		get_parent().get_node("BPlayStop").text = 'PLAY'
	else:
		set_process(true)
		get_parent().get_node("BPlayStop").text = 'STOP'


func _on_Button3_pressed() -> void:
	reset()
	update()


func _on_BClear_pressed() -> void:
	clear()
	update()
