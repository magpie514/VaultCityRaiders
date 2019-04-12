extends Label

var count : float = 1.0
const dmgColor = ["FF8A42","FC383B","FFDB4A"]
export(Color) var healColor = "44FF94" #TODO: Get this stuff from a theme file

func setExtraLabels(crit : bool = false, overkill : bool = false) -> void:
	if crit:       $CritLabel.show() #Critical hit
	else:          $CritLabel.hide()
	if overkill: $OverkillLabel.show() #Overkill
	else:          $OverkillLabel.hide()

func setSingle(dmg:int, crit:bool, overkill:bool, resist:int) -> void:
	var color = dmgColor[resist] if dmg > 0 else healColor
	set("custom_colors/font_color", color)
	setExtraLabels(crit, overkill)
	text = abs(dmg) as String

func setArray(data:Array) -> void:
	var sum : int = 0
	var overkill : bool = false
	var hits : String = ""
	for i in data:
		sum += i[0]
		hits += str("[color=#%s]%s[/color] " % [dmgColor[i[3]], i[0]])
		if not overkill and i[2]:
			overkill = true
	if not hits.empty():
		hits.erase(hits.length()-1, 1)
	$Hits/RichTextLabel.bbcode_text = "[center]%s[/center]" % hits
	$Hits.text = $Hits/RichTextLabel.text
	$Hits.show()
	setSingle(sum, false, overkill, 0)
	var size = [$Hits.get_size(), get_size()]
	set_size(Vector2(size[0].x, size[1].y))

func init(data):
	print("[DMGNUMBERS] ", data)
	$Hits.hide()
	setExtraLabels()
	if data.size() == 1: setSingle(data[0][0], data[0][1], data[0][2], data[0][3])
	else:                       setArray(data)
	count = 1.0
	set_process(true)

func _process(delta):
	count -= 0.01
	rect_position.y -= .01 + count
	modulate.a = count
	if count < 0:
		set_process(false)
		queue_free()
