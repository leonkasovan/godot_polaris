extends Control

var canPress = true

func _ready():
	$Tween.interpolate_property($ColorRect, "modulate", Color(1, 1, 1, 1), Color(0, 0, 0, 0), 1.0)
	$Tween.start()
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if not canPress:
			return 
		canPress = true
		Music.play("MainMenu")
		Events.emit_signal("roomTransitionSlow", "res://Menus/MainMenu.tscn")
		$Timer.stop()

func _on_Timer_timeout():
	canPress = false
	Music.play("MainMenu")
	Events.emit_signal("roomTransitionSlow", "res://Menus/MainMenu.tscn")
