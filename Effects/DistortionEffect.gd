extends Sprite


var time = 0

export (float) var scaleFluct = 0.1
export (float) var posFluct = 3.0
export (float) var freq = 5.0
export (float) var amplitude = 1.0

var amount = 0


var velo = Vector2.ZERO

func _ready():
	scale.x += rand_range( - scaleFluct, scaleFluct)
	scale.y += rand_range( - scaleFluct, scaleFluct)
	global_position += Vector2(rand_range( - posFluct, posFluct), rand_range( - posFluct, posFluct))

func _process(delta):
	time += delta
	amount = (sin(time * freq)) * amplitude
	material.set_shader_param("amount", amount)
	global_position += velo * delta
