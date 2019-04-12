extends Panel
signal openMenu
var W = null

func init(WP) -> void:
	W = WP
	$Name.text = WP.lib.name
	for i in range(9):
		var B = get_node("Slot%d" % i)
		if WP.DGem.slot[i] != null:
			B.text = "%s" % WP.DGem.slot[i].getUnicodeIcon()
			B.set("custom_colors/font_color", WP.DGem.slot[i].lib.color)
			B.hint_tooltip = "%s%s LV%d" % [WP.DGem.slot[i].getUnicodeIcon(), WP.DGem.slot[i].lib.name, WP.DGem.slot[i].level]
		else:
			B.set("custom_colors/font_color", "#FFFFFF")
			B.text = "⨯"


func _on_Slot_pressed(slot: int) -> void:
	emit_signal("openMenu", slot, W)


func _on_RemoveAll_pressed() -> void:
	for i in range(9):
		var G = W.detachGem(i)
		core.guild.giveDGem(G)
		init(W)
