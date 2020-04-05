extends Control

signal selection(x)

const FRONT_ROW = 0
const BACK_ROW = 1
const PARTY_SIZE = 6

var guild = null
var displayAdv = core.newArray(6)
var displayClass = preload("res://nodes/UI/char_display.tscn")

onready var grid:Array = [ $F0, $F1, $F2, $B0, $B1, $B2 ]

func battleTurnUpdate(): #Reset stuff at the start of a turn
	for i in displayAdv:
		if i != null:
			i.resetDamageCount()

func showButtons(S):
	var chr = null
	for i in range(PARTY_SIZE):
		chr = guild.formation[i]
		if chr != null:
			if chr.filter(S):
				grid[i].selectable(true)

func hideButtons():
	var chr = null
	for i in range(PARTY_SIZE):
		chr = guild.formation[i]
		if chr != null:
			grid[i].selectable(false)

func targetSelectSignal(x) -> void:
	hideButtons()
	emit_signal("selection", x)

func init(G):
	if not G: return
	var party = null
	guild = G
	guild.display = self
	party = guild.formation

	for i in range(PARTY_SIZE):
		if party[i] != null:
			grid[i].show()
			grid[i].init(party[i])
			party[i].display = grid[i]
		else:
			grid[i].hide()


func connectUISignals(obj):
	for i in range(PARTY_SIZE):
		if guild.formation[i] != null:
			grid[i].connect("display_info", obj, "showInfo")
			grid[i].connect("hide_info", obj, "hideInfo")

func disconnectUISignals(obj):
	for i in range(PARTY_SIZE):
		if guild.formation[i] != null:
			grid[i].disconnect("display_info", obj, "showInfo")
			grid[i].disconnect("hide_info", obj, "hideInfo")

func update():
	for i in range(PARTY_SIZE):
		if guild.formation[i] != null:
			grid[i].update()
