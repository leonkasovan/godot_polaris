extends "res://Effects/ExplodingDust.gd"

var rotDir = 0.0

func _ready():
	rotation_degrees = rand_range(0, 360)
	rotDir = rand_range( - 2, 2)
	$Sprite.frame = round(rand_range(0, 2))

func _process(delta):
	velo.y += grav * delta
	position += velo * delta
	rotation_degrees += rotDir
