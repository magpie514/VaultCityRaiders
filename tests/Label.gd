extends Label

var lines = []
const MAX_LINES = 25

func _ready():
	for i in range(MAX_LINES):
		add_line("")
	update()

func add_line(text):
	print(text)
	lines.push_back(text)
	if(lines.size() > MAX_LINES): lines.pop_front()
	update()

func update():
	var result = ""
	for i in range(lines.size()):
		result = str(result + lines[i] + "\n")
	self.text=result
	pass