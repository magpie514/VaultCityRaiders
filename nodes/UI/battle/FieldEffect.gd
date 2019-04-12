extends Panel
var textures = core.newArray(8)


func _ready() -> void:
	for i in range(8):
		textures[i] = load(core.stats.ELEMENT_DATA[i].icon)



func updateDisplay(FE:Object) -> void:
	var A = FE.data
	var sp = null
	var combo : int = 0
	var last : int = 0
	var tex : Texture
	var stri = ""
	for i in range(A.size()):
		sp = get_node(str("Sprite",i))
		sp.self_modulate = core.stats.ELEMENT_DATA[A[i]].color
		sp.texture = textures[A[i]]
		if A[i] == last and last != 0:
			if combo == 0 and i != 0:
				get_node(str("Combo", i-1)).color = core.stats.ELEMENT_DATA[A[i-1]].color
			combo += 1
			get_node(str("Combo", i)).color = core.stats.ELEMENT_DATA[A[i]].color
		else:
			combo = 0
			get_node(str("Combo", i)).color = Color(0, 0, 0, 0)
		last = A[i]
	for i in range(1, FE.bonus.size()):
		stri += str("[color=#%s]%s:%s%%[/color]\n" % [core.stats.ELEMENT_DATA[i].color, core.stats.ELEMENT_DATA[i].name, FE.bonus[i]])
	stri += str("Chains: %s Individual:%s/7\nHighest chain: %s" % [FE.chains, FE.unique, FE.maxChain])
	$FEPanel/RichTextLabel.bbcode_text = stri
	$Dominant.color = core.stats.ELEMENT_DATA[FE.dominant].color




func _on_TEST00_pressed() -> void:
	core.battle.control.state.field.push(randi() % 8)
	updateDisplay(core.battle.control.state.field)

func _on_TEST01_pressed() -> void:
	core.battle.control.state.field.random(1)
	updateDisplay(core.battle.control.state.field)

func _on_TEST02_pressed() -> void:
	core.battle.control.state.field.random(2)
	updateDisplay(core.battle.control.state.field)


func _on_TEST03_pressed() -> void:
	core.battle.control.state.field.consume(6)
	updateDisplay(core.battle.control.state.field)

func _on_TEST04_pressed() -> void:
	core.battle.control.state.field.optimize()
	updateDisplay(core.battle.control.state.field)


func _on_CloseFEPanel_pressed() -> void:
	$FEPanel.hide()


func _on_TEST05_pressed() -> void:
	core.battle.control.state.field.fillChance(6, 15)
	updateDisplay(core.battle.control.state.field)

func _on_FEDebug_pressed() -> void:
	$FEPanel.show()
