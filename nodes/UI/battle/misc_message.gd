extends Label

var msg = ""
var count = float()

func init(n, crit, color):
	count = 1.0
	msg = n
	text = str(msg)
	if color != null: modulate = color
	if crit: 	$CritLabel.show()
	else:			$CritLabel.hide()
	$CritLabel.rect_size.x = rect_size.x #Keep centered, copying the X size of the main label just works.
	set_process(true)

func _process(delta):
	count -= 0.01
	rect_position.y -= .01 + count
	modulate.a = count
	if count < 0:
		set_process(false)
		queue_free()