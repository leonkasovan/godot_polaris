extends Node2D

export (Resource) var wingEvent
onready var BG = [$Camera / CameraBackground / Sky / BGPrologue, $Camera / CameraBackground / Parallax1 / BGCanyon, $Camera / CameraBackground / Parallax2 / BGCanyon2]
var spawned = false
var spawned3 = false

func _ready():
	call_deferred("init")

func init():
	$Wing / HurtBox / CollisionShape2D.disabled = true
	$Wing.global_position = Vector2(684, 176)
	$Wing.overrideInputVector = Vector2(1, 0)
	Music.play("ColdBreeze", 0)
	for spawner in $Spawners.get_children():
		spawner.spawn()
	for bg in BG:
		bg.modulate = Color("ff5959")
	MainInstances.Level.isDark = true
	MainInstances.Level.init()
	for light in get_tree().get_nodes_in_group("FlickerLight"):
		light.init()
	$Embers.emitting = true
	Global.lastRoom = "res://Levels/Level_24.tscn"


func _on_Spawner2Trigger_body_entered(_body):
	if not spawned:
		for spawner in $Spawners2.get_children():
			spawner.call_deferred("spawn")
		spawned = true

func _on_Spawner3Trigger_body_entered(_body):
	if not spawned3:
		for spawner in $Spawners3.get_children():
			spawner.call_deferred("spawn")
		spawned3 = true
