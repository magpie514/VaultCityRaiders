extends Control

signal selection(x)

const FRONT_ROW = 0
const BACK_ROW = 1
const PARTY_SIZE = 6

var guild = null
var displayAdv = core.newArray(6)
var displayClass = preload("res://nodes/UI/char_display.tscn")

func rowSize(row):
	var a = [0, 1, 2] if row == FRONT_ROW else [3, 4, 5]
	var count = 0
	for i in a:
		count += 1 if displayAdv[i] else 0
	return count

func battleTurnUpdate(): #Reset stuff at the start of a turn
	for i in displayAdv:
		if i != null:
			i.resetDamageCount()

func showButtons(S):
	var chr = null
	for i in range(PARTY_SIZE):
		chr = guild.formation[i]
		if chr != null:
			if chr.filter(S.filter):
				displayAdv[i].selectable(true)

func hideButtons():
	var chr = null
	for i in range(PARTY_SIZE):
		chr = guild.formation[i]
		if chr != null:
			displayAdv[i].selectable(false)

func targetSelectSignal(x):
	hideButtons()
	emit_signal("selection", x)

func init(G):
	if not G: return
	var party = null
	guild = G
	guild.display = self
	party = guild.formation
	for i in range(PARTY_SIZE):
		displayAdv[i] = displayClass.instance() if party[i] else null
		if displayAdv[i]:
			add_child(displayAdv[i])
			displayAdv[i].init(party[i])
			displayAdv[i].connect("select", self, "targetSelectSignal")
			party[i].display = displayAdv[i]

	var row = int()
	var col = int()
	var colsize = [rowSize(FRONT_ROW), rowSize(BACK_ROW)]
	var colstart = [0, 0]
	for i in [FRONT_ROW, BACK_ROW]:
		match colsize[i]:
			3: colstart[i] = 0
			2: colstart[i] = rect_size.x * 0.16
			1: colstart[i] = rect_size.x * 0.5

	for i in range(PARTY_SIZE):
		if party[i]:
			row = FRONT_ROW if i < 3 else BACK_ROW
			col = 0 if i == 3 else col
			if displayAdv[i]:
				displayAdv[i].rect_position.x = colstart[row] + (rect_size.x / 3 * col)
				displayAdv[i].rect_position.y = (rect_size.y / 2) * row
				col += 1

func connectUISignals(obj):
	for i in range(PARTY_SIZE):
		if guild.formation[i] != null:
			displayAdv[i].connect("display_info", obj, "showInfo")
			displayAdv[i].connect("hide_info", obj, "hideInfo")

func disconnectUISignals(obj):
	for i in range(PARTY_SIZE):
		if guild.formation[i] != null:
			displayAdv[i].disconnect("display_info", obj, "showInfo")
			displayAdv[i].disconnect("hide_info", obj, "hideInfo")

func update():
	for i in range(PARTY_SIZE):
		if guild.formation[i] != null:
			displayAdv[i].update()

