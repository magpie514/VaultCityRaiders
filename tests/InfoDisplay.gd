extends Panel

func _ready():
	hide()

func showChar(c):
	show()
	$Name.text = str("%-24s" % c.name)
	$Level.text = str("LV.%03d" % c.level)
	$StatStatic/STR.text = str(c.battle.stat.ATK)
	$StatStatic/BSTR.init([float(c.statBase.ATK) / 255.0, float(c.statFinal.ATK - c.statBase.ATK) / 255.0, float(c.battle.stat.ATK - c.statFinal.ATK) / 255.0], ["FF0000", "FF9900", "0088FF"] )
	$StatStatic/END.text = str(c.battle.stat.DEF)
	$StatStatic/BEND.init([float(c.statBase.DEF) / 255.0, float(c.statFinal.DEF - c.statBase.DEF) / 255.0, float(c.battle.stat.DEF - c.statFinal.DEF) / 255.0], ["FF0000", "FF9900", "0088FF"] )
	$StatStatic/INT.text = str(c.battle.stat.ETK)
	$StatStatic/BINT.init([float(c.statBase.ETK) / 255.0, float(c.statFinal.ETK - c.statBase.ETK) / 255.0, float(c.battle.stat.ETK - c.statFinal.ETK) / 255.0], ["FF0000", "FF9900", "0088FF"] )
	$StatStatic/WIS.text = str(c.battle.stat.EDF)
	$StatStatic/BWIS.init([float(c.statBase.EDF) / 255.0, float(c.statFinal.EDF - c.statBase.EDF) / 255.0, float(c.battle.stat.EDF - c.statFinal.EDF) / 255.0], ["FF0000", "FF9900", "0088FF"] )
	$StatStatic/AGI.text = str(c.battle.stat.AGI)
	$StatStatic/BAGI.init([float(c.statBase.AGI) / 255.0, float(c.statFinal.AGI - c.statBase.AGI) / 255.0, float(c.battle.stat.AGI - c.statFinal.AGI) / 255.0], ["FF0000", "FF9900", "0088FF"] )
	$StatStatic/LUC.text = str(c.battle.stat.LUC)
	$StatStatic/BLUC.init([float(c.statBase.LUC) / 255.0, float(c.statFinal.LUC - c.statBase.LUC) / 255.0, float(c.battle.stat.LUC - c.statFinal.LUC) / 255.0], ["FF0000", "FF9900", "0088FF"] )

	$VitalStatic/Vital.text = str("%d/%d" % [c.HP, c.battle.stat.MHP])
	$ConditionStatic/Condition.text = str("%s" % core.skill.statusInfo[c.status].name)
	$ConditionStatic/Condition.add_color_override("font_color", core.skill.statusInfo[c.status].color)

	var elem = null
	for i in range(1, 8):
		elem = get_node(str("Elements/OFF/%02d" % [i]))
		elem.text = str("%03d" % c.battle.stat.OFF[core.stats.getElementKey(i)])
		elem = get_node(str("Elements/RES/%02d" % [i]))
		elem.text = str("%03d" % c.battle.stat.RES[core.stats.getElementKey(i)])

	var line = null
	if c.battle.buff != null:
		for i in range(3):
			line = get_node(str("Buffs/BuffLine%1s" % [i]))

			if i < c.battle.buff.size():
				line.text = c.battle.buff[i][0].name
				line.get_node("Label").text = str("%02d" % [c.battle.buff[i][2]])
				line.get_node("Label").show()
			else:
				line.text = "--"
				line.get_node("Label").hide()
			line = get_node(str("Debuffs/DebuffLine%1s" % [i]))
			if i < c.battle.debuff.size():
				line.text = c.battle.debuff[i][0].name
				line.get_node("Label").text = str("%02d" % [c.battle.debuff[i][2]])
				line.get_node("Label").show()
			else:
				line.text = "--"
				line.get_node("Label").hide()
