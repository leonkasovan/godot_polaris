extends "res://Enemies/Enemy.gd"

enum DIRECTION{
	LEFT = - 1
	RIGHT = 1
}

export (DIRECTION) var walkDirection

var state
onready var floorLeft = $FloorLeft
onready var floorRight = $FloorRight
onready var wallLeft = $WallLeft
onready var wallRight = $WallRight

func _ready():
	state = walkDirection
	velo.y = 8
	
func _physics_process(_delta):
	match state:
		DIRECTION.RIGHT:
			velo.x = maxSpeed
			if not floorRight.is_colliding() or wallRight.is_colliding():
				state = DIRECTION.LEFT
		DIRECTION.LEFT:
			velo.x = - maxSpeed
			if not floorLeft.is_colliding() or wallLeft.is_colliding():
				state = DIRECTION.RIGHT
	sprite.scale.x = sign(velo.x)
	velo = move_and_slide_with_snap(velo, Vector2.DOWN * 4, Vector2.UP, true, 4, deg2rad(46))
