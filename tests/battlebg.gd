extends Node2D

func init(group): #TODO: Use this later, properly.
	print("[BATTLEBG] Remember I exist!")
	var bgf = load("res://tests/bgtest_01.tscn").instance()
	$BG.add_child(bgf)
