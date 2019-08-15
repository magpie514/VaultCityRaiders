extends TextureRect
enum { NULL=0, HEAD=1, TAIL=2, WIRE=3 }
const wiredata:Dictionary = {
	NULL: { color = Color("#000000") },
	WIRE: { color = Color("#433300") },
	HEAD: { color = Color("#F0F05F") },
	TAIL: { color = Color("#A15224") },
}

const iter_neighbor = [
	[-1,-1], [-1, 0], [-1, 1],
	[ 0,-1],          [ 0, 1],
	[ 1,-1], [ 1, 0], [ 1, 1]
]
var width:int =  0
var height:int = 0
var cmap:Array = [[], []]
var cells:Array = cmap[0] #Cells is a pointer to current world. The worlds are swapped so memory use is under control.
var rangex:Array
var rangey:Array
var cursor:Vector2 = Vector2(0,0)
var cycle:int = 0 #Internal timer
var HEADs:int = 0 #Count of HEADs per turn.
var image:Image
var image_glow:Image

func _init(_width:int = 64, _height:int = 64) -> void:
	rangex = range(1, _width  + 1)
	rangey = range(1, _height + 1)
	image = Image.new();
	image_glow = Image.new()
	image.create(_width + 1, _height + 1, false, Image.FORMAT_RGBA8)
	image.fill('#000000')
	image_glow.create(_width + 1, _height + 1, true, Image.FORMAT_RGBA8)
	cmap[0].resize(_height + 1)
	for i in range(cmap[0].size()):
		var t = []
		t.resize(_width + 1)
		cmap[0][i] = t
	for y in rangey:
		for x in rangex:
			cmap[0][y][x] = 0
	cmap[1] = cmap[0].duplicate(true)
	cells = cmap[0]
	update()

func cmap_swap() -> void: #Swap our predefined arrays.
	cells = cmap[1] if cycle % 2 else cmap[0]

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
	cmap_swap()
	HEADs = 0
	image.lock();
	image_glow.fill(Color(0,0,0,0))
	image_glow.lock()
	for y in rangey:
		for x in rangex:
			cells[y][x] = rules(map, x, y)
			if cells[y][x] == HEAD:
				HEADs += 1
			if cells[y][x] == HEAD or cells[y][x] == TAIL:
				image_glow.set_pixel(x, y, wiredata[cells[y][x]].color)
			image.set_pixel(x, y, wiredata[cells[y][x]].color)
	image.unlock(); image_glow.unlock()
	texture.create_from_image(image, 0)
	$TextureRect.texture.create_from_image(image_glow)
	$TextureRect.update()
	cycle += 1
	if not cycle % 6: cells[2][2] = HEAD
	get_parent().get_node("RichTextLabel").bbcode_text = "Cycle: %.05d, Generator Period: %.05d, Heads: %.05d" % [cycle, 6, HEADs]


func _ready() -> void:
	texture = ImageTexture.new()
	$TextureRect.texture = ImageTexture.new()
	_init(64, 64)
	texture.create_from_image(image, 0)
	set_process(false)
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
var count:float = 0.0
func _process(delta: float) -> void:
	count += delta
	if count > 0.3:
		count = 0
		step()
	pass

func _draw() -> void:
	draw_rect(Rect2(Vector2(round(cursor.x), round(cursor.y)), Vector2(1,1)), "#FFFF00", false)

func _on_Control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var x:int = round(event.position.x) as int
		var y:int = round(event.position.y) as int
		cells[y][x] = WIRE
		print(event.position)
		update()
	elif event is InputEventMouseMotion:
		cursor = event.position
		update()



func _on_Button_pressed() -> void:
	step()
	update()


func _on_Button2_pressed() -> void:
	if is_processing():
		set_process(false)
		get_parent().get_node("Button2").text = 'PLAY'
	else:
		set_process(true)
		get_parent().get_node("Button2").text = 'STOP'
