extends Node
signal timeout
signal skill_finished
signal fx_finished
signal skill_special_finished
signal onhit_finished
signal action_finished

const ANIM_SPEEDS = [2.5, 2.0, 1.0, 0.5]

var subControlNode = preload("res://nodes/SkillControlSub.tscn")
var speed : int = 0
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

func startAnim(S, level, x, display) -> void:
	var temp = S.animations[x] if x in S.animations else "res://nodes/FX/basic.tscn"
	anim = load(temp).instance()
	add_child(anim)
	if S.animFlags[level] & core.skill.ANIMFLAGS_COLOR_FROM_ELEMENT:
		anim.modulate = core.stats.ELEMENT_DATA[S.element[level]].color
		print("[SKILLCONTROLLER] Setting color from element! %s" % str(anim.modulate))
	anim.pos(display.get_global_rect().position + (display.get_global_rect().size / 2))
	anim.connect("anim_done", self, "on_anim_done")
	anim.play(ANIM_SPEEDS[speed])

func _on_FXTimer_timeout():
	emit_signal("timeout")

func on_anim_done():
	if anim != null:
		anim.disconnect("anim_done", self, "on_anim_done")
		anim.queue_free()
		anim = null
	emit_signal("fx_finished")
