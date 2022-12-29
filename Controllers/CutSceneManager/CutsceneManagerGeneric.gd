extends Node2D

var Player:KinematicBody2D = null
var Ally:KinematicBody2D = null
export (String, FILE, "*.JSON") var dialogPath = null
export (String) var eventId
export (bool) var repositionEnabled = false
export  var playerReposition = Vector2()
export  var AllyReposition = Vector2()
export  var playerXScale = 1
export  var AllyXScale = 1

func _ready():
	call_deferred("init")

func init():
	Player = MainInstances.Player
	Ally = MainInstances.Ally

	TransitionCover.connect("repositionNow", self, "reposition")

func _on_Trigger_body_entered(player):
	if not eventId in Global.eventsDone:
		if repositionEnabled:
			Events.emit_signal("repositionEvent")
		else :
			noReposition()
		player.state = player.STATE.NOCONTROL
		Global.eventsDone.append(eventId)
		
func reposition():
	if Ally != null:
		Ally.state = Ally.STATE.NOCONTROL
		Ally.global_position = AllyReposition
		Ally.sprite.scale.x = AllyXScale
	Player.global_position = playerReposition
	Player.sprite.scale.x = playerXScale
	yield (get_tree().create_timer(1.0), "timeout")
	var dia = Utils.startDialog(dialogPath)
	dia.connect("tree_exited", self, "resume")
	
func noReposition():
	yield (get_tree().create_timer(1.0), "timeout")
	var dia = Utils.startDialog(dialogPath)
	dia.connect("tree_exited", self, "resume")
	Player.sprite.scale.x = playerXScale
	if Ally != null:
		Ally.sprite.scale.x = AllyXScale
	
func resume():
	Player.animOverride = false
	Player.state = Player.STATE.MOVE
	if Ally != null:
		Ally.state = Ally.STATE.MOVE
