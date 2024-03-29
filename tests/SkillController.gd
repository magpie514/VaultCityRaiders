extends Node
signal timeout
signal skill_finished
signal fx_finished
signal skill_special_finished
signal onhit_finished
signal action_finished
signal notify_all_finished
signal notify_finished

const ANIM_SPEEDS = [2.5, 2.0, 1.0, 0.5]

var subControlNode = preload("res://nodes/SkillControlSub.tscn")
var speed:int = 0
var anim = null

func start():
	print("SKILL INIT: CREATING CONTROL NODE")
	var node = subControlNode.instance()
	add_child(node)
	return node

func finish() -> void:
	print("SKILL FINISHED SIGNAL")
	emit_signal("skill_finished")

func finishSpecial() -> void:
	print("SKILL SPECIAL FINISHED SIGNAL")
	emit_signal("skill_special_finished")

func finishNotification() -> void:
	print("SKILL NOTIFY FINISHED SIGNAL")
	emit_signal("notify_finished")

func finishNotifications() -> void:
	print("SKILL NOTIFY ALL FINISHED SIGNAL")
	emit_signal("notify_all_finished")

func finishFollows() -> void:
	print("ONHIT FINISHED SIGNAL")
	emit_signal("onhit_finished")

func actionFinish() -> void:
	print("ACTION FINISHED SIGNAL")
	emit_signal("action_finished")

func echo(val):
	var parent = get_parent()
	if val != null:
		match typeof(val):
			TYPE_ARRAY:
				for i in val:
					parent.echo(i)
			TYPE_STRING:
				parent.echo(val)

func wait(x):
	$FXTimer.wait_time = x
	$FXTimer.start()
	return self

func startAnim(S, level:int, x, target:Node2D, user:Node2D, mirror:bool = false)  -> void:
	#Plays current skill animation, if possible.
	var temp = S.animations[x] if x in S.animations else "res://nodes/FX/basic.tscn"
	temp = "res://nodes/FX/basic.tscn"
	anim = load(temp).instance()
	target.get_parent().add_child(anim)
	anim.connect("anim_done", self, "on_anim_done")
	anim.init(user, target, mirror)
	if S.animFlags[level] & core.skill.ANIMFLAGS_COLOR_FROM_ELEMENT: #TODO: Change to a group of colorizable elements.
		anim.modulate = core.stats.ELEMENT_DATA[S.element[level]].color
		print("[SKILLCONTROLLER] Setting color from element! %s" % str(anim.modulate))
	#anim.pos(display.get_global_rect().position + (display.get_global_rect().size / 2))
	anim.play(ANIM_SPEEDS[speed])

func _on_FXTimer_timeout() -> void:
	emit_signal("timeout")

func on_anim_done() -> void:
	if anim != null:
		anim.disconnect("anim_done", self, "on_anim_done")
		anim.queue_free()
		anim = null
	emit_signal("fx_finished")
