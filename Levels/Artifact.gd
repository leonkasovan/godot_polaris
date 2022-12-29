extends Node2D

const distort = preload("res://Effects/DistortionEffect.tscn")

func createDistortion():
	var effect = Utils.instanceScene(distort, $Ring.global_position)
	effect.texture = $Ring.texture
	effect.scale = $Ring.scale
	effect.hframes = $Ring.hframes
	effect.frame = $Ring.frame
	effect.velo = Vector2.RIGHT * rand_range(2, 4)
	effect.amplitude = 1
	effect.z_index = z_index - 1
	var rot = deg2rad(rand_range(0, 360))
	effect.velo = effect.velo.rotated(rot)
