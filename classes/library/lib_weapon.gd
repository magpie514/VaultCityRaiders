extends "res://classes/library/lib_base.gd"

const LIBEXT_SKILL_LIST = "loaderSkillList"


var example = {
	"debug" : {
		"debug": {
			name = "Unarmed", wclass = core.WPCLASS_NONE,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "bash"], ["debug", "debug"] ],
			over = ["debug", "debug"],
		},
		"debugg": {
			name = "Debug Gun", wclass = core.WPCLASS_HANDGUN,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "shoot"], ["debug", "debugi"] ],
			over = ["debug", "debug"]
		},
		"debugs": {
			name = "Debug Shield", wclass = core.WPCLASS_SHIELD,
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "kiragrd"], ["debug", "kiraprtc"] ],
			over = ["debug", "debug"]
		},
	},
	"story" : {
		"orbicann": {
			name = "ORBITAL Cannon", wclass = core.WPCLASS_ARTILLERY,
			description = "Jay's personal energy weapon. Despite having a shield, it's very lightweight. It also has a foldable barrel extension for focused shots.'",
			ATK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			ETK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["sto_wp", "sever"], ["sto_wp", "orbishld"] ],
			over = "story/thunswrd",
		},
		"fomablad": {
			name = "FOMALHAUT Blade", wclass = core.WPCLASS_LONGSWORD,
			description = "Energy blade belonging to Jay's mentor, Fomalhaut. It's capable of ranged combat as well as close quarters.",
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["sto_wp", "dualshrs"], ["sto_wp", "thoukniv"] ],
			over = ["sto_wp", "lighflam"]
		},
		"soldrifl": {
			name = "MTM-GA23 Solid Rifle", wclass = core.WPCLASS_FIREARM,
			description = "Magpie's custom sniper rail accelerator, created by herself. It fires solid metal rails containing a G-crystal spike at high velocities.'",
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "trikshot"], ["debug", "hyprshot"] ],
			over = ["debug", "debug"]
		},
		"bstglaiv": {
			name = "MTM-GA12 Boost Glaive", wclass = core.WPCLASS_POLEARM,
			description = "Magpie's custom glaive, created by herself. It's a glaive equipped with rocket boosters, G-crystals and shotgun shells, and is reinforced by graviton reflow.",
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [001, 001, 001, 001, 001, 001, 001, 001, 001, 000],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ "debug/shckstab", "story/gemshrap" ],
			over = "debug/debug"
		},
		"hellfngr": {
			name = "Hellfanger", wclass = core.WPCLASS_LONGSWORD,
			description = "Anna's custom sword. It's basically a chainsaw shaped like a sword, spinning at logic-defying speed thanks to Anna's own power.'",
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [008, 008, 008, 008, 007, 007, 007, 007, 007, 006],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "fireslsh"], ["debug", "wideslsh"] ],
			over = ["debug", "debug"]
		},
		"deviclaw": {
			name = "Raven's Claw", wclass = core.WPCLASS_ARTILLERY,
			description = "Custom made for Anna's strength, designed to be used against enemies of large size. A monstrous antitank cannon with a reinforced barrel equipped with foldable blades, allowing it to slash like a scythe at close quarters.'",
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [016, 016, 016, 016, 014, 014, 014, 014, 014, 010],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["debug", "fireslsh"], ["debug", "wideslsh"] ],
			over = ["debug", "debug"]
		},
		"ganrei": {
			name = "Ganreitou", wclass = core.WPCLASS_LONGSWORD,
			description = "Shiro's personal blade and family heirloom. Bloodthirsty sword forged by the legendary Muramasa out of Orihalcon. It has occult properties and is bound to Shiro's very soul. It's virtually indestructible.",
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [002, 002, 002, 002, 002, 002, 002, 002, 002, 000],
			durability = [50, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["sto_wp", "ganrei"], ["sto_wp", "reienzan"] ],
			over = "sto_wp/zanken"
		},
		"kokukou": {
			name = "Kokukouga", wclass = core.WPCLASS_SHORTSWORD,
			description = "Shiro's custom pair of support blades. Forged from Black Orihalconium, they are very lightweight and durable.",
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [002, 002, 002, 002, 002, 002, 002, 002, 002, 000],
			durability = [32, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ ["sto_wp", "jigenzan"], ["sto_wp", "retugiri"] ],
			over = ["debug", "debug"]
		},
		"polrstar": {
			name = "Polar Star", wclass = core.WPCLASS_HANDGUN,
			description = "Yukiko's pistol. An ornate masterpiece, one of the best of Makai. Every single component is subtly covered with magical scripts, making it more like a grimoire in the form of a pistol.",
			ATK =    [002, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK =    [015, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [002, 002, 002, 002, 000, 000, 000, 000, 000, 000],
			durability = [35, 34, 37, 42, 50, 53, 56, 59, 62, 70],
			skill = [ "sto_wp/snobulle", "sto_wp/calmshot" ],
			over = "sto_wp/valkaccl"
		},
		"plndevie": {
			name = "SGN-33-G Pleine-de-vie", wclass = core.WPCLASS_FIREARM,
			description = "Elodie's custom rifle. Uses fully-charged Neo-Heliolite crystals as ammunition, which can be released as solid, explosive shots, or as a potent energy burst.",
			ATK = [010, 012, 014, 016, 020, 022, 024, 026, 028, 032],
			ETK = [005, 007, 009, 009, 012, 015, 017, 019, 019, 022],
			weight = [009, 009, 009, 009, 005, 005, 005, 005, 004, 003],
			durability = [12, 14, 14, 16, 18, 18, 20, 22, 22, 24],
			skill = [ "sto_wp/solbull", "sto_wp/solbeam"],
			over = "sto_wp/heliosph",
		},
	}
}

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING },
		"description" : { loader = LIBSTD_STRING },
		"wclass" : { loader = LIBSTD_INT, default = core.WPCLASS_NONE },
		"ATK" : { loader = LIBSTD_SKILL_ARRAY },
		"ETK" : { loader = LIBSTD_SKILL_ARRAY },
		"weight" : { loader = LIBSTD_SKILL_ARRAY },
		"durability" : { loader = LIBSTD_SKILL_ARRAY },
		"skill" : { loader = LIBEXT_SKILL_LIST },
		"over" : { loader = LIBSTD_TID },
	}


func loadDebug():
	loadDict(example)
	print("Weapon library:")
	printData()

func name(id):
	var entry = getIndex(id)
	return entry.name if entry else "ERROR"

func loaderSkillList(val):
	if val == null:
		return [ null, null ]
	else:
		var result = [
			core.tid.from(val[0]) if val[0] != null else null,
			core.tid.from(val[1]) if val[1] != null else null,
		]
		return result
