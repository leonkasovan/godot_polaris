extends ColorRect

var paused = false setget setPaused
var options
signal unpaused

func setPaused(val):
	SFX.play("Select", 1, true)
	paused = val
	get_tree().paused = paused
	if paused:
		show()
		$CenterContainer / VBoxContainer / ResumeButton.grab_focus()
	else :
		hide()
	if self.paused:
		MainInstances.levelUI.visible = false
	else :
		if not MainInstances.Level.UIoff:
			MainInstances.levelUI.visible = true
		emit_signal("unpaused")

func _input(_event):
	if Input.is_action_just_pressed("pause"):
		var Player = MainInstances.Player
		if Player == null:
			return 
		if not paused:
			self.paused = true
		else :
			if options != null:
				options.queue_free()
			self.paused = false

func _on_ResumeButton_pressed():
	self.paused = false

func _on_OptionsButton_pressed():
	SFX.play("Select")
	options = load("res://Menus/Options.tscn").instance()
	add_child(options)
	options.connect("tree_exited", self, "onOptionsBack")
	$CenterContainer / VBoxContainer.hide()
	
func onOptionsBack():
	options = null
	$CenterContainer / VBoxContainer.show()
	$CenterContainer / VBoxContainer / ResumeButton.grab_focus()
	
func playBlip():
	SFX.play("Blip")
