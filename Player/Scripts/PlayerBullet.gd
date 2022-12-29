extends "res://Common/Projectile.gd"

func _ready():
	set_process(false)
	SFX.play("Bullet", rand_range(0.8, 1.1))
