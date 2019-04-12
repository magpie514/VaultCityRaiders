extends "res://classes/group/group_base.gd"
var monster = preload("res://classes/char/char_enemy.gd")

const ROW_SIZE = 5
const MAX_SIZE = ROW_SIZE * 2

var display = null
var defeated = []

func updateFormation():
	var M = null

func initBattleTurn():
	var current = null
	for i in range(MAX_SIZE):
		current = formation[i]
		if current != null and current.status == core.skill.STATUS_DOWN:
			print("%s is down, removing from battle..." % [current.name])
			current.display.stop()
			defeated.push_back(current)
			formation[i] = null
	display.update()
	.initBattleTurn()

func initMember(d, lvbonus):
	var m = monster.new()
	m.level = d.level + lvbonus
	m.tid = d.tid
	m.initDict(core.lib.monster.getIndex(d.tid))
	return m

func init(tid, lvbonus = 0):
	formation = core.newArray(MAX_SIZE)
	var form = core.lib.mform.getIndex(tid)
	name = form.name
	for i in range(MAX_SIZE):
		if form.formation[i] != null:
			formation[i] = initMember(form.formation[i], lvbonus)
			formation[i].slot = i
			formation[i].row = 0 if i < ROW_SIZE else 1
			formation[i].group = self

func getSpreadTargets(row, filter, slot):
	return getSpreadTargets2(row, ROW_SIZE, filter, slot)

func getRowTargets(row, filter):
	return getRowTargets2(row, ROW_SIZE, filter)

func loadDebug():
	init(["debug", "debug"])
