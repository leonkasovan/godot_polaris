extends Node2D

var velo = Vector2(rand_range( - 10, 10), rand_range(0, - 20))

func _process(delta):
	position += velo * delta
