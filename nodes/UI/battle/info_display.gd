extends Panel
var parent = null

func _ready():
	hide_all()
	hide()

func init(_parent):
	parent = _parent

func hide_all():
	$SkillDisplay.hide()
	$PlayerDisplay.hide()
	$EnemyInfoDisplay.hide()

func showPlayer(C):
	hide_all()
	$PlayerDisplay.showChar(C)
	$PlayerDisplay.show()

func showEnemy(C):
	hide_all()
	$EnemyInfoDisplay.showChar(C)
	$EnemyInfoDisplay.show()

func showSkill(S, level):
	hide_all()
	$SkillDisplay.init(S, level)
	$SkillDisplay.show()