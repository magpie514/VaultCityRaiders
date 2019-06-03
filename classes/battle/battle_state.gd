enum { ACT_DEFEND, ACT_FIGHT, ACT_SKILL, ACT_ITEM, ACT_RUN, ACT_OVER }
enum { SIDE_PLAYER, SIDE_ENEMY, SIDE_SPECIAL }
enum { RESULT_ONGOING, RESULT_VICTORY, RESULT_DEFEAT, RESULT_GUILD_ESCAPE, RESULT_ENEMY_ESCAPE, RESULT_SPECIAL }

#signal skill_finished
const FIELD_EFFECT_SIZE = 12

var turn : int = 0
var quit : bool = false
var resolution : int = 0
var formations = core.newArray(2)
var actionQueue = core.newArray(1)
var field = preload("res://classes/battle/field_effects.gd").new()
var lastElement : int = 0    #Temporary var to store last used element. This is just to prevent multitarget attacks from adding too much.
var onhit = []
var UI = null
var lastAct = []
var nextAct = []
var EXP = 0
var msgColors = {
	names = ["9999FF", "FF9999", "99FF99"],
	damage = ["FF7842", "FC4547", "FFC542"],
	healing = ["44FF94"],
}

func dprint(text : String):
	print(text)


func _init():
	dprint("[battle_state]Initializing internal battle state...")
	turn = 0
	quit = false

func init(player, enemy, ui_node):
	UI = ui_node
	formations[SIDE_PLAYER] = player
	formations[SIDE_ENEMY] = enemy
	resetActionQueue()
	field.init()
	for i in formations:
		i.initBattle()

func echo(txt):
	UI.echo(txt)

func colorName(user) -> String:
	return msgColors.names[user.side]

func color_name(user) -> String:
	return "[color=#%s]%s[/color]" % [msgColors.names[user.side], user.name]

func passTurn():
	turn += 1
	echo("TURN %s START" % turn)
	field.passTurn()
	resetActionQueue()
	for i in formations:
		i.initBattleTurn()

func endTurn():
	var controlNode = core.battle.skillControl
	yield(controlNode.wait(0.001), "timeout") #Wait a little bit so the yield on caller can wait.
	print("Turn %s ended. Updating characters..." % turn)
	core.world.passTime()
	var defer = []
	for i in formations:
		for j in i.formation:
			if j != null:
				j.endBattleTurn(defer)
	if defer.size() > 0:
		for i in defer:
			print("  [ED:%sL%s] %s > %s" % [i[0].name, i[1], i[2].name, i[3].name])
			core.skill.processED(i[0], i[1], i[2], i[3])
			yield(controlNode, "skill_finished")
			print("....ED CODE RETURNED....")
	controlNode.emit_signal("skill_special_finished")

func resetActionQueue():
	actionQueue.clear()

static func sortActionQueue(a, b):
	return (a.spd > b.spd)

static func sortActionQueueOverPass(a, b):
	return (a.act == ACT_OVER)

func prepareActionQueue():
	self.printQueue()
	sort()

func pushAction(act):
	actionQueue.push_back(act)

func sort():
	actionQueue.sort_custom(self, "sortActionQueue")
	actionQueue.sort_custom(self, "sortActionQueueOverPass")

func popAction():
	return actionQueue.pop_front()

func status():
	return not quit

func amount():
	return actionQueue.size()

class Action:
	var side: int = 0
	var slot: int = 0
	var user = null
	var spd: int = 0
	var level: int = 0
	var skill
	var skillTid
	var target: Array
	var act: int = ACT_SKILL
	var WP = null
	var IT = null
	var override = null
	var cancel: bool = false

	func _init(_act = ACT_SKILL) -> void:
		act = _act


func addAction(side, slot, act: Action):
	var user = formations[side].formation[slot]
	act.user = user
	act.side = side
	act.slot = slot
	match act.act:
		ACT_DEFEND:
			act.skillTid = core.tid.create("core", "defend")
			act.skill = core.lib.skill.getIndex(act.skillTid)
			act.target = [ user ]
		ACT_RUN:
			act.skillTid = core.tid.create("debug", "debugi")
			act.skill = core.lib.skill.getIndex(act.skillTid)
			act.target = [ user ]
	if act.override != null:
			print("[BATTLE STATE][addAction] Using override %s" % act.override)
	act.spd = user.calcSPD(act.skill, 1)
	# var A = {
	# 	side = int(side),
	# 	user = user,
	# 	spd = int(spd),
	# 	level = int(act[2]),
	# 	skillTid = skill,
	# 	skill = S,
	# 	target = T,
	# 	act = int(act[0]),
	# 	WP = act[4],
	# 	IT = null,
	# }
	user.battle.lastAction = act
	if act.skill.chargeAnim[act.level] != 0: user.charge(true)
	if act.skill.initAD[act.level] != 100: user.display.updateAD(act.skill.initAD[act.level])
	pushAction(act)

func updateActions(A):
	lastAct = [A.side, A.user, A.skill, A.level]
	print("[BATTLE_STATE][UPDATEACTIONS] lastAct: %s %s LV%2d" % [lastAct[1].name, lastAct[2].name, lastAct[3]])
	var tmp = null
	if amount() > 0:
		tmp = actionQueue[0]
		nextAct = [tmp.side, tmp.user, tmp.skill]
	else:
		nextAct = null

func checkForAction(tid) -> bool:
	var S = core.lib.skill.getIndex(tid)
	for i in range(actionQueue.size()):
		if actionQueue[i].skill == S:
			return true
	return false

