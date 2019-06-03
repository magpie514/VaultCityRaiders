extends "res://classes/library/lib_base.gd"
var skill = core.skill

#TODO: How it should work.
# Parts should have a -5===0===5 slider. You can upgrade the part up to +5 to allow moving the slider up to -X===+X.
# 0 is a balanced state.

const LIBEXT_AAAA = "aaaa"

var example = {
	"debug" : {
		"debug" : {
			name = ""
			partStats = {
				stat1 = 'ATK',
				stat2 = 'DEF'
				data = [
					[ # Stat 1                                    Stat 2
						[ 010,009,008,007, 005, 003,002,001,000 ],[ 000,001,002,003, 005, 007,008,009,010 ],
					]
				
				]
			}
		}
	}
}

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING },
	}
	
func loadDebug():
	loadDict(example)
