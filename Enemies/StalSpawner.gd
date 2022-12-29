extends Node2D

export (PackedScene) var Spawn
export (float) var delayTime = 0.1
export (float) var spawnTime = 1.0
onready var chest = get_parent()

func _ready():
	chest.connect("opened", self, "chestOpened")
	init()
	
func init():
	$Timer.wait_time = spawnTime
	yield (get_tree().create_timer(delayTime), "timeout")
	$Timer.start()
	
func chestOpened():
	$Timer.stop()

func _on_Timer_timeout():
	var spawn = Utils.instanceScene(Spawn, global_position)
	spawn.fall()
