extends Node2D

const DustEffect = preload("res://Effects/DustEffect.tscn")

var velo = Vector2()
export (int) var grav = 300

func _process(delta):
	velo.y += grav * delta
	position += velo * delta
	
func createDustEffect():
	Utils.instanceScene(DustEffect, global_position)
