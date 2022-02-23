extends Panel
var parent = null

func _ready() -> void:
	hide_all()
	hide()

func init(_parent):
	parent = _parent

func hide_all() -> void:
	$SkillDisplay.hide()
	$PlayerDisplay.hide()
	$EnemyInfoDisplay.hide()

func showPlayer(C) -> void:
	hide_all()
	$PlayerDisplay.showChar(C)
	$PlayerDisplay.show()

func showEnemy(C) -> void:
	hide_all()
	$EnemyInfoDisplay.showChar(C)
	$EnemyInfoDisplay.show()

func showSkill(S, level) -> void:
	hide_all()
	$SkillDisplay.init(S, level)
	$SkillDisplay.show()
