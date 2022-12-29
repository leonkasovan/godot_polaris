extends "res://Enemies/Enemy.gd"

enum DIRECTION{
	LEFT = - 1, 
	RIGHT = 1
}

export (DIRECTION) var walkDir = DIRECTION.RIGHT

onready var floorCast = $FloorCast
onready var wallCast = $WallCast

func _ready():
	wallCast.cast_to.x *= walkDir
	sprite.scale.x = walkDir
	
func _physics_process(delta):
	if wallCast.is_colliding():
		global_position = wallCast.get_collision_point()
		var normal = wallCast.get_collision_normal()
		rotation = normal.rotated(deg2rad(90)).angle()
	else :
		floorCast.rotation_degrees = - maxSpeed * 10 * walkDir * delta
		if floorCast.is_colliding():
			global_position = floorCast.get_collision_point()
			var normal = floorCast.get_collision_normal()
			rotation = normal.rotated(deg2rad(90)).angle()
		else :
			rotation_degrees += 20 * walkDir
