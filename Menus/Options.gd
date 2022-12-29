extends Control

var keys = []
var buttons = []
var dupes = false
onready var lastKey = $BackButton

func _ready():
	initiateActions()
	$CenterContainer / HBoxContainer / Others / SFXSlider.value = SFX.sfxVolume
	$CenterContainer / HBoxContainer / Others / MusicSlider.value = Music.musicVolume
	$CenterContainer / HBoxContainer / Others / CheckBox.pressed = OS.is_window_fullscreen()
	
func initiateActions():
	keys.clear()
	buttons.clear()
	
	var action = Global.keybinds["left"]
	var scanCode = action[0].get_scancode()
	keys.append(scanCode)
	$CenterContainer / HBoxContainer / KeyboardControls / Left / Label.text = OS.get_scancode_string(scanCode)
	action = Global.keybinds["right"]
	scanCode = action[0].get_scancode()
	keys.append(scanCode)
	$CenterContainer / HBoxContainer / KeyboardControls / Right / Label.text = OS.get_scancode_string(scanCode)
	action = Global.keybinds["up"]
	scanCode = action[0].get_scancode()
	keys.append(scanCode)
	$CenterContainer / HBoxContainer / KeyboardControls / Up / Label.text = OS.get_scancode_string(scanCode)
	action = Global.keybinds["down"]
	scanCode = action[0].get_scancode()
	keys.append(scanCode)
	$CenterContainer / HBoxContainer / KeyboardControls / Down / Label.text = OS.get_scancode_string(scanCode)
	action = Global.keybinds["shoot"]
	scanCode = action[0].get_scancode()
	keys.append(scanCode)
	$CenterContainer / HBoxContainer / KeyboardControls / Shoot / Label.text = OS.get_scancode_string(scanCode)
	action = Global.keybinds["jump"]
	scanCode = action[0].get_scancode()
	keys.append(scanCode)
	$CenterContainer / HBoxContainer / KeyboardControls / Jump / Label.text = OS.get_scancode_string(scanCode)
	action = Global.keybinds["dash"]
	scanCode = action[0].get_scancode()
	keys.append(scanCode)
	$CenterContainer / HBoxContainer / KeyboardControls / Dash / Label.text = OS.get_scancode_string(scanCode)
	action = Global.keybinds["use"]
	scanCode = action[0].get_scancode()
	keys.append(scanCode)
	$CenterContainer / HBoxContainer / KeyboardControls / Use / Label.text = OS.get_scancode_string(scanCode)
	action = Global.keybinds["special"]
	scanCode = action[0].get_scancode()
	keys.append(scanCode)
	$CenterContainer / HBoxContainer / KeyboardControls / Special / Label.text = OS.get_scancode_string(scanCode)
	action = Global.keybinds["map"]
	scanCode = action[0].get_scancode()
	keys.append(scanCode)
	$CenterContainer / HBoxContainer / KeyboardControls / Map / Label.text = OS.get_scancode_string(scanCode)
	
	action = Global.keybinds["shoot"]
	var buttonName = action[1].get_button_index()
	buttons.append(buttonName)
	$CenterContainer / HBoxContainer / GamepadControls / Shoot / Label.text = str(Game.gpButtons[buttonName])
	action = Global.keybinds["jump"]
	buttonName = action[1].get_button_index()
	buttons.append(buttonName)
	$CenterContainer / HBoxContainer / GamepadControls / Jump / Label.text = str(Game.gpButtons[buttonName])
	action = Global.keybinds["dash"]
	buttonName = action[1].get_button_index()
	buttons.append(buttonName)
	$CenterContainer / HBoxContainer / GamepadControls / Dash / Label.text = str(Game.gpButtons[buttonName])
	action = Global.keybinds["use"]
	buttonName = action[1].get_button_index()
	buttons.append(buttonName)
	$CenterContainer / HBoxContainer / GamepadControls / Use / Label.text = str(Game.gpButtons[buttonName])
	action = Global.keybinds["special"]
	buttonName = action[1].get_button_index()
	buttons.append(buttonName)
	$CenterContainer / HBoxContainer / GamepadControls / Special / Label.text = str(Game.gpButtons[buttonName])
	action = Global.keybinds["map"]
	buttonName = action[1].get_button_index()
	buttons.append(buttonName)
	$CenterContainer / HBoxContainer / GamepadControls / Map / Label.text = str(Game.gpButtons[buttonName])

	dupes = Utils.checkForDupes(keys) or Utils.checkForDupes(buttons)
	if dupes == true:
		$BackButton.text = "ERROR: Duplicate Controls"
	else :
		$BackButton.text = "BACK"
	lastKey.grab_focus()
	
