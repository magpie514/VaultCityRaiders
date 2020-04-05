extends Panel
var _targetButton = load("res://nodes/UI/target_button.tscn")

func _ready():
	pass

func init(group, parent):
	for i in range(group.MAX_SIZE):
		var current = group.formation[i]
		if current != null:
			var button = _targetButton.instance()
			button.init(current)
			var col = i if i < group.ROW_SIZE else i - group.ROW_SIZE
			var row = 0 if i < group.ROW_SIZE else 1
			add_child(button)
			button.rect_position = Vector2(rect_size.x/2 + (-button.rect_size.x if row == 0 else 0), col * button.rect_size.y)
			button.connect("select", parent, "on_char_pressed")