func checkResolution() -> void:
	var guildActive = formations[SIDE_PLAYER].activeCount()
	var enemyActive = formations[SIDE_ENEMY].activeCount()
	if guildActive == 0:
		quit = true
		resolution = RESULT_DEFEAT
	elif enemyActive == 0:
		quit = true
		resolution = RESULT_VICTORY
		print("[BATTLE_STATE][checkResolution] Awarding %d EXP!" % EXP)
		core.guild.giveXP(EXP)
	else:
		quit = false
		resolution = RESULT_ONGOING

func enemyActions() -> void: #Think enemy actions.
	var F = formations[SIDE_ENEMY]
	var P = formations[SIDE_PLAYER]
	var action = null
	for i in F.activeMembers():
		i.display.update()
		action = i.thinkBattleAction(F, P, self)
		var result = Action.new(ACT_SKILL)
		result.skillTid = action[0]
		result.skill = core.lib.skill.getIndex(action[0])
		result.level = action[1]
		result.target = action[2]
		addAction(SIDE_ENEMY, i.slot, result)


func checkActionExecution(user, target) -> bool:
	if quit == true:
		return false
	if user.canAct() == false:
		if user.battle.paralyzed == true:
			echo("%s is paralyzed!" % user.name)
		return false
	elif target != null:
		return true
	return false

func initAction(act) -> void:
	if checkActionExecution(act.user, act.target):
		act.user.useBattleSkill(self, act.act, act.skill, act.level, act.target, act.WP, act.IT)
		yield(core.battle.skillControl, "skill_finished")
		# Process post-skill actions.
		if onhit.size() > 0:
			while onhit.size() > 0:
				var F = onhit.pop_front()
				if F[1][0].canFollow(F[1][3], F[1][4], F[0]):
					checkFollow(F, onhit.size() == 0)
					yield(core.battle.skillControl, "skill_special_finished")
			yield(core.battle.skillControl, "onhit_finished")
			core.battle.skillControl.actionFinish()
		else:
			print("[BATTLE_STATE][INITACTION] No onhit, all done.")
			core.battle.skillControl.actionFinish()
	else:
		if act.IT != null:
			print("[BATTLE_STATE][INITACTION] %s was trying to use %s, but was unable to act, giving it back." % [act.user.name, act.IT.lib.name])
			act.user.group.inventory.returnConsumable(act.IT)

func checkFollow(F, last) -> void:
	var controlNode = core.battle.skillControl
	var T = F[0] #Target
	var S = F[1] #Follow settings
	print("[BATTLE_STATE][CHECKFOLLOW] %s is marked by %s with skill %s LV%d" % [T.name, S[0].name, S[3].name, S[4]])
	if S[0].side == SIDE_PLAYER: S[0].display.highlight(true)
	else: S[0].sprDisplay.act()
	yield(core.battle.control.wait(0.1), "timeout")
	core.skill.processFL(S[3], S[4], S[0], T, [S[1], S[2]], F[2])
	yield(controlNode, "skill_finished")
	print("[BATTLE_STATE][CHECKFOLLOW] Follow returned!")
	yield(core.battle.control.wait(0.5), "timeout")
	print("[BATTLE_STATE][CHECKFOLLOW] FL WAIT OK!")
	controlNode.finishSpecial()
	if last:
		controlNode.finishFollows()


func collectPriorityActions(act, temp):
	if checkActionExecution(act.user, act.target):
		if core.skill.hasCodePR(act.skill):
			temp.push_back( [ act.skill, act.level, act.user, act.side ] )

func checkPriorityActions():
	var controlNode = core.battle.skillControl
	var temp = []
	for i in actions():
		collectPriorityActions(i, temp)
		#Set Active Defense for all participants
		#TODO: Ensure this isn't done twice for Over skills or multiple actions?
		i.user.setInitAD(i.skill, i.level - 1)
	if temp.size() > 0:
		for i in temp:
			print("  [PR:%sL%s] %s" % [i[0].name, i[1], i[2].name])
			if i[3] == SIDE_PLAYER: i[2].display.highlight(true)
			else: i[2].sprDisplay.act()
			core.skill.runExtraCode(i[0], i[1], i[2], core.skill.CODE_PR)
			yield(controlNode, "skill_finished")
			if i[3] == SIDE_PLAYER: i[2].display.highlight(false)
			i[2].display.update()
			print("[BATTLE_STATE][checkPriorityActions] PR returned!")
			yield(core.battle.control.wait(0.5), "timeout")
			print("[BATTLE_STATE][checkPriorityActions]")
	yield(core.battle.control.wait(0.1), "timeout")
	controlNode.emit_signal("skill_special_finished")

func actions():
	var act = []
	for i in range(actionQueue.size()): #Return them in order, that way they are already sorted by speed.
		act.push_back(actionQueue[i])
	return act


##Debug functions
func echoArray(a):
	for i in a:
		echo(i)

func printQueueTargets(a):
	var result = ""
	for i in a:
		result += str("[%s:%s]" % [i.slot, i.name])
	return result

func printQueue():
	print("= Action queue =")
	print("Actions: %s" % actionQueue.size())
	print("Revive enemies: %s" % str(formations[SIDE_ENEMY].defeated))
	for i in actionQueue:
		print("[%1s]%s %sL%02d SPD:%s>%s" % [i.user.slot, i.user.name, i.skillTid, i.level, i.spd, printQueueTargets(i.target)])

func printQueuePanel():
	var result = "= Action Queue =\n"
	result += ("Actions: %s\n" % actionQueue.size())
	result += ("Revive enemies: %s\n" % str(formations[SIDE_ENEMY].defeated))
	for i in actionQueue:
		result += str("[%1s]%s %sL%02d SPD:%s>%s\n" % [i.user.slot, i.user.name, i.skillTid, i.level, i.spd, printQueueTargets(i.target)])
	return result
