extends Panel

var stats1 = core.stats.createFromArray([61, 16, 10, 18, 12, 15, 17])
var stats2 = core.stats.createFromArray([474, 139, 93, 148, 105, 132, 163])

var stats3 = core.stats.create()

func _ready():
	$Label.text = str(stats1)
	$Label2.text = str(stats2)


func _on_HSlider_value_changed(value):
	for i in range(core.stats.SIZE):
		stats3[i] = floor(lerp(float(stats1[i]), float(stats2[i]), float(value) * 0.01))
	$Label3.text = str("level %s = %s" % [value, stats3])