extends Position2D
signal done

const healColor = "44FF94" #TODO: Get this stuff from a theme file
const dmgColor  = ["FF8A42","FC383B","FFDB4A"]
var count:float = 0.0

func setExtraLabels(crit:bool = false, overkill:bool = false, fullblock:bool = false) -> void:
	$Label/CritLabel.visible     = crit #Critical hit

func getColor(dmg:int, resist:int = 0) -> String:
	if dmg > 0: return dmgColor[resist]
	else:       return healColor

func init(dmg:int, crit:bool = false, resist:int = 0, record:String = '') -> void:
	$Label/Hits.visible = not record.empty()
	setExtraLabels()
	var color:Color = getColor(dmg, resist)
	$Label.set("custom_colors/font_color", color)
	setExtraLabels(crit)
	$Label.text = abs(dmg) as String
	count = 0.0
	if $Label/Hits.visible:
		$Label/Hits/RichTextLabel.bbcode_text = "[center]%s[/center]" % record
		$Label/Hits.text = $Label/Hits/RichTextLabel.text #Workaround to have RichTextLabel adapt better.
	set_process(true)

func _process(delta:float) -> void:
	count += delta
	#$Label.rect_position.y -= .01 + count
	modulate.a = 1.0 - (count / 2.5)
	$Label.percent_visible = count / 0.25
	if count > 2.3:
		queue_free()
		emit_signal("done")
		set_process(false)
