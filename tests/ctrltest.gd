extends Control
signal battle_finished

enum { WAIT_S, WAIT_M, WAIT_L, WAIT_XL }
const DELAYS = [0.15, 0.5, 1.0, 2.0]
const BATTLE_SPEED_MULTIPLIER = [0.15, 0.5, 1.0, 2.0]

var testguild = null
var testmform = null
var state = preload("res://classes/battle/battle_state.gd").new()
var reply = null
var battleSpeed : int = 0

func _ready():
	testguild = core.guild
	testmform = core.battle.enemy
	testmform.versus = testguild
	testguild.versus = testmform
	$SkillController.speed = battleSpeed
	core.battle.control = self
	core.battle.skillControl = $SkillController
	core.battle.background = $Panel/ViewportContainer/Viewport/BattleView
	core.battle.bg_fx = $Panel/ViewportContainer/Viewport/BattleView/FXHook
	state.init(testguild, testmform, self)
	$Panel/BattleControls.init(state, self)
	$Panel/BattleControls.hide()
	$Panel/GuildDisplay.init(testguild)
	$Panel/EnemyGroupDisplay.init(testmform)
	$Panel/WinPanel.hide() #Hide the VICTORY panel if I forget it.

	$Panel/GuildDisplay.connectUISignals(self)
	$Panel/EnemyGroupDisplay.connectUISignals(self)
	$Panel/InfoDisplay.init(self)
	echo("[color=#EEEE77]%s[/color] appeared!" % testmform.name)
	$Panel/ViewportContainer/Viewport/BattleView.init(testmform)
	battle()
	yield(self, "battle_finished")
	print("We are done here!")
	core.stopMusic()
	yield(wait(24.0), "timeout")
	$Panel/GuildDisplay.disconnectUISignals(self)
	print("Done")
	core.world.passTime(1)
	core.changeScene("res://tests/debug_menu.tscn")

func battle():
	var A = null
	var islot = 0
	var playerActions:Array = []
	var C = null
	var playerChars = null
	$Panel/BattleControls.hide()
	#core.playMusic("res://resources/music/EOIV_Storm.ogg")
	while state.status():
		# Turn initialization #########################################################################
		$Panel/CurrentAction.hide()
		if checkResolution(): return #Make sure end of turn special effects didn't cause a victory or defeat.
		$Panel/FieldEffect.updateDisplay(state.field)
		#Show battle log and hide large action text.
		$Panel/BattleLog2.bbcode_text = ""
		$Panel/BattleLog2.hide()
		$Panel/BattleLog.show()

		#From now on it's the new turn.
		state.passTurn()
		$Panel/Turn.text = "Turn %s" % state.turn
		$Panel/Time.text = "Time: %02d Day: %03d" % [int(core.world.time / 30), core.world.day]

		#Collect enemy actions and show them in the side queue.
		state.enemyActions()
		$Panel/ActionQueue.init(state.actions())

		$Panel/GuildDisplay.update()

		playerActions.clear()
		playerChars = testguild.activeMembers()
		islot = 0

		# Collect player actions ######################################################################
		while islot < playerChars.size():
			$Panel/ActionQueue.init(state.actions(), playerActions)
			C = playerChars[islot]
			#yield(waitFixed(0.05), "timeout")
			C.charge(false)
			C.display.highlight(true)
			C.display.setActionText(null)

			# Show controls to pick action. It's stored in reply.
			reply = null
			$Panel/BattleControls.setup(C, islot, self)
			yield($Panel/BattleControls, "finished")
			# Action or cancel.
			C.display.highlight(false)
			if reply is state.Action:
				#Player chose a valid action, register it and move to next.
				C.display.setActionText(reply)
				playerActions.push_back([state.SIDE_PLAYER, C.slot, reply])
				islot += 1
			elif islot > 0:
				#Player cancelled current action, clean up and go back.
				C.battle.overAction.clear() #Remove Over skills.
				var temp = playerActions.pop_back()
				if temp[2].IT: #If player selected items, give them back to inventory or give charge back.
					#TODO: Check for standard item duplication exploit shenanigans.
					testguild.inventory.returnConsumable(temp[2].IT)
					temp[2].IT = null
				islot -= 1
			$Panel/BattleControls.closeAll()

		yield(waitFixed(0.25), "timeout")
		for i in playerActions:
			C = testguild.formation[i[1]]
			if not C.battle.overAction.empty():
				for j in C.battle.overAction:
					state.addAction(i[0], i[1], j)
				C.battle.overAction.clear() #We don't need them anymore.
			state.addAction(i[0], i[1], i[2])

		# Done collecting player actions from here ####################################################
		state.prepareActionQueue()
		$DebugActionQueue.text = state.printQueuePanel()
		$Panel/GuildDisplay.battleTurnUpdate() 			#Reset turn counters (accumulated damage, etc)
		$Panel/EnemyGroupDisplay.battleTurnUpdate()

