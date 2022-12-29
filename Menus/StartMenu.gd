extends Control

onready var buttons = $VBoxContainer.get_children()
onready var main = get_parent()

func _ready():
	$VBoxContainer / StartButton.grab_focus()
	if Global.lastRoom == "":
		$VBoxContainer / ContinueButton.disabled = true
	for button in buttons:
		button.connect("focus_entered", self, "playBlip")
		button.connect("pressed", self, "playSelect")
		
func playBlip():
	SFX.play("Blip")
	
func playSelect():
	SFX.play("Select", 1, true)

func _on_StartButton_pressed():
	Global.clearSave()
	Music.play("FirstFlight", 5.0)
	SFX.play("Start")
	for button in buttons:
		button.hide()
	$TitleRect.hide()
	$MenuControls.hide()
	main.playStart()
	
func fadeToStart():
	Events.emit_signal("roomTransitionSlow", "res://Levels/Level_0_Bridge.tscn", 3.0)
	
func _on_ContinueButton_pressed():
	Events.emit_signal("roomTransitionSlow", Global.lastRoom)
	Music.stop(3.0)
	SFX.play("Start")
	for button in buttons:
		button.hide()
	Game.testTimer.start()

func _on_OptionsButton_pressed():
	var options = load("res://Menus/Options.tscn").instance()
	add_child(options)
	options.connect("tree_exited", self, "onOptionsBack")
	$VBoxContainer.hide()
	$TitleRect.hide()
	
func _on_QuitButton_pressed():
	get_tree().quit()
	
func onOptionsBack():
	$VBoxContainer / OptionsButton.grab_focus()
	$VBoxContainer.show()
	$TitleRect.show()
	
func _process(_delta):
	if has_focus():
		$VBoxContainer / StartButton.grab_focus()
