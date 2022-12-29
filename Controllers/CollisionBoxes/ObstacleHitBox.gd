extends "res://Controllers/CollisionBoxes/HitBox.gd"

export (int) var posx = 0
export (int) var posy = 0

var active = true

func _process(_delta):
	var collision = get_overlapping_areas()
	if collision.size() > 0 and active:
		for hurtbox in collision:
			if hurtbox.is_in_group("obstacleHurtBox"):
				hurtbox.emit_signal("obstacleHit", damage, posx, posy)
				active = false
	if collision.size() == 0 and not active:
		active = true
