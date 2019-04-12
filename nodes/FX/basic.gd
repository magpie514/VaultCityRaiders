extends Node2D
signal anim_done

func play(spd):
	$AnimationPlayer.playback_speed = spd
	$Particles2D.speed_scale = spd
	$AnimationPlayer.play("New Anim")

func done():
	emit_signal("anim_done")

func pos(x):
	global_position = x

func _on_AnimationPlayer_animation_finished(x):
	emit_signal("anim_done")
	queue_free()
