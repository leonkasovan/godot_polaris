extends Node2D

export (Array, String, FILE, "*.JSON") var dialogPath = null
export (Array, String) var eventId = null
onready var Player = MainInstances.Player
		
func _on_Boulder2_destroyed():
	if eventId[0] in Global.eventsDone:
		return 
	yield (get_tree().create_timer(1.0), "timeout")
	Player.state = Player.STATE.NOCONTROL
	yield (get_tree().create_timer(1.0), "timeout")
	var dia = Utils.startDialog(dialogPath[0], true)
	dia.connect("tree_exited", self, "diaEnd")
	
func diaEnd():
	Player.state = Player.STATE.MOVE
	Global.eventsDone.append(eventId[0])
