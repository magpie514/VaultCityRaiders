extends Label

var msg : String = ''
var count : float  = 0.0

func init(n, crit, color) -> void:
	count = 1.0
	msg = n
	text = str(msg)
	percent_visible = 0.0
	if color != null: set("custom_colors/font_color", color)
	if crit: 	$CritLabel.show()
	else:			$CritLabel.hide()
	$CritLabel.rect_size.x = rect_size.x #Keep centered, copying the X size of the main label just works.
	count = 0.0
	set_process(true)

func _process(delta: float) -> void:
	count += 1.4 * delta
	percent_visible = count
	if count > 1.0:
		count = 0.0
		set_process(false)
