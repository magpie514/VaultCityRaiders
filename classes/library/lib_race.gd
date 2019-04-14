extends "res://classes/library/lib_base.gd"

var example = {
	"debug" : {
		"debug" : {
			name = "DEBUG",
			description = "This is a debug class with ridiculously high stat growth.",
			#               HP   ATK  DEF  ETK  EDF  AGI  LUC    HP   ATK  DEF  ETK  EDF  AGI  LUC
			statSpread = [ [050, 010, 010, 010, 010, 010, 010], [999, 255, 255, 255, 255, 255, 255] ],
			#flags = RACE_MACHINE,
		},
		"human" : {
			name = "Human",
			description = "The third of the three races engineered by Tiamat, the Originator. They have an inherent affinity to technology.",
			statSpread = [ [045, 011, 013, 011, 010, 013, 014], [460, 120, 135, 100, 090, 130, 150] ],
			#flags = RACE_HUMAN,
		},
		"elf" : {
			name = "Elf",
			description = "A human with fairy blood, which raises their affinity to nature and the elements.",
			statSpread = [ [040, 009, 010, 012, 012, 014, 011], [410, 090, 094, 140, 135, 140, 110] ],
			#flags = RACE_HUMAN|RACE_FAIRY,
		},
		"vampire" : {
			name = "Vampire",
			description = "Humans afflicted by a dark curse, turning them undead and requiring blood to live. A perfected form of ghoul.",
			statSpread = [ [048, 013, 012, 013, 011, 012, 005], [500, 135, 130, 135, 100, 125, 035] ],
			#flags = RACE_HUMAN|RACE_UNDEAD,
		},
		"cyborg" : {
			name = "Cyborg",
			description = "A human partially augmented by technology. They are limited by their human bodies, but their augments allow for higher potential.",
			statSpread = [ [035, 010, 012, 010, 008, 012, 013], [380, 100, 100, 100, 075, 125, 120] ],
			#flags = RACE_HUMAN|RACE_MACHINE,
		},
		"choujin" : {
			name = "Choujin",
			description = "One of the potential ultimate forms of humanity. A human soul in a full machine body.",
			statSpread = [ [060, 015, 015, 015, 010, 010, 005], [520, 150, 165, 120, 090, 110, 085] ],
			#flags = RACE_MACHINE,
		},
		"fairy" : {
			name = "Fairy",
			description = "The second of the three races engineered by Tiamat, the Originator. They have an inherent affinity to nature and the elements.",
			statSpread = [ [040, 008, 008, 014, 014, 013, 010], [415, 090, 085, 150, 150, 130, 100] ],
			#flags = RACE_FAIRY,
		},
		"dragon" : {
			name = "Dragon",
			description = "The first of the three races engineered by Tiamat, the Originator. They have an inherent affinity to power. They can change to a human form when needed.",
			statSpread = [ [065, 014, 011, 014, 012, 013, 005], [600, 145, 120, 145, 130, 135, 050] ],
			#flags = RACE_DRAGON,
		},
	}
}

func initTemplate():
	return {
		"name": { loader = LIBSTD_STRING },
		"description": { loader = LIBSTD_STRING },
		"statSpread": { loader = LIBSTD_STATSPREAD },
	}

func loadDebug():
	loadDict(example)
	print("Race library:")
	#printData()

func name(id):
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"

func getStatSpread(id):
	var entry = getIndex(id)
	return entry.statSpread

func printData():
	var entry = null
	for key1 in data:
		print("[%8s]" % key1)
		for key2 in data[key1]:
			entry = data[key1][key2]
			print(" [%8s]\n  Name: %12s\n  Stats[HP:%03d-%03d|ATK:%03d-%03d|DEF:%03d-%03d|ETK:%03d-%03d|EDF:%03d-%03d|AGI:%03d-%03d|LUC:%03d-%03d]\n  Desc: %s" %
				[
					key2,
					entry.name,
					entry.statSpread[0][0], entry.statSpread[1][0],
					entry.statSpread[0][1], entry.statSpread[1][1],
					entry.statSpread[0][2], entry.statSpread[1][2],
					entry.statSpread[0][3], entry.statSpread[1][3],
					entry.statSpread[0][4], entry.statSpread[1][4],
					entry.statSpread[0][5], entry.statSpread[1][5],
					entry.statSpread[0][6], entry.statSpread[1][6],
					entry.description,
			  ])
