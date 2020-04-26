extends Control
const PARTY_SIZE       = 6
var grid:Array

func battleTurnUpdate(): #Reset stuff at the start of a turn
	update()

func init() -> void:
	grid = [ [$AF0, $AF1, $AF2, $AB0, $AB1, $AB2],[$BF0, $BF1, $BF2, $BB0, $BB1, $BB2] ]

func connectUISignals(obj) -> void:
	for i in range(PARTY_SIZE):
		grid[0][i].connect("display_info", obj, "showInfo")
		grid[0][i].connect("hide_info"   , obj, "hideInfo")

func disconnectUISignals(obj) -> void:
	for i in range(PARTY_SIZE):
		grid[0][i].disconnect("display_info", obj, "showInfo")
		grid[0][i].disconnect("hide_info"   , obj, "hideInfo")

func update() -> void:
	for i in range(PARTY_SIZE):
		if core.guild.formation[i] != null       : grid[0][i].update()
		if core.battle.enemy.formation[i] != null: grid[1][i].update()
