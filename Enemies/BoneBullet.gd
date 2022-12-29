extends "res://Common/Projectile.gd"
var Effect = preload("res://Effects/DustEffect.tscn")


func createDustEffect():
	Utils.instanceScene(Effect, global_position)
