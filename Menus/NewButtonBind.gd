extends PopupDialog

var action = ""
var _text = ""
var keybind = null

func _ready():
	popup_centered()
	call_deferred("updateAction")
	
func updateAction():
	_text = "Press a new button for \n" + "'' " + action + " ''"
	$CenterContainer / Label.text = _text
	keybind = Global.keybinds[action]
	
func _input(event):
	if event is InputEventJoypadButton:
		if event.button_index in Game.gpButtons:
			InputMap.action_erase_event(action, keybind[1])
			InputMap.action_add_event(action, event)
			Global.getActions()
			queue_free()
