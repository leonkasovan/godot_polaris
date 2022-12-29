extends Node2D

enum ACTIVITY{
	stand, 
	roam
}

export (ACTIVITY) var activity
export (bool) var facePlayer = false

func _process(_delta):
	call_deferred("faceThePlayer")
	
func faceThePlayer():
	if facePlayer:
		var player = MainInstances.Player
		if player != null:
			$Sprite.scale.x = sign(player.global_position.x - global_position.x)
