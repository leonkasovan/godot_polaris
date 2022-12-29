extends Node2D

export (Array, String, FILE, "*.JSON") var dialogPath = null
export (bool) var interactOnly = false
export (bool) var active = true
export (bool) var diaShowTop = false
export (String) var beforeEvent
export (String) var afterEvent

var currentDialogue = 0
var canSpeak = false
var Player
onready var parent = get_parent()

signal interact

func _ready():
	call_deferred("init")
	
func init():
	Player = MainInstances.Player

func _input(_event):
	if beforeEvent != "" and beforeEvent in Global.eventsDone:
		return 
	if afterEvent != "" and not afterEvent in Global.eventsDone:
		return 
	if Player != null:
		if (canSpeak and active and 
		Input.is_action_just_pressed("use")):
			if not interactOnly:
				var dialog = Utils.startDialog(dialogPath[currentDialogue], diaShowTop)
				dialog.connect("tree_exited", self, "onDialogEnd")
				canSpeak = false
				Player.useIndicator.visible = false
				Player.state = Player.STATE.NOCONTROL
				Player.dashTimer.stop()
				active = false
				Utils.playerFace(parent)
			else :
				emit_signal("interact")
				Player.useIndicator.visible = false

func _process(_delta):
	if beforeEvent != "" and beforeEvent in Global.eventsDone:
		return 
	if afterEvent != "" and not afterEvent in Global.eventsDone:
		return 
	var colliders = $Area2D.get_overlapping_bodies()
	if Player in colliders:
		var useButton = Global.keybinds["use"]
		var scancode = useButton[0].get_scancode()
		if active:
			canSpeak = true
			Player.useIndicator.visible = canSpeak
			Player.useIndicator.text = OS.get_scancode_string(scancode)
			return 
	canSpeak = false

func onDialogEnd():
	canSpeak = true
	if Player != null:
		Player.useIndicator.visible = canSpeak
		Player.state = Player.STATE.MOVE
		currentDialogue = min(len(dialogPath) - 1, currentDialogue + 1)
		active = true

func _on_Area2D_body_exited(_body):
	Player.useIndicator.visible = false
