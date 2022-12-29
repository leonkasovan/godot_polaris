extends Node2D

export (Array, Resource) var wingEvent
export (String) var afterEvent = "L5_Postboss"
onready var BG = [$Camera / CameraBackground / Parallax0 / Sprite, $Camera / CameraBackground / Sky / BGPrologue, $Camera / CameraBackground / Parallax1 / BGCanyon, $Camera / CameraBackground / Parallax2 / BGCanyon2]
var event1Done = false

func _ready():
	if afterEvent in Global.eventsDone:
		call_deferred("init")

func init():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.queue_free()
	$Wing / HurtBox / CollisionShape2D.disabled = true
	$Wing.global_position = Vector2(680, 128)
	$Wing.state = $Wing.STATE.NOCONTROL
	$Wing.anim.play("Idle")
	Music.play("ColdBreeze")
	$Camera / CameraBackground / Parallax0 / Smoke.emitting = true
	$Camera / CameraBackground / Parallax0 / Sprite.texture = load("res://World/SpaceShipDestroyedBG.png")
	for spawner in $Spawners.get_children():
		spawner.spawn()
	for spawner in $Spawners2.get_children():
		spawner.spawn()
	for bg in BG:
		bg.modulate = Color("ff5959")
	MainInstances.Level.isDark = true
	MainInstances.Level.init()
	for light in get_tree().get_nodes_in_group("FlickerLight"):
		light.init()
	$Embers.emitting = true
	
func _on_WingEventAnimationTrigger_body_entered(_body):
	if afterEvent in Global.eventsDone and not event1Done:
		$Wing.state = $Wing.STATE.EVENT
		$Wing.EventPlayer.add_animation("Event", wingEvent[0])
		$Wing.EventPlayer.play("Event")
		event1Done = true

func _on_Boulder_destroyed():
	$Wing.state = $Wing.STATE.EVENT
	$Wing.EventPlayer.add_animation("Event2", wingEvent[1])
	$Wing.EventPlayer.play("Event2")
