extends Control

var _seed = OS.get_unix_time()
var ELV : int = 0
var rank : int = 0

func _ready():
	if core.guild != null:
		$Panel2.show()
		$Panel2/Guild.text = str("The %s guild" % core.guild.name)
		$Panel2/Funds.text = str("Funds: %010d" % [core.guild.funds])
		$Panel2/Time.text = str("Time: %02d(%02d) Day: %02d" % [core.world.time / 30, core.world.time, core.world.day])
		$Panel2/Wins.text = str("Wins: %03d" % [core.guild.stats.wins])
		rank = core.guild.stats.wins
		$Panel2/Loses.text = str("Defeats: %03d" % [core.guild.stats.defeats])
		$Panel2/PartyDisplay.init(core.guild, self)
	$Panel3/Seed.text = str("%s" % [_seed])
	$Panel2/ELV.text = str(ELV)
	for i in get_tree().get_nodes_in_group("CharMenus"):
		i.hide()


#Function buttons
func _on_Heal_pressed():
	if core.guild != null:
		core.guild.healAll()

#Battle start buttons
func _on_Button_pressed():
	core.initGameState(_seed)
	if core.guild == null:
		core.initGuild("res://data/debug_guild.gd")
	core.initBattle(["debug", "debug"], ELV)

func _on_Button5_pressed():
	core.initGameState(_seed)
	if core.guild == null:
		core.initGuild("res://data/debug_guild.gd")
	core.initBattle(["debug", "debug0"], ELV)

func _on_Button6_pressed():
	var battleTIDs = [ ["debug", "debug"], ["debug", "debug0"], ["debug", "debug1"], ["debug", "debug2"] ]
	core.initGameState(_seed)
	if core.guild == null:
		core.initGuild("res://data/debug_guild.gd")
	core.initBattle(core.randomPick(battleTIDs), ELV)

func _on_RankSlider_value_changed(value: float) -> void:
	rank = value as int
	$Panel2/Rank.text = str(rank)

#Level adjust buttons
func _on_ELVSlider_value_changed(value: float) -> void:
	ELV = value as int
	$Panel2/ELV.text = str(ELV)


#Character display
func on_char_pressed(ch) -> void:
	$Panel4.init(ch)
	for i in get_tree().get_nodes_in_group("CharMenus"):
		i.hide()
	$Panel4.show()

#Dragon Gem menu
func _on_DGem_pressed() -> void:
	$Panel5.init($Panel4.C, self)
	$Panel5.show()

#Dragon Gem selector
func _on_DGem_select(slot:int, WP) -> void:
	$Panel6.init($Panel4.C, slot, WP, self)
	$Panel6.show()

#Equip Dragon Gem
func _on_DGem_selected(G, index, WP, slot) -> void:
	var C = $Panel4.C
	print("Char: %s, to equip gem %s LV.%1d (%d) on slot %d of %s" % [C.name, G.lib.name, G.level, index, slot, WP.lib.name])
	WP.attachGem(G, slot)
	core.guild.dragonGems[index] = null
	core.guild.sortDGems()
	$Panel6.close()
	$Panel5.init(C, self)

func _on_LoadDebugParty_pressed() -> void:
	core.initGameState(_seed)
	if core.guild == null:
		core.initGuild("res://data/debug_guild.gd")
	core.changeScene("res://tests/debug_menu.tscn")


func _on_DGemCancel_pressed() -> void:
	$Panel6.close()


func _on_DGemRemove_pressed(WP, slot) -> void:
	var C = $Panel4.C
	var G = WP.detachGem(slot)
	core.guild.giveDGem(G)
	$Panel6.close()
	$Panel5.init(C, self)
