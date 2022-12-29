extends Control

var canPress = false

func _ready():
	Global.health = Global.maxHealth
	Global.stamina = Global.maxStamina
	Global.healthAlly = Global.maxHealthAlly
	yield (get_tree().create_timer(3.0), "timeout")
	canPress = true

func _process(_delta):
	if not canPress:
		return 
	if Input.is_action_just_pressed("ui_accept"):
		Events.emit_signal("roomTransitionSlow", "res://Menus/MainMenu.tscn", 2.0)
		SFX.play("Select", 1, true)
		canPress = false
