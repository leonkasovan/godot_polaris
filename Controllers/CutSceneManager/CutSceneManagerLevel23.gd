extends Node2D

export (Resource) var wingEvent
onready var BG = [$Camera / CameraBackground / Parallax0 / Sprite, $Camera / CameraBackground / Sky / BGPrologue, $Camera / CameraBackground / Parallax1 / BGCanyon, $Camera / CameraBackground / Parallax2 / BGCanyon2]
var event1Done = false

func _ready():
	call_deferred("init")

func init():
	$Wing / HurtBox / CollisionShape2D.disabled = true
	$Wing.state = $Wing.STATE.EVENT
	$Wing.EventPlayer.add_animation("Event", wingEvent)
	$Wing.EventPlayer.play("Event")
	Music.play("ColdBreeze", 0)
	$Camera / CameraBackground / Parallax0 / Smoke.emitting = true
	$Camera / CameraBackground / Parallax0 / Sprite.texture = load("res://World/SpaceShipDestroyedBG.png")
	for spawner in $Spawners.get_children():
		spawner.spawn()
	for bg in BG:
		bg.modulate = Color("ff5959")
	MainInstances.Level.isDark = true
	MainInstances.Level.init()
	for light in get_tree().get_nodes_in_group("FlickerLight"):
		light.init()
	$Embers.emitting = true
