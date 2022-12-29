extends StaticBody2D

export  var sizeScale:float = 1.0
const ExplodingDust = preload("res://Effects/ExplodingBoulderDust.tscn")
signal destroyed

func destroy():
	emit_signal("destroyed")
	randomize()
	var scaler = round(10.0 * sizeScale)
	for i in scaler:
		var dust = Utils.instanceScene(ExplodingDust, global_position + Vector2(0, rand_range( - 12, 12)))
		dust.velo = Vector2((35 * sizeScale) * (i - scaler / 2), rand_range(50, - 250 * sizeScale))
		dust.scale.x = sizeScale
		dust.scale.y = sizeScale
	queue_free()
