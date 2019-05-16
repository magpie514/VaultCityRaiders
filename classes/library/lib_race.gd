extends "res://classes/library/lib_base.gd"
var skill = core.skill

var example = {
	"debug" : {
		"debug" : {
			name = "DEBUG",
			description = "This is a debug class with ridiculously high stat growth.",
			#               HP   ATK  DEF  ETK  EDF  AGI  LUC    HP   ATK  DEF  ETK  EDF  AGI  LUC
			statSpread = [ [050, 010, 010, 010, 010, 010, 010], [999, 255, 255, 255, 255, 255, 255] ],
			aspect = skill.RACEF_MEC,
			race = [ skill.RACE_MACHINE ],
		},
		

		"human" : { #Humans should be able to change races to cyborg naturally during the game.
			name = "Human",
			description = "The third of the three races engineered by Tiamat, the Originator. They have an inherent affinity to technology.",
			statSpread = [ [045, 011, 013, 011, 010, 013, 014], [460, 120, 135, 100, 090, 130, 150] ],
			aspect = skill.RACEF_BIO|skill.RACEF_SPI,
			race = [ skill.RACE_HUMAN ],
		},
		"cyborg" : {
			name = "Cyborg",
			description = "A human partially augmented by technology. They are limited by their human bodies, but their augments allow for higher potential.",
			statSpread = [ [035, 010, 012, 010, 008, 012, 013], [380, 100, 100, 100, 075, 125, 120] ],
			aspect = skill.RACEF_BIO|skill.RACEF_SPI|skill.RACEF_MEC,
			flags = [ skill.RACE_HUMAN, skill.RACE_MACHINE ],
		},
		"elf" : {
			name = "Elf",
			description = "A human with fairy blood, which raises their affinity to nature and the elements.",
			statSpread = [ [040, 009, 010, 012, 012, 014, 011], [410, 090, 094, 140, 135, 140, 110] ],
			aspect = skill.RACEF_BIO|skill.RACEF_SPI,
			race = [ skill.RACE_HUMAN, skill.RACE_FAIRY ],
		},
		"vampire" : {
			name = "Vampire",
			description = "Humans afflicted by a dark curse, turning them undead and requiring blood to live. A perfected form of ghoul.",
			statSpread = [ [048, 013, 012, 013, 011, 012, 005], [500, 135, 130, 135, 100, 125, 035] ],
			aspect = skill.RACEF_BIO|skill.RACEF_SPI,
			race = [ skill.RACE_HUMAN, skill.RACE_UNDEAD ],
		},
		"skeleton" : { #There you go, I hope you are happy.
			name = "Skeleton",
			description = "Was once human, then died, then got back, all boney. But with a constant smile.",
			statSpread = [ [048, 013, 012, 013, 011, 012, 005], [500, 135, 130, 135, 100, 125, 035] ],
			aspect = skill.RACEF_BIO|skill.RACEF_SPI,
			race = [ skill.RACE_HUMAN, skill.RACE_UNDEAD ],
		},
		"robot" : {
			name = "Robot",
			description = "A race created by humans. They AI and physical capabilities are highly variable, but their potential is tied to their equipment.",
			statSpread = [ [060, 015, 015, 015, 010, 010, 005], [520, 150, 165, 120, 090, 110, 085] ],
			aspect = skill.RACEF_SPI|skill.RACEF_MEC,
			flags = [ skill.RACE_MACHINE ],
		},
		"choujin" : { #Mostly story mode exclusive. Could probably look into making it a stronger but less versatile version of robots, like you get some initial picks and you get stuck with them.
			name = "Choujin",
			description = "One of the potential ultimate forms of humanity. A human soul in a full machine body. Being a type of robot, their potential is also tied to their equipment",
			statSpread = [ [060, 015, 015, 015, 010, 010, 005], [520, 150, 165, 120, 090, 110, 085] ],
			aspect = skill.RACEF_SPI|skill.RACEF_MEC,
			player = false,
			flags = [ skill.RACE_MACHINE ],
		},
		"fairy" : {  #The best class for energy attackers.
			name = "Fairy",
			description = "The second of the three races engineered by Tiamat, the Originator. They have an inherent affinity to nature and the elements.",
			statSpread = [ [040, 008, 008, 014, 014, 013, 010], [415, 090, 085, 150, 150, 130, 100] ],
			aspect = skill.RACEF_BIO|skill.RACEF_SPI,
			flags = [ skill.RACE_FAIRY ],
		},
		"dracon" : {  #I need a good name for this.
			name = "??????", #This race should be the regular player-usable instance of dragon and act like Breath of Fire or something.
			description = "A human with dragon blood, which raises their affinity to power. They can change into a dragon form.",
			statSpread = [ [065, 014, 011, 014, 012, 013, 005], [600, 145, 120, 145, 130, 135, 050] ],
			aspect = skill.RACEF_BIO|skill.RACEF_SPI,
			flags = [ skill.RACE_HUMAN, skill.RACE_DRAGON ],
		},
		"dragon" : {  #This race I don't know what to do with. Dragons are supposed to be ridiculously powerful in this setting.
			name = "Dragon",
			description = "The first of the three races engineered by Tiamat, the Originator, and the closest to her heart. They have an inherent affinity to power.",
			statSpread = [ [065, 014, 011, 014, 012, 013, 005], [600, 145, 120, 145, 130, 135, 050] ],
			aspect = skill.RACEF_BIO|skill.RACEF_SPI,
			player = false,
			flags = [ skill.RACE_DRAGON ],
		},
		"god" : {     #Not available on player creation. I think. Maybe unlockable or cheaty?
			name = "God",  #This is just some fantasy bull and not meant to represent anyone's view of theology.
			description = "Higher beings born from the power of belief. Their power is tied to the prayer of their believers.",
			statSpread = [ [065, 014, 011, 014, 012, 013, 005], [600, 145, 120, 145, 130, 135, 050] ],
			aspect = skill.RACEF_SPI,
			player = false,
			flags = [ skill.RACE_GOD ],
		},
		"origin" : {  #Only for Tiamat and Cromwell.
			name = "Originator",
			description = "Born from the primordial chaos, Originators are gifted with the power to create universes. Only two are known to exist.",
			statSpread = [ [065, 014, 011, 014, 012, 013, 005], [600, 145, 120, 145, 130, 135, 050] ],
			aspect = skill.RACEF_SPI,
			player = false,
			flags = [ skill.RACE_ORIGINATOR ],
		},
	}
}

