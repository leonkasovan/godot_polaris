extends KinematicBody2D

var rotationSpeed = 2.0

func _physics_process(delta):
	
	pass
	
func _process(delta):
	rotateToTarget(MainInstances.Player, delta)
		
func rotateToTarget(target, delta):
	var direction = (target.global_position - global_position)
	var angleTo = transform.x.angle_to(direction)
	rotate(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))




