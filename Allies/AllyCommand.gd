extends Area2D

enum COMMAND{
	null, 
	waitMove, 
	jump, 
	stop, 
	event, 
	inputOverride
}

enum DIRECTION{
	LEFT = - 1, 
	RIGHT = 1, 
	NONE = 0
}

export (DIRECTION) var commandDir = DIRECTION.NONE
export (COMMAND) var command = COMMAND.jump
export (Vector2) var jumpVelo = Vector2(140, - 300)
export (DIRECTION) var stopDir = DIRECTION.RIGHT
export (String, FILE, "*.tres") var event = null

func _process(_delta):
	allyInside()
	
func allyInside():
	var allies = get_overlapping_bodies()
	for ally in allies:
		if (ally.sprite.scale.x == commandDir
		 or commandDir == DIRECTION.NONE):
			ally.command = command
			ally.jumpVelo = jumpVelo
			ally.stopDir = stopDir
			ally.currentEvent = event

func _on_AllyCommand_body_exited(ally):
	ally.command = null
	ally.stopDir = 0
