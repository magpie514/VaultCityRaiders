extends Panel

func _ready():
	hide()

func showChar(c):
	if c == null: return
	show()
	$Name.text = str("%-24s" % c.name)
	$Level/RaceClass.text = str("%s/%s" % [c.racelib.name, c.classlib.name])
	$Level.text = str("LV.%03d" % c.level)
	$StatStatic/ATK.text = str(c.battle.stat.ATK)
	$StatStatic/BATK.init([float(c.statBase.ATK) / 255.0, float(c.statFinal.ATK - c.statBase.ATK) / 255.0, float(c.battle.stat.ATK - c.statFinal.ATK) / 255.0], ["FF0000", "FF9900", "0088FF"] )
	$StatStatic/DEF.text = str(c.battle.stat.DEF)
	$StatStatic/BDEF.init([float(c.statBase.DEF) / 255.0, float(c.statFinal.DEF - c.statBase.DEF) / 255.0, float(c.battle.stat.DEF - c.statFinal.DEF) / 255.0], ["FF0000", "FF9900", "0088FF"] )
	$StatStatic/ETK.text = str(c.battle.stat.ETK)
	$StatStatic/BETK.init([float(c.statBase.ETK) / 255.0, float(c.statFinal.ETK - c.statBase.ETK) / 255.0, float(c.battle.stat.ETK - c.statFinal.ETK) / 255.0], ["FF0000", "FF9900", "0088FF"] )
	$StatStatic/EDF.text = str(c.battle.stat.EDF)
	$StatStatic/BEDF.init([float(c.statBase.EDF) / 255.0, float(c.statFinal.EDF - c.statBase.EDF) / 255.0, float(c.battle.stat.EDF - c.statFinal.EDF) / 255.0], ["FF0000", "FF9900", "0088FF"] )
	$StatStatic/AGI.text = str(c.battle.stat.AGI)
	$StatStatic/BAGI.init([float(c.statBase.AGI) / 255.0, float(c.statFinal.AGI - c.statBase.AGI) / 255.0, float(c.battle.stat.AGI - c.statFinal.AGI) / 255.0], ["FF0000", "FF9900", "0088FF"] )
	$StatStatic/LUC.text = str(c.battle.stat.LUC)
	$StatStatic/BLUC.init([float(c.statBase.LUC) / 255.0, float(c.statFinal.LUC - c.statBase.LUC) / 255.0, float(c.battle.stat.LUC - c.statFinal.LUC) / 255.0], ["FF0000", "FF9900", "0088FF"] )

	$VitalStatic/Vital.text = str("%d/%d" % [c.HP, c.battle.stat.MHP])
	$ConditionStatic/Condition.text = str("%s" % core.stats.CONDITION_DATA[c.condition].name)
	$ConditionStatic/Condition.add_color_override("font_color", core.stats.CONDITION_DATA[c.condition].color)
	$ConditionPanel.init(c)

	$Elements.init(c.battle.stat)

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
