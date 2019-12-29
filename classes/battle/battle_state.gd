
#signal skill_finished

const FIELD_EFFECT_SIZE = 12
const ElementField = preload("res://classes/battle/field_effects.gd")
const msgColors = {
	names = ["9999FF", "FF9999", "99FF99"],
	damage = ["FF7842", "FC4547", "FFC542"],
	healing = ["44FF94"],
}

enum { ACT_DEFEND, ACT_FIGHT, ACT_SKILL, ACT_ITEM, ACT_RUN, ACT_OVER }
enum { SIDE_PLAYER, SIDE_ENEMY, SIDE_SPECIAL }
enum { RESULT_ONGOING, RESULT_VICTORY, RESULT_DEFEAT, RESULT_GUILD_ESCAPE, RESULT_ENEMY_ESCAPE, RESULT_SPECIAL }

class Action:
	var user = null          #Pointer to user.
	var act:int = ACT_SKILL  #Action type.
	var side:int = 0         #User's group.
	var slot:int = 0         #User's slot.
	var spd:int = 0          #Action speed.
	var level:int = 0        #Action level.
	var skill                #Pointer to action's skill definition.
	var skillTid             #TID of skill definition.
	var target: Array        #List of targets.
	var override = null      #Pointer to skill override (mostly dragon gems)
	var cancel:bool = false  #TODO: What?
	#Player only.
	var WP = null            #Pointer to weapon in use.
	var IT = null            #Pointer to item in use.

	func _init(_act:int = ACT_SKILL) -> void:
		act = _act

var turn:int = 0                         #Current turn for this battle. Influences AI.
var quit:bool = false                    #If battle should continue or not.
var resolution:int = 0                   #Result for the encounter when quitting.
var formations:Array = core.newArray(2)  #Pointers to the participating groups.
var actionQueue = core.newArray(1)       #Action queue.
var field = ElementField.new()           #Elemental field.
var lastElement:int = 0                  #Temporary var to store last used element. This is just to prevent multitarget attacks from adding too much.
var onhit = []                           #Temporary var to store extra onhit effects.
var UI = null                            #Pointer to user interface.
var lastAct = []                         #Last action?
var nextAct = []                         #Next action?
var EXP:int = 0                          #Accumulated EXP reward for the encounter.


func dprint(text:String) -> void: #TODO: Convert this into a proper debug printer.
	print(text)

func _init() -> void:
	#This print here is only to see when the state is initialized in the logs.
	dprint("[BATTLE_STATE][_init]Initializing internal battle state...")
	turn = 0
	quit = false

func init(player, enemy, ui_node) -> void: #Actual initialization of the battle queue.
	UI = ui_node
	formations[SIDE_PLAYER] = player
	formations[SIDE_ENEMY] = enemy
	resetActionQueue()
	field.init() #Initialize elemental field.
	for i in formations: #Initialize both formations. Iterated in case I add more factions at once.
		i.initBattle()

func echo(txt) -> void: #Sends a message to the action log.
	UI.echo(txt)

func colorName(user) -> String:
	return msgColors.names[user.side]

func color_name(user) -> String:
	return "[color=#%s]%s[/color]" % [msgColors.names[user.side], user.name]

func passTurn(): #Advances the turn counter and makes groups update its members.
	turn += 1
	echo("TURN %s START" % turn)
	field.passTurn()
	resetActionQueue() #Relieve the queue from any potential trash data.
	for i in formations: #Make participating groups update their members.
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

func resetActionQueue() -> void: #Resets the action queue.
	dprint("[BATTLE_STATE][resetActionQueue] Resetting action queue.")
	actionQueue.clear()

func prepareActionQueue() -> void:
	self.printQueue()
	sort()

func pushAction(act:Action) -> void: #Push an action into the queue.
	actionQueue.push_back(act)

func popAction() -> Action: #Pop the front of the queue and return it.
	return actionQueue.pop_front()

func amount() -> int: #Returns amount of actions in the queue.
	return actionQueue.size()

func sort() -> void: #Sorts the action queue by action speed.
	actionQueue.sort_custom(self, "sortActionQueue")
	#Over actions take special priority and are put in front but are also sorted by speed besides that.
	actionQueue.sort_custom(self, "sortActionQueueOverPass")

static func sortActionQueue(a, b): #Sorts actions, faster first.
	return (a.spd > b.spd)

static func sortActionQueueOverPass(a, b): #Sorts actions, Over first.
	return (a.act == ACT_OVER)

func status() -> bool: #Checks if battle should continue or not.
	return not quit


