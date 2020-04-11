extends Position2D

const dmgColor = ["FF8A42","FC383B","FFDB4A"]
export(Color) var healColor = "44FF94" #TODO: Get this stuff from a theme file
var count:float = 1.0

func setExtraLabels(crit:bool = false, overkill:bool = false, guardbreak:bool = false, fullblock:bool = false) -> void:
	if crit:       $Label/CritLabel.show() #Critical hit
	else:          $Label/CritLabel.hide()
	if overkill:   $Label/OverkillLabel.show() #Overkill
	else:          $Label/OverkillLabel.hide()
	if guardbreak: $Label/GuardBreakLabel.show() #Guard break
	else:          $Label/GuardBreakLabel.hide()

func setSingle(dmg:int, crit:bool, overkill:bool, resist:int, info = null) -> void:
	var color:Color     = dmgColor[resist] if dmg > 0 else healColor
	var guardbreak:bool = false
	var fullblock:bool  = false
	if info != null:
		guardbreak = info.guardBreak
		fullblock = info.barrierFullBlock
	$Label.set("custom_colors/font_color", color)
	setExtraLabels(crit, overkill, guardbreak, fullblock)
	$Label.text = abs(dmg) as String

func setArray(data:Array) -> void:
	var sum:int       = 0
	var overkill:bool = false
	var hits:String   = ""
	for i in data:
		sum += i[0]
		hits += str("[color=#%s]%s[/color] " % [dmgColor[i[3]], i[0]])
		if not overkill and i[2]:
			overkill = true
	if not hits.empty():
		hits.erase(hits.length()-1, 1)
	$Label/Hits/RichTextLabel.bbcode_text = "[center]%s[/center]" % hits
	$Label/Hits.text = $Label/Hits/RichTextLabel.text
	$Label/Hits.show()
	setSingle(sum, false, overkill, 0, null)
	var size:Array = [$Label/Hits.get_size(), $Label.get_size()]
	$Label.set_size(Vector2(size[0].x, size[1].y))

func init(data) -> void:
	print("[DMGNUMBERS] ", data)
	$Label/Hits.hide()
	setExtraLabels()
	if data.size() == 1: setSingle(data[0][0], data[0][1], data[0][2], data[0][3], data[0][4])
	else:                       setArray(data)
	count = 1.0
	set_process(true)

func _process(delta:float) -> void:
	count -= 0.01
	$Label.rect_position.y -= .01 + count
	modulate.a = count
	if count < 0:
		set_process(false)
		queue_free()
