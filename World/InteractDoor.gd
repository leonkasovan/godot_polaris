extends Node2D

export (String, FILE, "*.tscn") var nextRoom = ""
export (int) var nextPosX = 0
export (int) var nextPosY = 0
export (bool) var flipX = false
export (bool) var isUpDoor = false
export (Vector2) var upDoorVelo = Vector2()
var Player

func _ready():
	call_deferred("init")

func init():
	Player = MainInstances.Player

func _on_Interact_interact():
	Player.emit_signal("hitDoor", self)
