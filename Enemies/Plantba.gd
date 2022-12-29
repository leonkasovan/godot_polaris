extends "res://Enemies/Enemy.gd"

const PlantBullet = preload("res://Enemies/PlantBullet.tscn")

export (int) var bulletSpd = 30
export (float) var spread = 30

onready var bulletDir = $BulletDirection
onready var muzzle = $BulletSpawnPoint

func shoot():
	var bullet = Utils.instanceScene(PlantBullet, muzzle.global_position)
	var velocity = (bulletDir.global_position - global_position).normalized() * bulletSpd
	velocity = velocity.rotated(deg2rad(rand_range( - spread / 2, spread / 2)))
	bullet.velo = velocity
