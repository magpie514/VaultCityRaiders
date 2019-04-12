extends Node
signal timeout
signal skill_finished
signal fx_finished
signal skill_special_finished
signal follows_finished
signal action_finished

var subControlNode = preload("res://nodes/SkillControlSub.tscn")

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
	print("FOLLOW FINISHED SIGNAL")
	emit_signal("follows_finished")

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

func startAnim(x, display):
	anim = load("res://nodes/FX/basic.tscn").instance()
	add_child(anim)
	anim.pos(display.get_global_rect().position + (display.get_global_rect().size / 2))
	anim.connect("anim_done", self, "on_anim_done")
	anim.play(6.0)

func _on_FXTimer_timeout():
	emit_signal("timeout")

func on_anim_done():
	if anim != null:
		anim.disconnect("anim_done", self, "on_anim_done")
		anim.queue_free()
		anim = null
	emit_signal("fx_finished")