func addAction(side, slot, act:Action) -> void:
	var user = formations[side].formation[slot]
	act.user = user
	act.side = side
	act.slot = slot

	match act.act: #These action types are special.
		ACT_DEFEND: #TODO: Set defensive action if any here.
			act.skillTid = core.tid.create("core", "defend")
			act.skill = core.lib.skill.getIndex(act.skillTid)
			act.target = [ user ]
		ACT_RUN: #Running is not a real skill, but internally it's treated as such.
			#TODO: Set up an actual running skill.
			act.skillTid = core.tid.create("debug", "debugi")
			act.skill = core.lib.skill.getIndex(act.skillTid)
			act.target = [ user ]

	if act.override != null: #Something, usually a dragon gem, is overriding the regular skill pointer.
		print("[BATTLE STATE][addAction] Using override %s" % act.override)

	#Action speed.
	if act.IT != null and act.act == ACT_ITEM: #Using an item, ignore skill speed.
		act.spd = user.calcSPD(user.battle.itemSPD)
	else: #Using a skill.
		act.spd = user.calcSPD(act.skill.spdMod[0])
		#act.spd = user.calcSPD(act.skill.spdMod[act.level]) #TODO: Enable this once all level data has been normalized.

	#Set action as last used for the character. Mostly relevant to players to redo actions from the battle menu.
	user.battle.lastAction = act

	# Visual and interface related functions go here.
	if act.skill.chargeAnim[act.level] != 0: user.charge(true)
	if act.skill.initAD[act.level] != 100: user.display.updateAD(act.skill.initAD[act.level])
	pushAction(act)

func updateActions(A) -> void:
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
	for i in F.activeMembers():
		var action = i.thinkBattleAction(F, P, self)
		var result = Action.new(ACT_SKILL)
		result.skillTid = action[0]
		result.skill = core.lib.skill.getIndex(action[0])
		result.level = action[1]
		result.target = action[2]
		i.display.update()
		addAction(SIDE_ENEMY, i.slot, result)

func checkActionExecution(user, target) -> bool: #Check if an action can be performed before getting to details.
	if quit == true: #Battle is over, no further actions are performed.
		return false
	if user.canAct() == false: #Check if user can act.
		if user.battle.paralyzed == true: #Intercept paralysis status in particular so a message can be printed.
			echo("%s is paralyzed!" % user.name)
		return false
	elif target != null: #If user can act and there are valid targets, proceed.
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
	#Play ACTION animation.
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


func collectPriorityActions(act, temp) -> void:
	if checkActionExecution(act.user, act.target):
		if core.skill.hasCodePR(act.skill):
			temp.push_back( [ act.skill, act.level, act.user, act.side ] )

func checkPriorityActions() -> void:
	var controlNode = core.battle.skillControl
	var temp:Array = []
	for i in actions():
		collectPriorityActions(i, temp) #Store priority actions in temp if any.
		#Set Active Defense for all participants
		#TODO: Ensure this isn't done twice for Over skills or multiple actions?
		#TODO: This should perhaps be elsewhere.
		i.user.setInitAD(i.skill, i.level - 1)
	if temp.size() > 0:
		for i in temp:
			#Execute PR code blocks of involved skills.
			print("  [PR:%sL%s] %s" % [i[0].name, i[1], i[2].name])
			#Play ACTION animation.
			if i[3] == SIDE_PLAYER: i[2].display.highlight(true)
			else: i[2].sprDisplay.act()
			core.skill.runExtraCode(i[0], i[1], i[2], core.skill.CODE_PR)
			yield(controlNode, "skill_finished")
			if i[3] == SIDE_PLAYER: i[2].display.highlight(false)
			i[2].display.update()
			print("[BATTLE_STATE][checkPriorityActions] PR returned!")
			yield(core.battle.control.wait(0.5), "timeout")
			print("[BATTLE_STATE][checkPriorityActions]")
	yield(core.battle.control.wait(0.1), "timeout") #Small pause.
	controlNode.emit_signal("skill_special_finished") #Notify we are done processing all priority special actions.

func actions() -> Array: #Returns a total list of actions without popping them.
	var result:Array = []
	for i in range(actionQueue.size()): #Return them in order, that way they are already sorted by speed.
		result.push_back(actionQueue[i])
	return result

# Debug functions #############################################################
func echoArray(a) -> void: #Prints all the contents of an array.
	for i in a:
		echo(i)

func printQueueTargets(a):
	var result = ""
	for i in a:
		result += str("[%s:%s]" % [i.slot, i.name])
	return result

func printQueue() -> void:
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
