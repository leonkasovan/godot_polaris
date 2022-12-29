extends Node2D

var Player:KinematicBody2D = null
export (Array, String, FILE, "*.JSON") var dialogPath = null
export (Array, String) var eventID = ["L6_Preboss", "L6_Postboss"]
export (Vector2) var reposition
export (PackedScene) var Wing

func _ready():
	call_deferred("init")

func init():
	Player = MainInstances.Player

	$Boulder.connect("destroyed", self, "onBoulderDestroy")

	TransitionCover.connect("repositionNow", self, "repositionPlayer")

func _on_Trigger_body_entered(player):
	if not eventID[0] in Global.eventsDone:
		Global.eventsDone.append(eventID[0])
		player.state = player.STATE.NOCONTROL
		startDialog(0)
		SFX.play("Radio")
		
func onBoulderDestroy():
	if not eventID[1] in Global.eventsDone:
		Global.eventsDone.append(eventID[1])
	Utils.emote($WingNPC, 0, Vector2(0, - 50))
	yield (get_tree().create_timer(1.0), "timeout")
	Events.emit_signal("repositionEvent")
		
func repositionPlayer():
	Player.global_position = reposition
	Player.state = Player.STATE.NOCONTROL
	Player.sprite.scale.x = 1
	Utils.instanceScene(Wing, $WingNPC.global_position)
	$WingNPC.queue_free()
	startDialog(1)
		
func startDialog(num):
	yield (get_tree().create_timer(1.5), "timeout")
	var dia = Utils.startDialog(dialogPath[num])
	dia.connect("tree_exited", self, "resume")
	
func resume():
	Player.state = Player.STATE.MOVE