func _on_BackButton_pressed():
	playSelect()
	if not dupes:
		Global.saveKeyBinds()
		queue_free()
	
func popupDone():
	call_deferred("initiateActions")
	show()
	
func checkForJoypad():
	return Input.get_connected_joypads().size() > 0

func showPopup(_action):
	var popup = load("res://Menus/NewKeyBind.tscn").instance()
	add_child(popup)
	popup.action = _action
	popup.connect("tree_exited", self, "popupDone")
	self.hide()
	
func showPopupButton(_action):
	var popup = load("res://Menus/NewButtonBind.tscn").instance()
	add_child(popup)
	popup.action = _action
	popup.connect("tree_exited", self, "popupDone")
	self.hide()

func _on_Left_pressed():
	playSelect()
	showPopup("left")
	lastKey = $CenterContainer / HBoxContainer / KeyboardControls / Left / Left

func _on_Right_pressed():
	playSelect()
	showPopup("right")
	lastKey = $CenterContainer / HBoxContainer / KeyboardControls / Right / Right

func _on_Up_pressed():
	playSelect()
	showPopup("up")
	lastKey = $CenterContainer / HBoxContainer / KeyboardControls / Up / Up

func _on_Down_pressed():
	playSelect()
	showPopup("down")
	lastKey = $CenterContainer / HBoxContainer / KeyboardControls / Down / Down

func _on_Shoot_pressed():
	playSelect()
	showPopup("shoot")
	lastKey = $CenterContainer / HBoxContainer / KeyboardControls / Shoot / Shoot

func _on_Jump_pressed():
	playSelect()
	showPopup("jump")
	lastKey = $CenterContainer / HBoxContainer / KeyboardControls / Jump / Jump

func _on_Dash_pressed():
	playSelect()
	showPopup("dash")
	lastKey = $CenterContainer / HBoxContainer / KeyboardControls / Dash / Dash

func _on_Use_pressed():
	playSelect()
	showPopup("use")
	lastKey = $CenterContainer / HBoxContainer / KeyboardControls / Use / Use
	
func _on_Special_pressed():
	playSelect()
	showPopup("special")
	lastKey = $CenterContainer / HBoxContainer / KeyboardControls / Special / Special

func _on_Map_pressed():
	playSelect()
	showPopup("map")
	lastKey = $CenterContainer / HBoxContainer / KeyboardControls / Map / Map
	
func playSelect():
	SFX.play("Select", 1, true)
	
func playBlip():
	SFX.play("Blip")

func _on_SFXSlider_value_changed(value):
	SFX.sfxVolume = value

func _on_MusicSlider_value_changed(value):
	Music.musicVolume = value

func _on_CheckBox_pressed():
	if OS.is_window_fullscreen():
		OS.set_window_fullscreen(false)
	else :
		OS.set_window_fullscreen(true)
	SFX.play("Select", 1, true)


func _on_ShootB_pressed():
	if not checkForJoypad():
		return 
	playSelect()
	showPopupButton("shoot")
	lastKey = $CenterContainer / HBoxContainer / GamepadControls / Shoot / ShootB
