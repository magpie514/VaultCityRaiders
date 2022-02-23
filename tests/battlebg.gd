#Standard battle background container.
extends Node2D

onready var cam:Node      = $Main/BattleCamera   #Contains scene camera.
onready var cursor:Node   = $Main/Cursor         #Constains the cursor displayed under the player character that is currently selecting an action.
onready var fxHook:Node2D = $Main/FXHook

var formation:Array    #Stores the nodes for all of the character's positions in each side.
var multitargets:Array #Stores targets for multitarget skills.

func _ready() -> void:
	#Assign arrays for formations.
	formation = [
		[   #Group 0, player side.
			$Main/Player/F1,$Main/Player/F2,$Main/Player/F3,
			$Main/Player/B1,$Main/Player/B2,$Main/Player/B3,
		],[ #Group 1, enemy side.
			$Main/Enemy/F1,$Main/Enemy/F2,$Main/Enemy/F3,
			$Main/Enemy/B1,$Main/Enemy/B2,$Main/Enemy/B3,
		]
	]
	multitargets = [
		[$Main/Player/GroupFX],
		[$Main/Enemy/GroupFX ]
	]
	cam.focusAnchor(fxHook)

func getCharAnchor(side:int, slot:int) -> Node:
	return formation[side][slot]

func setCursor(at:Node) -> void: #Move cursor to current character.
	cursor.global_position = at.global_position
	cursor.visible         = true
	cursor.z_index         = at.z_index - 20

func hideCursor() -> void:
	cursor.visible = false

func init(group) -> void: #TODO: Use this later, properly.
	print("[BATTLEBG] Remember I exist!")
	var bgf = load("res://tests/bgtest_01.tscn").instance()
	$BG.add_child(bgf)
	cam.focusAnchor($Main/Enemy)
