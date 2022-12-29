extends Node2D

enum DIRECTION{
	LEFT = - 1, 
	RIGHT = 1
}

export (DIRECTION) var moveDirection = DIRECTION.LEFT
export (String, FILE, "*JSON") var dialogue
export (String) var activateBeforeEvent
export (String) var activateAfterEvent

var Player

func _ready():
	call_deferred("init")
	
func init():
	Player = MainInstances.Player

func _on_Trigger_body_entered(player):
	if activateBeforeEvent != "" and activateBeforeEvent in Global.eventsDone:
		return 
	if activateAfterEvent != "" and not activateAfterEvent in Global.eventsDone:
		return 
	player.state = player.STATE.NOCONTROL
	yield (get_tree().create_timer(1.0), "timeout")
	var dia = Utils.startDialog(dialogue)
	dia.connect("tree_exited", self, "resume")
	
func resume():
	Player.cutSceneInputVector = Vector2(moveDirection, 0)
	yield (get_tree().create_timer(0.5), "timeout")
	Player.cutSceneInputVector = Vector2.ZERO
	Player.state = Player.STATE.MOVE
