extends "res://classes/char/char_enemy.gd"
class_name EnemyBoss

# Boss stats ##################################################################
var phase:int = 0  #Boss current phase.
var totalPhases:int = 0 #Boss total phases

func init(C) -> void:
	side = 1
	lib  = C
	ID   = randi()
	name = str(lib.name)
	recalculateStats()