func initTemplate():
	return {
		"name": { loader = LIBSTD_STRING },
		"description": { loader = LIBSTD_STRING },
		"statSpread": { loader = LIBSTD_STATSPREAD },
		"aspect" : { loader = LIBSTD_INT },
		"player" : { loader = LIBSTD_BOOL, default = true },
		"skills" : { loader = LIBSTD_SKILL_LIST },
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



# Main objective
# Core races should be generally suited for urban fantasy scenarios. Shadowrun but more anime, basically.
# Due to the multiversal nature of the Vaults and the various worlds in "Creation" (capitalized),
# technically anything goes, but the "core" world, Origin, is meant to be pretty advanced with
# scifi and fantasy elements. Basically an alternate version of Earth where legends and heroes are a thing.
# So yes you can technically have a French elf blasting Lemurian robots in the nega-verse or something.


# In this setting, the Originator Tiamat engineered three base races with higher conscience.
# Dragons, the closest to her, inherited the ability to manipulate "power", being able to absorb or
# transfer "things" like strength, courage, elemental energies and whatever.
# 	They are basically OP and will ruin your day. Do not piss them off.
# Faeries came second, inherited the ability to interact with the forces of nature, astral bodies,
# and the contents of the universe at large.
# 	They are more balanced but can also ruin your day. Do not piss them off.
# And last came humans, with the ability to create their own power.
# 	They are the flimsiest ones but it's generally advised to not piss them off too much.
# All other races came to be from natural causes but still following a link to her imagination.
# If she imagines dog, dog will happen somewhere.
# And then there's the Eldritch which are created naturally by the primordial chaos, but aren't
# proper beings, and they can be pretty much anything. Absolute wildcards.
#		Pissing them off could mean nothing, a lucky day, or the eradication of all sentient life.

# Tiamat mostly leaves the races alone to evolve free, but all worlds contain or have
# contained dragons, faeries and humans at the very least. Or have "attempted" to. Within these rules
# a place like real life Earth would be one where only humans managed to thrive due to whatever conditions
# with no dragons or fairies for magic to be a thing, but they still manifest as legends.
# Thus xenos and other "not rubber forehead" alien worlds would be the work of the Eldritch and it's
# an absolute ball of whatever in that case.
