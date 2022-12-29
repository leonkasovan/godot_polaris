extends Area2D

export (String, FILE, "*.tscn") var nextRoom = ""
export (int) var nextPosX = 0
export (int) var nextPosY = 0
export (bool) var flipX = false
export (bool) var isUpDoor = false
export (Vector2) var upDoorVelo = Vector2()

func _on_Door_body_entered(Player):
	if Player.state != Player.STATE.DOOR_JUMP:
		Player.emit_signal("hitDoor", self)
