extends Node2D

onready var mount1 = $Camera / CameraBackground / Parallax1 / BGCanyon
onready var mount2 = $Camera / CameraBackground / Parallax2 / BGCanyon2
onready var tw = $Tween
var player

export (String) var eventId = "Prologue"
export (Array, String, FILE, "*JSON") var dialogue

func _ready():
	call_deferred("init")
	if eventId in Global.eventsDone:
		return 
	tw.interpolate_property(mount1, "offset", mount1.offset + Vector2(0, 40), Vector2.ZERO, 5)
	tw.interpolate_property(mount2, "offset", mount2.offset + Vector2(0, 20), Vector2.ZERO, 5)
	tw.start()
	SFX.play("ShipLand")
	yield (get_tree().create_timer(5), "timeout")
	Events.emit_signal("screenShake", 2, 0.5)
	yield (get_tree().create_timer(3), "timeout")
	var dia = Utils.startDialog(dialogue[0])
	dia.connect("tree_exiting", self, "startGame")
	Global.eventsDone.append(eventId)
	
func init():
	player = MainInstances.Player
	player.connect("fired", self, "playerFired")
	if eventId in Global.eventsDone:
		return 
	player.state = player.STATE.NOCONTROL

func startGame():
	player.state = player.STATE.MOVE
	$NPC / Interact.active = true
	
func playerFired():
	$NPC / Interact.active = false
	player.state = player.STATE.NOCONTROL
	yield (get_tree().create_timer(1), "timeout")
	Utils.emote($NPC, 1, Vector2(0, - 50))
	var dia = Utils.startDialog(dialogue[1])
	dia.connect("tree_exiting", self, "startGame")
