extends Panel

var _dmgNum = preload("res://nodes/UI/damage_numbers.tscn")

var damageDelay = 0
var damageQueue = []

func init(c):
	set_process(true)

func popDamageNums():
	if damageQueue.size() > 0:
		var v = damageQueue.pop_front()
		var d = _dmgNum.instance()
		add_child(d)
		d.init(v)
		damageDelay = 32

func damage(x):
	damageQueue.push_back(x)
	if damageDelay == 0:
		damageDelay = 1
	show()

func _process(delta):
	if damageDelay > 0:
		damageDelay -= 1
		if damageDelay == 0:
			popDamageNums()

func _on_Button_pressed():
	damage([[9999, randi()%2, randi()%2, randi() % 3]])

func _on_Button2_pressed():
	damage([[-9999, false, false, false]])

func _on_Button3_pressed():
	damage(["PARALYSIS", [false, false, randi() % 3], "FFFF00"])


func _on_Button4_pressed() -> void:
	var D = []
	for i in range(2 + (randi() % 5)):
		D.push_back([32000, randi()%2, randi()%2, randi() % 3])
	damage(D)
