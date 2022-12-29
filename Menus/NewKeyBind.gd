extends PopupDialog

var action = ""
var _text = ""
var keybind = null
var isPressed = false

func _ready():
	popup_centered()
	call_deferred("updateAction")
	
func updateAction():
	_text = "Press a new key for \n" + "'' " + action + " ''"
	$CenterContainer / Label.text = _text
	keybind = Global.keybinds[action]
	
func _input(event):
	if event is InputEventKey and not isPressed:
		isPressed = true
		var pastEvents = InputMap.get_action_list(action)
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		var count = 0
		for i in pastEvents:
			if count > 0:
				InputMap.action_add_event(action, i)
			count += 1
		Global.getActions()
		queue_free()
