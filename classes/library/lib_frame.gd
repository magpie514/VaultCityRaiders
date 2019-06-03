extends "res://classes/library/lib_base.gd"
var skill = core.skill

const LIBEXT_AAAA = "aaaa"

var example = {
	"debug" : {
		"debug" : {
			name = ""
		}
	}
}

func initTemplate():
	return {
		"name" : { loader = LIBSTD_STRING },
	}
	
func loadDebug():
	loadDict(example)
