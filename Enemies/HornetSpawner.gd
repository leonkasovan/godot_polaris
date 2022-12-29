extends Node2D

export (int) var initialRot = 0
export (PackedScene) var hornet = preload("res://Enemies/Hornet.tscn")

func _ready():
	pass

func spawn():
	var enemy = Utils.instanceScene(hornet, global_position, self)
	enemy.sprite.rotation_degrees = initialRot
