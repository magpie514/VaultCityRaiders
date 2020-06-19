extends Panel
#                 0:Blck  1:RedD   2:RedB   3:Oran   4:Yell   5:GrnL   6:Turq   7:TrqL   8:Whit
const colors = [ "000000","880000","FF0000","FF8800","FFFF00","88FF88","00FFFF","88FFFF","FFFFFF" ]
var S = null
var skill = core.skill
var textures:Array = core.newArray(9)
var elements:Array = core.newArray(3)

func _init() -> void:
	for i in range(9):
		textures[i] = load(core.stats.ELEMENT_DATA[i].icon)

func _ready():
	for i in range(3):
		elements[i] = get_node(str("Element", i))
		elements[i].hide()

func hide_elements() -> void:
	for i in elements:
		i.hide()

func init(_S, level) -> void:
	S = _S
	if S == null: return
	var DE = S.displayElement
	var elem = null
	$Name.text = "%s  LV%02d/%02d" % [S.name, level+1, S.levels]
	hide_elements()
	if DE.size() > 0:
		for i in range(DE.size()):
			if i < 3:
				elem = elements[i]
				elem.texture = textures[DE[i]]
				elem.self_modulate = core.stats.ELEMENT_DATA[DE[i]].color
				elem.show()
	else:
		elements[0].texture = textures[S.element[level]]
		elements[0].self_modulate = core.stats.ELEMENT_DATA[S.element[level]].color
		elements[0].show()

	$ACC/Label.text = "%03d%%" % S.accMod[level]
	$ACC/Label.self_modulate = colorACC(S.accMod[level])

	if S.initAD[level] != S.AD[level]:
		$AD/Label.text = "%03d%%" % [S.initAD[level]]
		$AD/Label.self_modulate = colorAD(S.initAD[level])
		$AD/Label2.text = ">%03d%%" % [S.AD[level]]
		$AD/Label2.self_modulate = colorAD(S.AD[level])
		$AD/Label2.show()
	else:
		$AD/Label.text = "%03d%%" % [S.AD[level]]
		$AD/Label.self_modulate = colorAD(S.AD[level])
		$AD/Label2.hide()

	$SPD/Label.text = "%03d%%" % S.spdMod[level]
	$SPD/Label.self_modulate = colorSPD(S.spdMod[level])

	$CRIT/Label.text = "%03d%%" % S.critMod[level]
	$FE/Label.text = "x%1d" % S.fieldEffectMult[level]
	$FE/Label.self_modulate = colorEF1(S.fieldEffectMult[level])
	$FE/Label2.text = "+%1d" % S.fieldEffectAdd[level]
	$FE/Label2.self_modulate = colorEF1(S.fieldEffectAdd[level])

	$RANGE.text = "Ranged" if S.ranged[level] != 0 else "Melee"
	$ENERGY.text = "Energy" if S.energy else "Kinetic"
	$MAINSTAT/Label.text = "%s" % core.stats.STATS[S.damageStat]
	$MODSTAT/Label.text = "%s" % core.stats.STATS[S.modStat]

	if S.chain != core.skill.CHAIN_NONE:
		$CHAIN.show()
		match S.chain:
			core.skill.CHAIN_STARTER            : $CHAIN.text = "CHAIN STARTER"
			core.skill.CHAIN_STARTER_AND_FOLLOW : $CHAIN.text = "CHAIN START+FOLLOW"
			core.skill.CHAIN_FOLLOW             : $CHAIN.text = "CHAIN FOLLOW"
			core.skill.CHAIN_FINISHER           : $CHAIN.text = "CHAIN FINISHER"
	else: $CHAIN.hide()

	$Desc.text = S.description
	$Lore.text = S.lore
	$Desc2.text = core.skill.printCode(S, level)

func colorEF1(n:int) -> String:
	var result : String
	if   n > 3: result = colors[7]
	elif n > 1: result = colors[6]
	elif n < 1: result = colors[5]
	else      : result = colors[8]
	return result

func colorACC(n : int) -> String:
	var result : String
	if n >= 100: result = colors[8]
	elif n > 95: result = colors[7]
	elif n > 90: result = colors[6]
	elif n > 75: result = colors[5]
	elif n > 50: result = colors[2]
	elif n > 25: result = colors[1]
	else: result = colors[0]
	return result

func colorAD(n : int) -> String:
	var result : String
	if n > 300: result = colors[0]
	elif n > 200: result =  colors[1]
	elif n > 150: result = colors[2]
	elif n > 100: result = colors[4]
	elif n == 100: result = colors[8]
	elif n > 85: result = colors[6]
	else: result = colors[7]
	return result

func colorSPD(n : int) -> String:
	var result : String
	if n > 199: result = colors[7]
	elif n > 100: result = colors[6]
	elif n == 100: result = colors[8]
	elif n > 80: result = colors[4]
	elif n > 50: result = colors[3]
	elif n > 25: result = colors[2]
	else: result = colors[1]
	return result