# Action starts here ###########################################################
		$Panel/ActionQueue.init(state.actions())
		$Panel/BattleLog.hide()
		$Panel/BattleLog2.show()
		$Panel/BattleLog2.bbcode_text = ""
		$Panel/EnemyGroupDisplay.showBars(0.1)
	#First check if any actions have a priority setup.
		state.checkPriorityActions()
		yield($SkillController, "skill_special_finished")

	#Now run everything else.
		while state.amount() > 0:
			$Panel/BattleLog2.bbcode_text = ""
			A = state.popAction()
			$Panel/CurrentAction.show()
			$Panel/CurrentAction.init(A)
			$Panel/ActionQueue.init(state.actions())
			if A.user.canAct():
				if state.status():
					#Play ACTION animation.
					if A.side == state.SIDE_PLAYER:
						A.user.display.highlight(true)
						yield(wait(1.0), "timeout")

					else:
						A.user.sprDisplay.act()
						yield(A.user.sprDisplay.player, "animation_finished")
					state.initAction(A)
					yield($SkillController, "action_finished")
					state.updateActions(A)
					state.sort()
					yield(wait(1.0), "timeout")
					$Panel/GuildDisplay.update()
					$Panel/EnemyGroupDisplay.update()
					$Panel/FieldEffect.updateDisplay(state.field)
					if A.side == state.SIDE_PLAYER: A.user.display.highlight(false)
					if checkResolution(): return
				else:
					print("Skipping action, battle is over.")
		state.endTurn()
		yield($SkillController, "skill_special_finished")
		yield(wait(0.5), "timeout")
		$Panel/EnemyGroupDisplay.fadeBars(0.5)
		print("Checking if state changed...")
		if checkResolution(): return
		print("Actual end of turn")

# Support functions ###########################################################
func getBattleDelay(x):
	return float(x) * (BATTLE_SPEED_MULTIPLIER[battleSpeed])

func echo(text):
	text = str(text)
	$Panel/BattleLog.addLine(text)
	$Panel/BattleLog2.bbcode_text += "%s\n" % text

func wait(time, absolute = false): #Wait some time (affected by battle speed)
	$Timer.wait_time = time if absolute else getBattleDelay(time)
	$Timer.start()
	return $Timer

func waitFixed(time): #Wait some time (not affected by battle speed)
	var result = wait(time, true)
	print("[DD][CTRLTEST][waitFixed] Deprecated.")
	return result

func checkResolution():
	state.checkResolution()		#Check for battle resolution.
	match state.resolution: 	#Done very action, so no useless actions take place.
		state.RESULT_VICTORY:
			echo("Victory!")
			$Panel/WinPanel.show()
			#TODO: Show EXP and loot tally.
			testguild.stats.wins += 1
			emit_signal("battle_finished")
			return true
		state.RESULT_DEFEAT:
			echo("Defeat...")
			#TODO: Show game over screen and go back to HQ.
			testguild.stats.defeats += 1
			emit_signal("battle_finished")
			return true
		state.RESULT_GUILD_ESCAPE:
			echo("You ran away successfully!")
			#TODO: Show EXP tally anyway as long as any enemy was defeated.
			emit_signal("battle_finished")
			return true
		state.RESULT_ENEMY_ESCAPE:
			echo("Enemies fled!")
			#TODO: Same as above.
			testguild.stats.wins += 1
			emit_signal("battle_finished")
			return true
		_:
			return false

# Signals #####################################################################

func _on_BattleControls_finished(a): #Pick result from player input.
	$Panel/BattleControls.hide()
	#print("->",a)
	reply = a

func _on_QuitButton_pressed(): #Quit button.
	core.changeScene("res://tests/debug_menu.tscn")

func showInfo(what, type, level = 0): #Show the info panel.
	match type:
		0:
			$Panel/InfoDisplay.showPlayer(what)
		1:
			$Panel/InfoDisplay.showEnemy(what)
		2:
			$Panel/InfoDisplay.showSkill(what, level)
	$Panel/InfoDisplay.show()

func hideInfo(): #Hide the info panel.
	$Panel/InfoDisplay.hide()

func _on_Speed_pressed(x:int) -> void: #Speed control debug buttons.
	battleSpeed = x
	$SkillController.speed = x

func _on_Button_pressed() -> void: #PASS HOUR debug button.
	core.world.passTime()
