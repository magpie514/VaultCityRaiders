extends Panel
var STYLE   = load("res://resources/tres/action_queue_item-stylebox.tres")
var style   = null
var pos:int = 0

func init(A:BattleState.Action, _pos:int) -> void: #A:Action
	style = STYLE.duplicate()
	pos = _pos
	set("custom_styles/panel", style)
	$Label.text = str("%s" % [A.user.name])
	if A.user is Player:
		style.bg_color = "66000088"
		$Warning.visible = false
	elif A.user is Enemy:
		style.bg_color = "66880000"
		$Warning.visible = A.skill.dangerous
		$Position.flip   = true
	if A.preview:
		style.bg_color = "55002F66"
	$Position.value = A.user.slot
