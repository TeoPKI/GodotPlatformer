extends Label

export var variable: String


func _ready():
	text = "\"" + variable + "\"" + ": " + "N/A"

func _on_Blackboard_data_changed(key, data):
	if(key == variable):
		text = var2str(key) + ": " + var2str(data)
